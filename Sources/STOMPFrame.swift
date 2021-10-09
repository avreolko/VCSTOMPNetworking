//
//  STOMPFrame.swift
//  STOMPNetworking
//
//  Copyright © 2020 Valentin Cherepyanko. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// STOMP frame.
struct STOMPFrame {

    private static let lineFeed = "\n"
    private static let nullChar = "\0"

    /// Frame command.
    private(set) var command: STOMPCommand

    /// Frame headers.
    private(set) var headers: Set<STOMPHeader>

    /// Frame body.
    private(set) var body: String?

    /// STOMP frame initialization method.
    ///
    /// - Parameters:
    ///   - command: STOMP command associated with this frame.
    ///   - headers: Frame headers dictionary.
    ///   - body: Optional body in string representation.
    init(command: STOMPCommand, headers: Set<STOMPHeader> = [], body: String? = nil) {
        self.command = command
        self.headers = headers
        self.body = body
    }

    /// STOMP frame initialization method.
    ///
    /// For more details read official documentation:
    ///
    /// https://stomp.github.io/stomp-specification-1.2.html#STOMP_Frames
    ///
    /// - Parameters:
    ///   - text: String representation of the STOMP frame.
    ///
    /// - Throws: Error in `com.stompnetworking.error` domain if text parsing failed.
    init(text: String) throws {

        let parts: [String] = text.components(separatedBy: Self.lineFeed + Self.lineFeed)

        guard !parts.isEmpty else {
            let info = [NSLocalizedDescriptionKey: "Frame is empty."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_002, userInfo: info)
        }

        guard parts.count < 3 else {
            let info = [NSLocalizedDescriptionKey: "Received frame does not conform specification."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_003, userInfo: info)
        }

        // Command + headers
        let firstPartComponents = parts.first?.split(separator: Character(Self.lineFeed))

        guard let commandComponent = firstPartComponents?.first else {
            let info = [NSLocalizedDescriptionKey: "Frame does not have a command."]
            throw NSError(domain: ERROR_DOMAIN, code: 1_004, userInfo: info)
        }

        // Command initialization
        let command = try STOMPCommand(text: String(commandComponent))

        // Headers
        let headerComponents = firstPartComponents?.dropFirst() ?? []

        let headers: [STOMPHeader] = headerComponents.compactMap { headerString in
            let headerParts = headerString.components(separatedBy: ":")
            guard let key = headerParts.first, let value = headerParts.last else { return nil }
            return STOMPHeader(key: key, value: value)
        }

        var body = (parts.count == 2) ? parts.last : nil
        if body?.hasSuffix(Self.nullChar) ?? false { body = String(body?.dropLast() ?? "") }

        self.init(command: command, headers: Set(headers), body: body)
    }

    /// String representation of this frame.
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

    /// Frame message.
    var message: String {
        if let header = headers.filter(\.isMessage).first {
            return header.value
        } else {
            return ""
        }
    }

    /// Frame destination.
    var destination: String {
        if let header = headers.filter(\.isDestination).first {
            return header.value
        } else {
            return ""
        }
    }
}
