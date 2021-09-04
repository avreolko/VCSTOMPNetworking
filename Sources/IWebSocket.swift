//
//  IWebSocket.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation

public protocol IWebSocket {
    func connect()
    func disconnect()
    func write(string: String)
}
