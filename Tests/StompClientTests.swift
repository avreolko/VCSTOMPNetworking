//
//  StompClientTests.swift
//  StompClientTests
//
//  Created by Valentin Cherepyanko on 29.03.2021.
//

import XCTest
import Starscream
@testable import STOMPNetworking

final class StompClientTests: XCTestCase {

    private var clientDelegateMock: StompClientDelegateMock!
    private var client: StompClient!
    private var socketMock: WebSocketMock!

    override func setUp() {
        super.setUp()
        socketMock = WebSocketMock()
        client = StompClient(socket: socketMock)
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

private final class StompClientDelegateMock: NSObject, IStompClientDelegate {

    var didConnectedMethodCalled = false
    var receivedData: Data?
    var receivedError: NSError?
    var destination: String?

    func stompClientDidConnected(_ client: IStompClient) {
        didConnectedMethodCalled = true
    }

    func stompClient(_ client: IStompClient, didErrorOccurred error: NSError) {
        receivedError = error
    }

    func stompClient(_ client: IStompClient, didReceivedData data: Data, fromDestination destination: String) {
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
