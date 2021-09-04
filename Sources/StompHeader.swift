//
//  StompHeader.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation

/// Перечисление STOMP заголовков.
enum StompHeader {

    /// Версия протокола, посылаемая клиентом.
    /// Возможные значения:
    /// - 1.0
    /// - 1.1
    /// - 1.2
    case acceptVersion(version: String)

    /// Настройки сердцебиения.
    ///
    /// - Parameters:
    ///   - value: Настройки в формате `x,y`. Где:
    ///   - x: Интервал сердцебиения клиента в миллисекундах.
    ///   - y: Желаемый интервал сердцебиения сервера в миллисекундах.
    case heartBeat(value: String)

    /// Назначение фрейма.
    ///
    /// - Parameters:
    ///   - path: Строковое представление назначения.
    case destination(path: String)

    /// Идентификатор фрейма.
    ///
    /// - Parameters:
    ///   - id: Значение идентификатора.
    case id(_ id: String)

    /// Версия протокола, посылаемая сервером.
    ///
    /// Возможные значения версии:
    /// - 1.0
    /// - 1.1
    /// - 1.2
    case version(version: String)

    /// Заголовок с идентификатором подписки, присылаемый сервером.
    case subscription(subId: String)

    /// Заголовок, содержащий идентификатор сообщения.
    case messageId(id: String)

    /// Длина отсылаемого и получаемого контента.
    case contentLength(length: String)

    /// Сообщение.
    case message(message: String)

    /// Тип контента.
    case contentType(type: String)

    /// Любой другой заголовок.
    ///
    /// - Parameters:
    ///   - key: Ключ заголовка.
    ///   - value: Значение заголовка.
    case custom(key: String, value: String)

    init(key: String, value: String) {
        switch key {
        case "version": self = .version(version: value)
        case "subscription": self = .subscription(subId: value)
        case "message-id": self = .messageId(id: value)
        case "content-length": self = .contentLength(length: value)
        case "message": self = .message(message: value)
        case "destination": self = .destination(path: value)
        case "heart-beat": self = .heartBeat(value: value)
        case "content-type": self = .contentType(type: value)
        default: self = .custom(key: key, value: value)
        }
    }

    /// Флаг, показывающий является ли заголовок сообщением.
    var isMessage: Bool {
        switch self {
        case .message: return true
        default: return false
        }
    }

    /// Флаг, показывающий является ли заголовок назначением.
    var isDestination: Bool {
        switch self {
        case .destination: return true
        default: return false
        }
    }

    /// Ключ заголовка.
    var key: String {
        switch self {
        case .acceptVersion: return "accept-version"
        case .heartBeat: return "heart-beat"
        case .destination: return "destination"
        case .id: return "id"
        case .custom(let key, _): return key
        case .version: return "version"
        case .subscription: return "subscription"
        case .messageId: return "message-id"
        case .contentLength: return "content-length"
        case .message: return "message"
        case .contentType: return "content-type"
        }
    }

    /// Значение заголовка.
    var value: String {
        switch self {
        case .acceptVersion(let version): return version
        case .heartBeat(let value): return value
        case .destination(let path): return path
        case .id(let id): return id
        case .custom(_, let value): return value
        case .version(let version): return version
        case .subscription(let subId): return subId
        case .messageId(let id): return id
        case .contentLength(let length): return length
        case .message(let body): return body
        case .contentType(let type): return type
        }
    }
}

extension StompHeader: Hashable, Equatable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(key.hashValue)
    }

    static func == (lhs: StompHeader, rhs: StompHeader) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
