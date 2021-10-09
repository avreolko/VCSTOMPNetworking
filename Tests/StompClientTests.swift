//
//  STOMPClientTests.swift
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
import Starscream
@testable import STOMPNetworking

final class STOMPClientTests: XCTestCase {

    private var clientDelegateMock: StompClientDelegateMock!
    private var client: STOMPClient!
    private var socketMock: WebSocketMock!

    override func setUp() {
        super.setUp()
        socketMock = WebSocketMock()
        client = STOMPClient(socket: socketMock)
        clientDelegateMock = StompClientDelegateMock()
        client.delegate = clientDelegateMock
    }

    func test_socket_connecting() {

        // Act
        client.connect()

        // Assert
        XCTAssert(socketMock.connectCalled)
    }

    func test_disconnect_frame() {

        // Arrange
        let expectedFrameStringRepresentation = "DISCONNECT\n\n\0"

        // Act
        client.disconnect()

        // Assert
        XCTAssert(socketMock.writeCalled)
        XCTAssertEqual(socketMock.writtenString, expectedFrameStringRepresentation)
    }

    func test_subscribe_frame() {

        // Arrange
        let destination = "path"

        // Act
        _ = client.subscribe(destination, parameters: ["eid" : "5566"])

        // Assert
        XCTAssert(socketMock.writeCalled)
        XCTAssertTrue(socketMock.writtenString.contains("SUBSCRIBE\n"))
        XCTAssertTrue(socketMock.writtenString.contains("destination:\(destination)"))
        XCTAssertTrue(socketMock.writtenString.contains("id:"))
        XCTAssertTrue(socketMock.writtenString.contains("eid:5566"))
    }
    
    func test_unsubscribe_frame() {

        // Arrange
        let destination = "path"

        // Act
        client.unsubscribe(destination, subscriptionID: "sub-0")

        // Assert
        XCTAssert(socketMock.writeCalled)
        XCTAssertTrue(socketMock.writtenString.contains("UNSUBSCRIBE\n"))
        XCTAssertTrue(socketMock.writtenString.contains("destination:\(destination)"))
    }

    func test_json_sending() {

        // Arrange
        let destination = "path"
        let json = "{\"field\": \"value\"}"

        // Act
        client.send(json: json, to: destination)

        // Assert
        XCTAssert(socketMock.writeCalled)
        XCTAssertTrue(socketMock.writtenString.contains("content-type:application/json"))
        XCTAssertTrue(socketMock.writtenString.contains("{\"field\": \"value\"}"))
        XCTAssertTrue(socketMock.writtenString.contains("SEND"))
    }
}

private final class StompClientDelegateMock: NSObject, ISTOMPClientDelegate {

    var didConnectedMethodCalled = false
    var receivedData: Data?
    var receivedError: NSError?
    var destination: String?

    func stompClientDidConnected(_ client: ISTOMPClient) {
        didConnectedMethodCalled = true
    }

    func stompClient(_ client: ISTOMPClient, didErrorOccurred error: NSError) {
        receivedError = error
    }

    func stompClient(_ client: ISTOMPClient, didReceivedData data: Data, fromDestination destination: String) {
        receivedData = data
        self.destination = destination
    }
}

private final class WebSocketMock: IWebSocket {

    var isConnected: Bool = false

    var writtenString: String!

    var connectCalled = false
    var disconnectCalled = false
    var writeCalled = false

    func connect() {
        connectCalled = true
    }

    func disconnect() {
        disconnectCalled = true
    }

    func write(string: String) {
        writeCalled = true
        writtenString = string
    }

}
