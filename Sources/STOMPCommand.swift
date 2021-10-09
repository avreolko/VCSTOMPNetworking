//
//  STOMPCommand.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation

/// STOMP commands enumeration.
enum STOMPCommand: String {

    // MARK: - Client commands

    /// Connection command.
    case connect = "CONNECT"

    /// Disconnection command.
    case disconnect = "DISCONNECT"

    /// Subscription command.
    case subscribe = "SUBSCRIBE"

    /// Unsubscription command.
    case unsubscribe = "UNSUBSCRIBE"

    /// Command for data sending.
    case send = "SEND"

    // MARK: - Server commands

    /// Command for connection affirmation.
    case connected = "CONNECTED"

    /// Command for message receiving.
    case message = "MESSAGE"

    /// Error command.
    case error = "ERROR"

    /// Method for command initialization from string representation.
    ///
    /// - Parameters:
    ///   - text: Command string representation.
    ///
    /// - Throws: Error in `com.stompnetworking.error` domain if command was not recognized.
    init(text: String) throws {

        guard let command = STOMPCommand(rawValue: text) else {
            let info = [NSLocalizedDescriptionKey: "Received command is undefined."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_004, userInfo: info)
        }

        self = command
    }
}
