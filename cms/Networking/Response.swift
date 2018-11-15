//
//  Response.swift
//  cms
//
//  Created by Andy on 14/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class Response {
    let data: Data?
    let error: String?

    init(from data: Data?, response: URLResponse?, error: Error?) {
        var errorDescription: String?

        if error != nil {
            errorDescription = error?.localizedDescription
        } else {
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    if data != nil {
                        errorDescription = String(data: data!, encoding: .utf8)
                    } else {
                        errorDescription = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    }
                }
            }
        }

        self.error = errorDescription
        self.data = self.error == nil ? data : nil
    }

    func parsed<T:Decodable>(_ type: T.Type) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try? decoder.decode(type, from: data!)
    }
}
