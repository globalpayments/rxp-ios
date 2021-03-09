import Foundation

extension String {

    /// Percent escape value to be added to a URL query value as specified in RFC 3986.
    /// This percent-escapes all characters besize the alphanumeric character set and "-", ".", "_", and "~".
    /// - Returns: The precent escaped string
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._~")

        return self.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }

    /// Encoded string in Base64
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
