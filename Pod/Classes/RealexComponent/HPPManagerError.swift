import Foundation

@objcMembers public class HPPManagerError: NSError {

    public static func missingProducerURL() -> NSError {
        NSError(
            domain: "com.realex.payments",
            code: 9000,
            userInfo: [NSLocalizedDescriptionKey : "HPPRequestProducerURL can't be blank"]
        )
    }

    public static func typeMismatch() -> NSError {
        NSError(
            domain: "com.realex.payments",
            code: 9001,
            userInfo: [NSLocalizedDescriptionKey : "decodedResponse should be a [String: String]"]
        )
    }
}
