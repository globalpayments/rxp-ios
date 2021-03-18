import Foundation

struct HPPResponse: Decodable {
    let orderID: String
    let responseCode: String
    let responseMessage: String

    enum CodingKeys: String, CodingKey {
        case orderID = "orderId"
        case responseCode, responseMessage
    }
}

extension HPPResponse: CustomStringConvertible {

    var description: String {
        return "orderID: \(orderID)\nresponseCode: \(responseCode)\nresponseMessage: \(responseMessage)"
    }
}
