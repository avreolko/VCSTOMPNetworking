//
//  STOMPClient+StarScream.swift
//  
//
//  Created by Valentin Cherepyanko on 09.10.2021.
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
