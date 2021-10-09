//
//  IWebSocket.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation

/// Abstract interface of web socket.
///
/// Allows to use any web socket implementation.
public protocol IWebSocket {

    /// Method for connection initialization.
    func connect()

    /// Method for web socket disconnection.
    func disconnect()

    /// Method for writing some string data in web socket.
    ///
    /// - Parameters:
    ///   - string: Data in string representation.
    func write(string: String)
}
