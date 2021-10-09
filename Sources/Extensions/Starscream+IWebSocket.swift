//
//  Starscream+IWebSocket.swift
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
