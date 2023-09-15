import Foundation

extension Encodable {
    var data: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(self)
    }
    var queryItems: [URLQueryItem]? {
        guard let data = data,
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else {
            return nil
        }
        return jsonObject.compactMap { URLQueryItem(name: $0, value: "\($1)") }
    }
}
