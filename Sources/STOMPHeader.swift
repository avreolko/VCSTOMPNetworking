//
//  STOMPHeader.swift
//  STOMPNetworking
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import Foundation

/// STOMP header enumeration.
enum STOMPHeader {

    /// Protocol version that client sends.
    ///
    /// Possible values:
    /// - 1.0
    /// - 1.1
    /// - 1.2
    case acceptVersion(version: String)

    /// Hearbeat setting header.
    ///
    /// - Parameters:
    ///   - value: Settings in format of `x,y`. Where:
    ///   - x: Clint hearbeat interval in milliseconds.
    ///   - y: Desired server heartbeat interval.
    case heartBeat(value: String)

    /// Frame destination header.
    ///
    /// - Parameters:
    ///   - path: String representation of the destination.
    case destination(path: String)

    /// Frame identifier.
    ///
    /// - Parameters:
    ///   - id: Identifier value.
    case id(_ id: String)

    /// Protocol version that server sends to client.
    ///
    /// Possible values:
    /// - 1.0
    /// - 1.1
    /// - 1.2
    case version(version: String)

    /// Header with unique subscription identifier.
    case subscription(subId: String)

    /// Header with message identifier.
    case messageId(id: String)

    /// Length of sent or received content.
    case contentLength(length: String)

    /// Message header.
    case message(message: String)

    /// Content type header.
    case contentType(type: String)

    /// Any other header value.
    ///
    /// - Parameters:
    ///   - key: Header key.
    ///   - value: Header value.
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

    /// Flag, that indicates header as message.
    var isMessage: Bool {
        switch self {
        case .message: return true
        default: return false
        }
    }

    /// Flag, that indicates header as destination.
    var isDestination: Bool {
        switch self {
        case .destination: return true
        default: return false
        }
    }

    /// Header key.
    var key: String {
        switch self {
        case .acceptVersion: return "accept-version"
        case .heartBeat: return "heart-beat"
        case .destination: return "destination"
        case .id: return "id"
        case .version: return "version"
        case .subscription: return "subscription"
        case .messageId: return "message-id"
        case .contentLength: return "content-length"
        case .message: return "message"
        case .contentType: return "content-type"
        case .custom(let key, _): return key
        }
    }

    /// Header value.
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

extension STOMPHeader: Hashable, Equatable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(key.hashValue)
    }

    static func == (lhs: STOMPHeader, rhs: STOMPHeader) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
