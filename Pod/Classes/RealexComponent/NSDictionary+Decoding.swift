import Foundation

extension NSDictionary {

    /// Decoded array values in Base64
    func decodeAllValues() -> NSMutableDictionary {
        let dict = NSMutableDictionary(capacity: self.count)

        for value in self {
            if (value.value as? String) != "" {
                dict[value.key] = (value.value as? String)?.base64Decoded()
            } else {
                dict[value.key] = value.value
            }
        }

        return dict
    }
}

extension String {

    /// Encoded string in Base64
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
