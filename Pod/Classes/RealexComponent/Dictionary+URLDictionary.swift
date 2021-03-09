import Foundation

extension Dictionary where Key == String, Value == String {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects.
    /// This percent escapes in compliance with RFC 3986
    /// - Returns: The string representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = key.stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = value.stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
}
