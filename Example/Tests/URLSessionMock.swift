//
//  URLSessionMock.swift
//  RXPiOS_Example
//
//  Copyright © 2020 realexpayments. All rights reserved.
//

import Foundation

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?
    var request: URLRequest?

    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping CompletionHandler
        )-> URLSessionDataTask {
        let data = self.data
        let error = self.error
        self.request = request

        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}
