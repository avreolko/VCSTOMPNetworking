//
//  StompClient.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation
import Starscream

internal let ERROR_DOMAIN = "com.stompnetworking.error"

public protocol IStompClientDelegate: AnyObject {
    func stompClientDidConnected(_ client: IStompClient)
    func stompClient(_ client: IStompClient, didErrorOccurred error: NSError)
    func stompClient(_ client: IStompClient, didReceivedData data: Data, fromDestination destination: String)
}

public protocol IStompClient: AnyObject {

    var delegate: IStompClientDelegate? { get set }

    func connect()
    func disconnect()
    func subscribe(_ destination: String, parameters: [String: String]?) -> String
    func unsubscribe(_ destination: String, subscriptionID: String)
    func send(json: String, to destination: String)
}

public final class StompClient: IStompClient {

    private struct Settings {
        static let stompVersion = "1.2"
        static let reconnectDelay: TimeInterval = 1
    }

    public weak var delegate: IStompClientDelegate?

    private var socket: IWebSocket
    private var heartbeatTimer: Timer?
    private let heartbeatInterval: TimeInterval

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
        var headers: Set<StompHeader> = [.id(id), .destination(path: destination)]
        parameters?.forEach { headers.insert(.custom(key: $0, value: $1)) }

        let frame = StompFrame(command: .subscribe, headers: headers)
        sendFrame(frame)

        return id
    }

    public func unsubscribe(_ destination: String, subscriptionID: String) {
        let headers: Set<StompHeader> = [.id(subscriptionID), .destination(path: destination)]
        let frame = StompFrame(command: .unsubscribe, headers: headers)
        sendFrame(frame)
    }

    public func send(json: String, to destination: String) {
        let headers: Set<StompHeader> = [.destination(path: destination), .contentType(type: "application/json")]
        let frame = StompFrame(command: .send, headers: headers, body: json)
        sendFrame(frame)
    }
}

internal extension StompClient {

    func websocketDidConnect() {

        let heartbeatString = String(format: "%.0f", heartbeatInterval * 1_000)

        let headers: Set<StompHeader> = [
            .acceptVersion(version: Settings.stompVersion),
            .heartBeat(value: "\(heartbeatString),0")
        ]

        let frame = StompFrame(command: .connect, headers: headers)
        sendFrame(frame)
    }

    func websocketDidDisconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Settings.reconnectDelay) { [weak self] in
            self?.socket.connect()
        }
    }

    func websocketDidReceiveMessage(text: String) {

        do {

            let frame = try StompFrame(text: text)

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

private extension StompClient {

    func sendFrame(_ frame: StompFrame) {
        socket.write(string: frame.stringRepresentation)
        resetHeartbeatTimer()
    }

    func resetHeartbeatTimer() {

        heartbeatTimer?.invalidate()

        heartbeatTimer = Timer.scheduledTimer(
            timeInterval: heartbeatInterval,
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
