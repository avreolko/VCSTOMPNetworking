//
//  STOMPClient+StarScream.swift
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

extension STOMPClient: WebSocketDelegate {

    public func didReceive(event: WebSocketEvent, client: WebSocket) {

        switch event {
        case .connected:
            websocketDidConnect()
        case .disconnected:
            websocketDidDisconnect()
        case .text(let text):
            websocketDidReceiveMessage(text: text)
        case .error(let error):
            print(error?.localizedDescription ?? "[StompClient] Error received!")
        case .pong, .ping, .binary, .viabilityChanged, .reconnectSuggested, .cancelled:
            () // do nothing
        }
    }
}

extension STOMPClient {

    /// Convenience initialization method.
    ///
    /// - Parameters:
    ///   - url: URL for internal web socket.
    ///
    /// - Returns: "Ready to go" STOMP client.
    public convenience init(url: URL) {

        let urlRequest = URLRequest(url: url)
        let socket = WebSocket(request: urlRequest)

        self.init(socket: socket)

        socket.delegate = self
    }
}
