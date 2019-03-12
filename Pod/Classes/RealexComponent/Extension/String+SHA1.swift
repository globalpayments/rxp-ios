//
//  String+SHA1.swift
//  rxp-ios

import Foundation
import CommonCrypto

extension String {

	var sha1: String? {
		guard let data = self.data(using: String.Encoding.utf8) else { return nil }

		let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
			var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
			CC_SHA1(bytes, CC_LONG(data.count), &hash)
			return hash
		}

		return hash.map { String(format: "%02x", $0) }.joined()
	}
}
