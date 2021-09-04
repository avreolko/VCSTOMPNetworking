//
//  StompFrame.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation

/// Фрейм STOMP-протокола.
struct StompFrame {

    private static let lineFeed = "\n"
    private static let nullChar = "\0"

    /// Команда фрейма.
    private(set) var command: StompCommand

    /// Заголовки фрейма.
    private(set) var headers: Set<StompHeader>

    /// Тело фрейма.
    private(set) var body: String?

    /// Метод инициализации фрейма.
    ///
    /// - Parameters:
    ///   - command: Команда фрейма.
    ///   - headers: Заголовки фрейма.
    ///   - body: Тело фрейма.
    init(command: StompCommand, headers: Set<StompHeader> = [], body: String? = nil) {
        self.command = command
        self.headers = headers
        self.body = body
    }

    /// Метод инициализации фрейма.
    ///
    /// - Parameters:
    ///   - text: Текстовое представление фрейма.
    init(text: String) throws {

        let parts: [String] = text.components(separatedBy: Self.lineFeed + Self.lineFeed)

        guard !parts.isEmpty else {
            let info = [NSLocalizedDescriptionKey: "Полученный фрейм пуст."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_002, userInfo: info)
        }

        guard parts.count < 3 else {
            let info = [NSLocalizedDescriptionKey: "Полученный фрейм не соответствует протоколу."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_003, userInfo: info)
        }

        // Команда + заголовки
        let firstPartComponents = parts.first?.split(separator: Character(Self.lineFeed))

        guard let commandComponent = firstPartComponents?.first else {
            let info = [NSLocalizedDescriptionKey: "Во фрейме отсутствует команда."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_004, userInfo: info)
        }

        // Команда
        let command = try StompCommand(text: String(commandComponent))

        // Заголовки
        let headerComponents = firstPartComponents?.dropFirst() ?? []

        let headers: [StompHeader] = headerComponents.compactMap { headerString in
            let headerParts = headerString.components(separatedBy: ":")
            guard let key = headerParts.first, let value = headerParts.last else { return nil }
            return StompHeader(key: key, value: value)
        }

        var body = (parts.count == 2) ? parts.last : nil
        if body?.hasSuffix(Self.nullChar) ?? false { body = String(body?.dropLast() ?? "") }

        self.init(command: command, headers: Set(headers), body: body)
    }

    /// Строковое представление фрейма.
    var stringRepresentation: String {
        var string = command.rawValue + Self.lineFeed
        headers.forEach { string += $0.key + ":" + $0.value + Self.lineFeed }

        body.map {
            string += Self.lineFeed
            string += $0
        }

        string += Self.lineFeed + Self.nullChar
        return string
    }

    /// Сообщение фрейма.
    var message: String {
        if let header = headers.filter(\.isMessage).first {
            return header.value
        } else {
            return ""
        }
    }

    /// Назначение фрейма.
    var destination: String {
        if let header = headers.filter(\.isDestination).first {
            return header.value
        } else {
            return ""
        }
    }
}
