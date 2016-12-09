//
//  RealexRemote.swift
//  rxp-ios
//

import UIKit

class RealexRemote: NSObject {

    /**
    Validate Card Number. Returns true if card number valid. Only allows non-empty numeric values between 12 and 19 characters. A Luhn check is also run against the card number.

    - parameter cardNumber: The credit card number to be checked

    - returns: Returns true if the card number is valid
    */
    class func validateCardNumber(cardNumber: String?) -> Bool {

        if let number = cardNumber {

            // test numeric and length between 12 and 19
            let regex = "^\\d{12,19}$"
            if number.rangeOfString(regex, options: .RegularExpressionSearch) == nil {
                return false
            }

            // luhn check
            var sum = 0;
            var digit = 0;
            var addend = 0;
            var timesTwo = false;

            for (var i = (number.characters.count - 1); i >= 0; i--) {
                digit = Int(number.substringWithRange(Range<String.Index>(start: number.startIndex.advancedBy(i),
                    end: number.startIndex.advancedBy(i+1))))!

                if (timesTwo) {
                    addend = digit * 2;
                    if (addend > 9) {
                        addend -= 9;
                    }
                } else {
                    addend = digit;
                }
                sum += addend;
                timesTwo = !timesTwo;
            }

            let modulus = sum % 10;
            if (modulus != 0) {
                return false;
            }

            return true;

        }
        return false
    }

    /**
    Validate Card Holder Name. Returns true if card holder valid. Only allows non-empty ISO/IEC 8859-1 values 100 characters or less.

    - parameter cardHolderName: THe card holder's name to validate

    - returns: Returns true if the card holder's name is valid
    */
    class func validateCardHolderName(cardHolderName: String?) -> Bool {
        // test for undefined
        if let name = cardHolderName {

            // test white space only
            let trimmedString = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if trimmedString == "" {
                return false
            }

            // test ISO/IEC 8859-1 characters between 1 and 100
            let regex = "^[\\u0020-\\u007E\\u00A0-\\u00FF]{1,100}$"
            if name.rangeOfString(regex, options: .RegularExpressionSearch) == nil {
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
    class func validateAmexCvn(cvn: String?) -> Bool {
        if let cvnNumber = cvn {
            // test numeric length 4
            let regex = "^\\d{4}$"
            if cvnNumber.rangeOfString(regex, options: .RegularExpressionSearch) == nil {
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
    class func validateCvn(cvn: String?) -> Bool {
        if let cvnNumber = cvn {
            // test numeric length 3
            let regex = "^\\d{3}$"
            if cvnNumber.rangeOfString(regex, options: .RegularExpressionSearch) == nil {
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
    class func validateExpiryDateFormat(expiryDate: String?) -> Bool {
        if let date = expiryDate {
            // test numeric of length 4
            let regex = "^\\d{4}$"
            if date.rangeOfString(regex, options: .RegularExpressionSearch) == nil {
                return false
            }
            let month = Int(date.substringWithRange(Range<String.Index>(start: date.startIndex.advancedBy(0),
                end: date.startIndex.advancedBy(2))))!

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
    class func validateExpiryDateNotInPast(expiryDate: String?) -> Bool {
        if let date = expiryDate {
            // test valid format
            if self.validateExpiryDateFormat(date) == false {
                return false
            }

            let month = Int(date.substringWithRange(Range<String.Index>(start: date.startIndex.advancedBy(0),
                end: date.startIndex.advancedBy(2))))
            let year = Int(date.substringWithRange(Range<String.Index>(start: date.startIndex.advancedBy(2),
                end: date.startIndex.advancedBy(4))))

            let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: NSDate())
            let currentMonth = components.month
            let currentYear = components.year

            if (year < (currentYear % 100)) {
                return false;
            } else if (year == (currentYear % 100) && month < currentMonth) {
                return false;
            }
            return true
        }
        return false
    }

}
