import UIKit

private enum RegexRules: String {
    case cardNumber = "^\\d{12,19}$"
    case cardHolderName = "^[\\u0020-\\u007E\\u00A0-\\u00FF]{1,100}$"
    case threeDigits = "^\\d{3}$"
    case fourDigits = "^\\d{4}$"

    func validate(_ input: String?) -> Bool {
        guard let input = input else { return false }
        return input.range(of: self.rawValue, options: .regularExpression) != nil
    }
}

class RealexRemote: NSObject {

    /// Validate Card Number. Returns true if card number valid. Only allows non-empty numeric values between 12 and 19 characters. A Luhn check is also run against the card number.
    /// - Parameter cardNumber: The credit card number to be checked
    /// - Returns: Returns true if the card number is valid
    class func validateCardNumber(_ cardNumber: String?) -> Bool {
        guard let number = cardNumber else { return false }
        guard RegexRules.cardNumber.validate(number) else { return false }

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

    /// Validate Card Holder Name. Only allows non-empty ISO/IEC 8859-1 values 100 characters or less.
    /// - Parameter cardHolderName: The card holder's name to validate
    /// - Returns: Returns true if the card holder's name is valid
    class func validateCardHolderName(_ cardHolderName: String?) -> Bool {
        guard let name = cardHolderName else { return false }
        guard name.trimmingCharacters(in: CharacterSet.whitespaces) != "" else { return false }

        return RegexRules.cardHolderName.validate(name)
    }

    /// Validate Amex CVN. Applies to Amex card types. Only allows 4 numeric characters.
    /// - Parameter cvn: the Amex CVN to validate
    /// - Returns: Returns true if the Amex CVN is valid
    class func validateAmexCvn(_ cvn: String?) -> Bool {
        guard let cvnNumber = cvn else { return false }

        return RegexRules.fourDigits.validate(cvnNumber)
    }

    /// Validate CVN. Applies to non-Amex card types. Only allows 3 numeric characters.
    /// - Parameter cvn: the CVN to validate
    /// - Returns: Returns true if the CVN is valid
    class func validateCvn(_ cvn: String?) -> Bool {
        guard let cvnNumber = cvn else { return false }

        return RegexRules.threeDigits.validate(cvnNumber)
    }

    /// Validate Expiry Date Format. Only allows 4 numeric characters. Month must be between 1 and 12.
    /// - Parameter expiryDate: The card expiry date to validate
    /// - Returns: Returns true if the expiry date is valid
    class func validateExpiryDateFormat(_ expiryDate: String?) -> Bool {
        guard let date = expiryDate else { return false }
        guard RegexRules.fourDigits.validate(date) else { return false }
        guard let month = Int.month(from: date) else { return false }

        return 1...12 ~= month
    }

    /// Validate Expiry Date Not In Past. Also runs checks from validateExpiryDateFormat.
    /// - Parameter expiryDate: The card expiry date to validate
    /// - Returns: Returns true if the expiry date is not in the past
    class func validateExpiryDateNotInPast(_ expiryDate: String?) -> Bool {
        guard let date = expiryDate else { return false }
        guard validateExpiryDateFormat(date) else { return false }
        guard let month = Int.month(from: date) else { return false }
        guard let year = Int.year(from: date) else { return false }

        let components = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month], from: Date())
        guard let currentMonth = components.month else { return false }
        guard let currentYear = components.year else { return false }

        if (year < (currentYear % 100)) {
            return false
        } else if (year == (currentYear % 100) && month < currentMonth) {
            return false
        }
        return true
    }
}

private extension Int {

    static func month(from date: String) -> Int? {
        return Int(date[date.index(date.startIndex, offsetBy: 0) ..< date.index(date.startIndex, offsetBy: 2)])
    }

    static func year(from date: String) -> Int? {
        return Int(date[date.index(date.startIndex, offsetBy: 2) ..< date.index(date.startIndex, offsetBy: 4)])
    }
}
