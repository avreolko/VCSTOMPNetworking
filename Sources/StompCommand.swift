//
//  StompCommand.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation

/// Перечисление STOMP команд.
enum StompCommand: String {

    // MARK: - Команды клиента.

    /// Команда установки подключения.
    case connect = "CONNECT"

    /// Команда завершения подключения.
    case disconnect = "DISCONNECT"

    /// Команда подписки на назначение.
    case subscribe = "SUBSCRIBE"

    /// Команда отписки на назначение.
    case unsubscribe = "UNSUBSCRIBE"

    /// Команда отправки сообщения.
    case send = "SEND"

    // MARK: - Команды сервера.

    /// Команда подтверждения установки подключения.
    case connected = "CONNECTED"

    /// Команда получения сообщения.
    case message = "MESSAGE"

    /// Команда ошибки.
    case error = "ERROR"

    /// Метод инициализации команды, выбрасывающий ошибку.
    ///
    /// Нужен для того, чтобы вместо `nil` получать ошибку с кодом и доменом.
    ///
    /// - Parameters:
    ///   - text: Строковое представление команды.
    init(text: String) throws {

        guard let command = StompCommand(rawValue: text) else {
            let info = [NSLocalizedDescriptionKey: "Received command is undefined."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_004, userInfo: info)
        }

        self = command
    }
}
