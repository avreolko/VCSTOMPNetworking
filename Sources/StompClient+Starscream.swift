//
//  Starscream+STOMPNetworking.swift
//  
//
//  Created by Valentin Cherepyanko on 02.04.2021.
//

import Foundation
import Starscream

extension WebSocket: IWebSocket {

    public func disconnect() {
        self.disconnect(closeCode: CloseCode.normal.rawValue)
    }
}

extension StompClient {

    public convenience init(url: URL) {

        let urlRequest = URLRequest(url: url)
        let socket = WebSocket(request: urlRequest)

        self.init(socket: socket)

        socket.delegate = self
    }
}

extension StompClient: WebSocketDelegate {

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
