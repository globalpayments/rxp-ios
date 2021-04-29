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
