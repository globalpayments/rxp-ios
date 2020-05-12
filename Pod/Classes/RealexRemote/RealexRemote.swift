//
//  RealexRemote.swift
//  rxp-ios
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class RealexRemote: NSObject {

    /**
    Validate Card Number. Returns true if card number valid. Only allows non-empty numeric values between 12 and 19 characters. A Luhn check is also run against the card number.

    - parameter cardNumber: The credit card number to be checked

    - returns: Returns true if the card number is valid
    */
    class func validateCardNumber(_ cardNumber: String?) -> Bool {
        guard let number = cardNumber else { return false }

        // test numeric and length between 12 and 19
        let regex = "^\\d{12,19}$"
        if number.range(of: regex, options: .regularExpression) == nil {
            return false
        }

        // luhn check
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            }
        }

        return sum % 10 == 0
    }

    /**
    Validate Card Holder Name. Returns true if card holder valid. Only allows non-empty ISO/IEC 8859-1 values 100 characters or less.

    - parameter cardHolderName: THe card holder's name to validate

    - returns: Returns true if the card holder's name is valid
    */
    class func validateCardHolderName(_ cardHolderName: String?) -> Bool {
        // test for undefined
        if let name = cardHolderName {

            // test white space only
            let trimmedString = name.trimmingCharacters(in: CharacterSet.whitespaces)
            if trimmedString == "" {
                return false
            }

            // test ISO/IEC 8859-1 characters between 1 and 100
            let regex = "^[\\u0020-\\u007E\\u00A0-\\u00FF]{1,100}$"
            if name.range(of: regex, options: .regularExpression) == nil {
                return false
            }

            return true

        }
        return false
    }

    /**
    Validate Amex CVN. Applies to Amex card types. Only allows 4 numeric characters.

    - parameter cvn: the Amex CVN to validate

    - returns: Returns true if the Amex CVN is valid
    */
    class func validateAmexCvn(_ cvn: String?) -> Bool {
        if let cvnNumber = cvn {
            // test numeric length 4
            let regex = "^\\d{4}$"
            if cvnNumber.range(of: regex, options: .regularExpression) == nil {
                return false
            }
            return true
        }
        return false
    }


    /**
    Validate CVN. Applies to non-Amex card types. Only allows 3 numeric characters.

    - parameter cvn: the CVN to validate

    - returns: Returns true if the CVN is valid
    */
    class func validateCvn(_ cvn: String?) -> Bool {
        if let cvnNumber = cvn {
            // test numeric length 3
            let regex = "^\\d{3}$"
            if cvnNumber.range(of: regex, options: .regularExpression) == nil {
                return false
            }
            return true
        }
        return false
    }

    /**
    Validate Expiry Date Format. Only allows 4 numeric characters. Month must be between 1 and 12.

    - parameter expiryDate: The card expiry date to validate

    - returns: Returns true if the expiry date is valid
    */
    class func validateExpiryDateFormat(_ expiryDate: String?) -> Bool {
        if let date = expiryDate {
            // test numeric of length 4
            let regex = "^\\d{4}$"
            if date.range(of: regex, options: .regularExpression) == nil {
                return false
            }
            let month = Int(date[date.index(date.startIndex, offsetBy: 0) ..< date.index(date.startIndex, offsetBy: 2)])!

            // test month range is 1-12
            if (month < 1 || month > 12) {
                return false;
            }
            return true
        }
        return false
    }

    /**
    Validate Expiry Date Not In Past. Also runs checks from validateExpiryDateFormat.

    - parameter expiryDate: The card expiry date to validate

    - returns: Returns true if the expiry date is not in the past
    */
    class func validateExpiryDateNotInPast(_ expiryDate: String?) -> Bool {
        if let date = expiryDate {
            // test valid format
            if self.validateExpiryDateFormat(date) == false {
                return false
            }

            let month = Int(date[date.index(date.startIndex, offsetBy: 0) ..< date.index(date.startIndex, offsetBy: 2)])
            let year = Int(date[date.index(date.startIndex, offsetBy: 2) ..< date.index(date.startIndex, offsetBy: 4)])

            let components = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month], from: Date())
            let currentMonth = components.month
            let currentYear = components.year

            if (year! < (currentYear! % 100)) {
                return false;
            } else if (year! == (currentYear! % 100) && month! < currentMonth!) {
                return false;
            }
            return true
        }
        return false
    }

}
