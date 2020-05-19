//
//  rxp_iosTests.swift
//  rxp-iosTests
//
//  Copyright © 2015 realexpayments. All rights reserved.
//

import XCTest
@testable import RXPiOS

class rxp_iosTests: XCTestCase {
    
    func testValidateCardNumber() {
        XCTAssertTrue(RealexRemote.validateCardNumber("424242424242424242"), "valid card")
        XCTAssertTrue(RealexRemote.validateCardNumber("4929939187355598"), "valid card")
        XCTAssertFalse(RealexRemote.validateCardNumber("a24242424242424242"), "non-numeric card")
        XCTAssertFalse(RealexRemote.validateCardNumber("4242 424242424242"), "card with spaces")
        XCTAssertFalse(RealexRemote.validateCardNumber(""), "empty card")
        XCTAssertFalse(RealexRemote.validateCardNumber(nil), "undefined card")
        XCTAssertFalse(RealexRemote.validateCardNumber("   "), "white space only")
        XCTAssertFalse(RealexRemote.validateCardNumber("42424242420"), "length < 12")
        XCTAssertFalse(RealexRemote.validateCardNumber("42424242424242424242"), "length > 19")
        XCTAssertTrue(RealexRemote.validateCardNumber("424242424242"), "length = 12")
        XCTAssertTrue(RealexRemote.validateCardNumber("4242424242424242428"), "length = 19")
        XCTAssertFalse(RealexRemote.validateCardNumber("4242424242424242427"), "luhn check")
    }
    
    func testValidateCardHolderName() {
        XCTAssertTrue(RealexRemote.validateCardHolderName("Joe Smith"), "valid name")
        XCTAssertFalse(RealexRemote.validateCardHolderName(""), "empty name")
        XCTAssertFalse(RealexRemote.validateCardHolderName(nil), "undefined name")
        XCTAssertFalse(RealexRemote.validateCardHolderName("  "), "white space only")
        XCTAssertTrue(RealexRemote.validateCardHolderName("abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghij"), "name of 100 characters")
        XCTAssertFalse(RealexRemote.validateCardHolderName("abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghija"), "name over 100 characters")
        XCTAssertTrue(RealexRemote.validateCardHolderName("!\" # $ % & \' ( ) * +  - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R"), "ISO/IEC 8859-1 characters 1")
        XCTAssertTrue(RealexRemote.validateCardHolderName("S T U V W X Y Z [ ] ^ _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~ ¡ ¢ £ ¤ ¥"), "ISO/IEC 8859-1 characters 2")
        XCTAssertTrue(RealexRemote.validateCardHolderName("¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿ À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö"), "ISO/IEC 8859-1 characters 3")
        XCTAssertTrue(RealexRemote.validateCardHolderName("× Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ"), "ISO/IEC 8859-1 characters 4")
        XCTAssertFalse(RealexRemote.validateCardHolderName("€"), "non-ISO/IEC 8859-1 characters")
    }
    
    func testValidateAmexCvn() {
        XCTAssertTrue(RealexRemote.validateAmexCvn("1234"), "valid Amex CVN")
        XCTAssertFalse(RealexRemote.validateAmexCvn(""), "empty CVN")
        XCTAssertFalse(RealexRemote.validateAmexCvn(nil), "undefined CVN")
        XCTAssertFalse(RealexRemote.validateAmexCvn("   "), "white space only")
        XCTAssertFalse(RealexRemote.validateAmexCvn("12345"), "Amex CVN of 5 numbers")
        XCTAssertFalse(RealexRemote.validateAmexCvn("123"), "Amex CVN of 3 numbers")
        XCTAssertFalse(RealexRemote.validateAmexCvn("123a"), "non-numeric Amex CVN of 4 characters")
    }
    
    func testValidateCvn() {
        XCTAssertTrue(RealexRemote.validateCvn("123"), "valid non-Amex CVN")
        XCTAssertFalse(RealexRemote.validateCvn(""), "empty CVN")
        XCTAssertFalse(RealexRemote.validateCvn(nil), "undefined CVN")
        XCTAssertFalse(RealexRemote.validateCvn("   "), "white space only")
        XCTAssertFalse(RealexRemote.validateCvn("1234"), "non-Amex CVN of 4 numbers")
        XCTAssertFalse(RealexRemote.validateCvn("12"), "non-Amex CVN of 2 numbers")
        XCTAssertFalse(RealexRemote.validateCvn("12a"), "non-numeric non-Amex CVN of 3 characters")
    }
    
    func testValidateExpiryDateFormat() {
        XCTAssertTrue(RealexRemote.validateExpiryDateFormat("1299"), "valid date 1299")
        XCTAssertTrue(RealexRemote.validateExpiryDateFormat("0199"), "valid date 0199")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat("a199"), "non-numeric date")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat("1 99"), "date with spaces")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat(""), "empty date")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat(nil), "undefined date")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat("    "), "white space only")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat("12099"), "length > 4")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat("199"), "length < 4")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat("0099"), "invalid month 00")
        XCTAssertFalse(RealexRemote.validateExpiryDateFormat("1399"), "invalid month 13")
    }
    
    func testValidateExpiryDateNotInPast() {
        XCTAssertFalse(RealexRemote.validateExpiryDateNotInPast(nil), "undefined date")
        XCTAssertFalse(RealexRemote.validateExpiryDateNotInPast("0615"), "date in past")
        
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month], from: currentDate)
        var nowMonth = String(describing: components.month!)
        nowMonth = nowMonth.count < 2 ? "0" + nowMonth : nowMonth
        let year = String(describing: components.year!)
        let nowYear = String(year[year.index(year.startIndex, offsetBy: 2)...])
        let nowDate = nowMonth + nowYear
        
        XCTAssertTrue(RealexRemote.validateExpiryDateNotInPast(nowDate), "current month")
    }
}
