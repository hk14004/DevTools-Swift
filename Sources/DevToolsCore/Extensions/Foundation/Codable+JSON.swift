//
//  Codable+JSON.swift
//

import Foundation

// MARK: - Encoding

public extension Encodable {

    /// Encodes the value to JSON `Data`.
    ///
    /// Returns `nil` if encoding fails. Pass a configured encoder to control
    /// key strategy, date format, etc.
    ///
    /// ```swift
    /// let data = user.toJSONData()
    /// let data = user.toJSONData(encoder: .snakeCaseEncoder)
    /// ```
    func toJSONData(encoder: JSONEncoder = JSONEncoder()) -> Data? {
        try? encoder.encode(self)
    }

    /// Encodes the value to a JSON string.
    ///
    /// ```swift
    /// print(user.toJSONString() ?? "encoding failed")
    /// analytics.track(event.toJSONString())
    /// ```
    func toJSONString(encoder: JSONEncoder = JSONEncoder()) -> String? {
        toJSONData(encoder: encoder).flatMap { String(data: $0, encoding: .utf8) }
    }

    /// Encodes the value to a `[String: Any]` dictionary.
    ///
    /// Useful for analytics SDKs, Firebase, and other APIs that accept
    /// raw dictionaries instead of typed models.
    ///
    /// ```swift
    /// Analytics.log(event: purchaseEvent.toDictionary() ?? [:])
    /// ```
    func toDictionary(encoder: JSONEncoder = JSONEncoder()) -> [String: Any]? {
        guard let data = toJSONData(encoder: encoder) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

// MARK: - Decoding

public extension Decodable {

    /// Decodes an instance from JSON `Data`.
    ///
    /// ```swift
    /// let user = try User.decode(from: responseData)
    /// let user = try User.decode(from: data, decoder: .snakeCaseDecoder)
    /// ```
    static func decode(
        from data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self {
        try decoder.decode(Self.self, from: data)
    }

    /// Decodes an instance from a JSON string.
    ///
    /// ```swift
    /// let user = try User.decode(fromJSONString: cachedString)
    /// ```
    static func decode(
        fromJSONString string: String,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self {
        guard let data = string.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "String could not be encoded as UTF-8.")
            )
        }
        return try decode(from: data, decoder: decoder)
    }
}
