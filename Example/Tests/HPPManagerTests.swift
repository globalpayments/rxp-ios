//
//  HPPManagerTests.swift
//  RXPiOS_Tests
//
//  Copyright © 2020 GlobalPayments. All rights reserved.
//

import XCTest
@testable import RXPiOS

class HPPManagerTests: XCTestCase {

    let session = URLSessionMock()
    var sut: HPPManager?

    override func setUp() {

        sut = HPPManager(session: session)
        sut?.HPPRequestProducerURL = URL(string: "https://www.example.com/HppRequestProducer")
        sut?.HPPURL = URL(string: "https://pay.sandbox.realexpayments.com/pay")
        sut?.HPPResponseConsumerURL = URL(string: "https://www.example.com/HppResponseConsumer")
    }

    override func tearDown() {
        sut = nil
    }

    func testHPPManagerShouldNotContainAdditionalHeaders() {
        // Given
        let viewController = UIViewController()
        // When
        sut?.presentViewInViewController(viewController)
        // Then
        XCTAssertNil(sut?.additionalHeaders)
    }

    func testHPPManagerShouldContainAdditionalHeader() {
        // Given
        let viewController = UIViewController()
        sut?.additionalHeaders = ["custom_header": "test_value"]
        // When
        sut?.presentViewInViewController(viewController)
        // Then
        let request: URLRequest? = session.request
        XCTAssertNotNil(sut?.additionalHeaders)
        XCTAssertTrue((request?.allHTTPHeaderFields?.keys.contains("custom_header"))!)
        XCTAssertEqual(request?.value(forHTTPHeaderField: "custom_header"), "test_value")
    }

    func testHPPManagerShouldContainAdditionalHeaders() {
        // Given
        let viewController = UIViewController()
        sut?.additionalHeaders = ["custom_header_1": "test_value_1",
                                  "custom_header_2": "test_value_2"]
        // When
        sut?.presentViewInViewController(viewController)
        // Then
        let request: URLRequest? = session.request
        XCTAssertNotNil(sut?.additionalHeaders)
        XCTAssertTrue((request?.allHTTPHeaderFields?.keys.contains("custom_header_1"))!)
        XCTAssertTrue((request?.allHTTPHeaderFields?.keys.contains("custom_header_2"))!)
        XCTAssertEqual(request?.value(forHTTPHeaderField: "custom_header_1"), "test_value_1")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "custom_header_2"), "test_value_2")
    }
}
