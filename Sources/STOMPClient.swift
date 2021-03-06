//
//  STOMPClient.swift
//  STOMPNetworking
//
//  Copyright © 2020 Valentin Cherepyanko. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Starscream

internal let ERROR_DOMAIN = "com.stompnetworking.error"

/// Public interface of STOMP client delegate.
///
/// Allows mocking for internal testing.
public protocol ISTOMPClientDelegate: AnyObject {

    /// Method, that will be called on successful client connection.
    ///
    /// - Parameters:
    ///   - client: Client instance connected to the server.
    func stompClientDidConnected(_ client: ISTOMPClient)

    /// Metahd, that will be called on any error occured in process of communication between client and server.
    ///
    /// - Parameters:
    ///   - client: Client instance that received an error.
    ///   - error: Received error.
    func stompClient(_ client: ISTOMPClient, didErrorOccurred error: NSError)

    /// Method, that will called on receiving some data from the server.
    ///
    /// - Parameters:
    ///   - client: Client instance that received a data.
    ///   - data: Received data.
    ///   - destination: Subscribed destination.
    func stompClient(_ client: ISTOMPClient, didReceivedData data: Data, fromDestination destination: String)
}

/// Public interface of STOMP client.
public protocol ISTOMPClient: AnyObject {

    /// Delegate object that should conform to `ISTOMPClientDelegate` protocol.
    var delegate: ISTOMPClientDelegate? { get set }

    /// Connection method.
    func connect()

    /// Disconnection method.
    func disconnect()

    /// Subcription method.
    ///
    /// - Parameters:
    ///   - destination: Destination of the subscription.
    ///   - parameters: Dictionary of parameters passed to subscription.
    ///
    /// - Returns: Unique identifer of the subscription in string representation.
    func subscribe(_ destination: String, parameters: [String: String]?) -> String

    /// Unsubscription method.
    ///
    /// - Parameters:
    ///   - destination: Destination of the subscription.
    ///   - subscriptionID: Unique identifer of the subscription in string representation.
    func unsubscribe(_ destination: String, subscriptionID: String)

    /// Method for sending JSON data.
    ///
    /// Beside data sending this method also sets `content-type` header to `application/json`.
    ///
    /// - Parameters:
    ///   - json: JSON string.
    ///   - destination: Destination of the subscription.
    func send(json: String, to destination: String)

    /// Method for sending data in string representation.
    ///
    /// - Parameters:
    ///   - string: Data in string representation.
    ///   - destination: Destination of the subscription.
    func send(string: String, to destination: String)
}

/// STOMP client implementation.
public final class STOMPClient: ISTOMPClient {

    private struct Settings {
        static let stompVersion = "1.2"
        static let reconnectDelay: TimeInterval = 1
    }

    /// STOMP client delegate object.
    public weak var delegate: ISTOMPClientDelegate?

    private var socket: IWebSocket
    private var heartbeatTimer: Timer?
    private let heartbeatInterval: TimeInterval

    /// STOMP client initialization method.
    ///
    /// Passed heartbeat interval value divides by two to take into account possible network delays.
    ///
    /// - Parameters:
    ///   - socket: Object that conforms to `IWebSocket` protocol.
    ///   - heartbeatInterval: Heartbeating interval in seconds.
    public init(socket: IWebSocket, heartbeatInterval: TimeInterval = 15) {
        self.socket = socket
        self.heartbeatInterval = heartbeatInterval
    }

    deinit {
        heartbeatTimer?.invalidate()
    }

    public func connect() {
        socket.connect()
    }

    public func disconnect() {
        sendFrame(.init(command: .disconnect))
        socket.disconnect()
    }

    public func subscribe(_ destination: String, parameters: [String: String]? = nil) -> String {

        let id = UUID().uuidString
        var headers: Set<STOMPHeader> = [.id(id), .destination(path: destination)]
        parameters?.forEach { headers.insert(.custom(key: $0, value: $1)) }

        let frame = STOMPFrame(command: .subscribe, headers: headers)
        sendFrame(frame)

        return id
    }

    public func unsubscribe(_ destination: String, subscriptionID: String) {
        let headers: Set<STOMPHeader> = [.id(subscriptionID), .destination(path: destination)]
        let frame = STOMPFrame(command: .unsubscribe, headers: headers)
        sendFrame(frame)
    }

    public func send(json: String, to destination: String) {
        let headers: Set<STOMPHeader> = [.destination(path: destination), .contentType(type: "application/json")]
        let frame = STOMPFrame(command: .send, headers: headers, body: json)
        sendFrame(frame)
    }

    public func send(string: String, to destination: String) {
        let headers: Set<STOMPHeader> = [.destination(path: destination)]
        let frame = STOMPFrame(command: .send, headers: headers, body: string)
        sendFrame(frame)
    }
}

internal extension STOMPClient {

    func websocketDidConnect() {

        let heartbeatString = String(format: "%.0f", heartbeatInterval * 1_000)

        let headers: Set<STOMPHeader> = [
            .acceptVersion(version: Settings.stompVersion),
            .heartBeat(value: "\(heartbeatString),0")
        ]

        let frame = STOMPFrame(command: .connect, headers: headers)
        sendFrame(frame)
    }

    func websocketDidDisconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Settings.reconnectDelay) { [weak self] in
            self?.socket.connect()
        }
    }

    func websocketDidReceiveMessage(text: String) {

        do {

            let frame = try STOMPFrame(text: text)

            switch frame.command {
            case .connected:
                delegate?.stompClientDidConnected(self)
            case .message:
                guard let data = frame.body?.data(using: String.Encoding.utf8) else { return }
                delegate?.stompClient(self, didReceivedData: data, fromDestination: frame.destination)
            case .error:
                let info = [NSLocalizedDescriptionKey: frame.message]
                let error = NSError(domain: ERROR_DOMAIN, code: 999, userInfo: info)
                delegate?.stompClient(self, didErrorOccurred: error)
            default:
                break
            }

        } catch let error as NSError {
            delegate?.stompClient(self, didErrorOccurred: error)
        }
    }
}

private extension STOMPClient {

    func sendFrame(_ frame: STOMPFrame) {
        socket.write(string: frame.stringRepresentation)
        resetHeartbeatTimer()
    }

    func resetHeartbeatTimer() {

        heartbeatTimer?.invalidate()

        heartbeatTimer = Timer.scheduledTimer(
            timeInterval: heartbeatInterval / 2,
            target: self,
            selector: #selector(heartbeat),
            userInfo: nil,
            repeats: false
        )
    }

    @objc
    func heartbeat() {
        socket.write(string: "\r\n")
        resetHeartbeatTimer()
    }
}
