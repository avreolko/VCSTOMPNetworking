//
//  StompFrameTests.swift
//  StompClient
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import XCTest
@testable import STOMPNetworking

final class StompFrameTests: XCTestCase {

    func test_frame_creation() {

        // Arrange
        let parameters = ["eid" : "5566", "mid" : "7788"]

        var headers: Set<StompHeader> = [.destination(path: "/path"), .id("sub-id")]

        for (key, value) in parameters {
            headers.insert(.custom(key: key, value: value))
        }

        // Act
        let frame = StompFrame(command: .subscribe, headers: headers)

        // Assert
        XCTAssertEqual(frame.command, StompCommand.subscribe)
        XCTAssertEqual(frame.headers.count, 4)
    }
    
    func test_frame_creation_from_text() throws {

        // Arrange
        let string = "MESSAGE\ndestination:/user/topic/view/0\nsubscription:sub-0\nmessage-id:1234\ncontent-length:0\n\nbody\n\0"

        // Act
        let frame = try StompFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, StompCommand.message)
        XCTAssertEqual(frame.headers.count, 4)
        XCTAssertNotNil(frame.body)
    }

    func test_frame_creation_from_text_without_body() throws {

        // Arrange
        let string = "MESSAGE\ndestination:/user/topic/view/0\nsubscription:sub-0\nmessage-id:1234\ncontent-length:0\0"

        // Act
        let frame = try StompFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, StompCommand.message)
        XCTAssertEqual(frame.headers.count, 4)
        XCTAssertNil(frame.body)
    }

    func test_frame_creation_from_text_without_headers() throws {

        // Arrange
        let string = "MESSAGE\n\nbody\n\0"

        // Act
        let frame = try StompFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, StompCommand.message)
        XCTAssertEqual(frame.headers.count, 0)
        XCTAssertNotNil(frame.body)
    }

    func test_frame_creation_from_text_without_headers_and_body() throws {

        // Arrange
        let string = "MESSAGE\n\n\0"

        // Act
        let frame = try StompFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, StompCommand.message)
        XCTAssertEqual(frame.headers.count, 0)
        XCTAssertNotNil(frame.body)
    }

    func test_frame_creation_from_text_with_body_containing_linefeeds() throws {

        // Arrange
        let string = "MESSAGE\n\nbody\nbody\n\0"

        // Act
        let frame = try StompFrame(text: string)

        // Assert
        XCTAssertEqual(frame.command, StompCommand.message)
        XCTAssertEqual(frame.body, "body\nbody\n")
    }

    func test_frame_creation_from_text_with_multiple_bodies() {

        // Arrange
        let string = "MESSAGE\n\nbody\n\nbody\n\0"

        // Act
        // Assert
        XCTAssertThrowsError(try StompFrame(text: string))
    }

    func test_empty_command_error_throwing() throws {

        // Arrange
        let string = "\n\nbody\nbody\n\0"

        // Act
        // Assert
        XCTAssertThrowsError(try StompFrame(text: string))
    }

    func test_unknown_command_error_throwing() throws {

        // Arrange
        let string = "SOMECOMMAND\n\nbody\nbody\n\0"

        // Act
        // Assert
        XCTAssertThrowsError(try StompFrame(text: string))
    }
}
