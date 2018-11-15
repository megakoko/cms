//
//  NetworkManager.swift
//  cms
//
//  Created by Andy on 14/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class NetworkManager {
    private static var shared = NetworkManager()

    private init() {
    }

    @discardableResult
    static func request(_ request: Request, handler: @escaping (Response?) -> Void) -> URLSessionDataTask? {
        return shared.request(request, handler: handler)
    }

    @discardableResult
    private func request(_ request: Request, handler: @escaping (Response?) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = request.urlRequest else {
            handler(nil)
            return nil
        }

        let dataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, urlResponse, error in

            let response = Response(from: data, response: urlResponse, error: error)

            handler(response)
        }

        dataTask.resume()

        return dataTask
    }
}
