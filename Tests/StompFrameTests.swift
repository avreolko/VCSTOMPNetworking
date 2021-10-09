//
//  STOMPFrameTests.swift
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

import XCTest
@testable import STOMPNetworking

final class STOMPFrameTests: XCTestCase {

    func test_frame_creation() {

        // Arrange
        let parameters = ["eid" : "5566", "mid" : "7788"]

        var headers: Set<STOMPHeader> = [.destination(path: "/path"), .id("sub-id")]

        for (key, value) in parameters {
            headers.insert(.custom(key: key, value: value))
        }

        // Act
        let frame = STOMPFrame(command: .subscribe, headers: headers)

        // Assert
        XCTAssertEqual(frame.command, STOMPCommand.subscribe)
        XCTAssertEqual(frame.headers.count, 4)
    }
    
    func test_frame_creation_from_text() throws {

        // Arrange
        let string = "MESSAGE\ndestination:/user/topic/view/0\nsubscription:sub-0\nmessage-id:1234\ncontent-length:0\n\nbody\n\0"

        // Act
        let frame = try STOMPFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, STOMPCommand.message)
        XCTAssertEqual(frame.headers.count, 4)
        XCTAssertNotNil(frame.body)
    }

    func test_frame_creation_from_text_without_body() throws {

        // Arrange
        let string = "MESSAGE\ndestination:/user/topic/view/0\nsubscription:sub-0\nmessage-id:1234\ncontent-length:0\0"

        // Act
        let frame = try STOMPFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, STOMPCommand.message)
        XCTAssertEqual(frame.headers.count, 4)
        XCTAssertNil(frame.body)
    }

    func test_frame_creation_from_text_without_headers() throws {

        // Arrange
        let string = "MESSAGE\n\nbody\n\0"

        // Act
        let frame = try STOMPFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, STOMPCommand.message)
        XCTAssertEqual(frame.headers.count, 0)
        XCTAssertNotNil(frame.body)
    }

    func test_frame_creation_from_text_without_headers_and_body() throws {

        // Arrange
        let string = "MESSAGE\n\n\0"

        // Act
        let frame = try STOMPFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, STOMPCommand.message)
        XCTAssertEqual(frame.headers.count, 0)
        XCTAssertNotNil(frame.body)
    }

    func test_frame_creation_from_text_with_body_containing_linefeeds() throws {

        // Arrange
        let string = "MESSAGE\n\nbody\nbody\n\0"

        // Act
        let frame = try STOMPFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, STOMPCommand.message)
        XCTAssertEqual(frame.body, "body\nbody\n")
    }

    func test_frame_creation_from_text_with_multiple_bodies() {

        // Arrange
        let string = "MESSAGE\n\nbody\n\nbody\n\0"

        // Act
        // Assert
        XCTAssertThrowsError(try STOMPFrame(text: string))
    }

    func test_empty_command_error_throwing() throws {

        // Arrange
        let string = "\n\nbody\nbody\n\0"

        // Act
        // Assert
        XCTAssertThrowsError(try STOMPFrame(text: string))
    }

    func test_unknown_command_error_throwing() throws {

        // Arrange
        let string = "SOMECOMMAND\n\nbody\nbody\n\0"

        // Act
        // Assert
        XCTAssertThrowsError(try STOMPFrame(text: string))
    }
}
