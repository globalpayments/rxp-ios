//
//  String+URLString.swift
//  rxp-ios
//

import Foundation

extension String {

    /**
    Percent escape value to be added to a URL query value as specified in RFC 3986.

    This percent-escapes all characters besize the alphanumeric character set and "-", ".", "_", and "~".

    - returns: The precent escaped string
    */
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")

        return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }

}
