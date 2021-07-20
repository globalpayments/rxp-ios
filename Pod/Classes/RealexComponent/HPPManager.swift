import UIKit

/// The delegate callbacks which allow the host app to receive all possible results form the component.
@objc public protocol HPPManagerDelegate: class {
    @objc func HPPManagerCompletedWithResult(_ result: [String: Any])
    @objc func HPPManagerFailedWithError(_ error: Error?)
    @objc func HPPManagerCancelled()
}

/// The delegate callbacks which allow the host app to receive all possible results from the component using a generic decodable type.
public protocol GenericHPPManagerDelegate: class {
    associatedtype PaymentServiceResponse: Decodable

    func HPPManagerCompletedWithResult(_ result: PaymentServiceResponse)
    func HPPManagerFailedWithError(_ error: Error?)
    func HPPManagerCancelled()
}

/// A type-erased implementer of the `GenericHPPManagerDelegate` protocol
fileprivate class AnyGenericHPPManagerDelegate<T: Decodable>: GenericHPPManagerDelegate {
    
    private let completed: (T) -> Void
    private let failed: (Error?) -> Void
    private let cancelled: () -> Void
    
    init<D: GenericHPPManagerDelegate>(_ delegate: D) where D.PaymentServiceResponse == T {
        self.completed = { [weak delegate] in delegate?.HPPManagerCompletedWithResult($0) }
        self.failed = { [weak delegate] in delegate?.HPPManagerFailedWithError($0) }
        self.cancelled = { [weak delegate] in delegate?.HPPManagerCancelled() }
    }
    
    public func HPPManagerCompletedWithResult(_ result: T) {
        completed(result)
    }
    
    public func HPPManagerFailedWithError(_ error: Error?) {
        failed(error)
    }
    
    public func HPPManagerCancelled() {
        cancelled()
    }
}

/// The main object the host app creates.
/// A convenience payment manager for payment service responses that have a `[String: String]` structure
public class HPPManager: GenericHPPManager<[String: String?]> { }

/// The main object the host app creates.
/// A payment manager that can decode payment service responses that have a generic structure
public class GenericHPPManager<T: Decodable>: NSObject, HPPViewControllerDelegate {

    /// The request producer which takes the request from the component and encodes it using the shared secret stored on the server side.
    @objc public var HPPRequestProducerURL: URL!

    /// The response consumer which takes the encoded response received back from HPP.
    @objc public var HPPResponseConsumerURL: URL!

    /// The HPP server where the component sends the encoded request.
    @objc public var HPPURL: URL! = URL(string: "https://pay.realexpayments.com/pay")

    /// The merchant ID supplied by Realex Payments – note this is not the merchant number supplied by your bank.
    @objc public var merchantId: String = ""

    /// The sub-account to use for this transaction. If not present, the default sub-account will be used.
    @objc public var account: String = ""

    /// A unique alphanumeric id that’s used to identify the transaction. No spaces are allowed.
    @objc public var orderId: String = ""

    /// Total amount to authorise in the lowest unit of the currency – i.e. 100 euro would be entered as 10000.
    /// If there is no decimal in the currency (e.g. JPY Yen) then contact Realex Payments. No decimal points are allowed.
    /// Amount should be set to 0 for OTB transactions (i.e. where validate card only is set to 1).
    @objc public var amount: String = ""

    /// A three-letter currency code (Eg. EUR, GBP). A list of currency codes can be provided by your account manager.
    @objc public var currency: String = ""

    /// Date and time of the transaction. Entered in the following format: YYYYMMDDHHMMSS. Must be within 24 hours of the current time.
    @objc public var timestamp: String = ""

    /// Used to signify whether or not you wish the transaction to be captured in the next batch.
    /// - If set to "1" and assuming the transaction is authorised then it will automatically be settled in the next batch.
    /// - If set to "0" then the merchant must use the RealControl application to manually settle the transaction.
    ///
    /// This option can be used if a merchant wishes to delay the payment until after the goods have been shipped.
    /// Transactions can be settled for up to 115% of the original amount and must be settled within a certain period of time agreed with your issuing bank.
    @objc public var autoSettleFlag: String = ""

    /// A freeform comment to describe the transaction.
    @objc public var commentOne: String = ""

    /// A freeform comment to describe the transaction.
    @objc public var commentTwo: String = ""

    /// Used to signify whether or not you want a Transaction Suitability Score for this transaction.
    /// Can be "0" for no and "1" for yes.
    @objc public var returnTss: String = ""

    /// The postcode or ZIP of the shipping address.
    @objc public var shippingCode: String = ""

    /// The country of the shipping address.
    @objc public var shippingCountry: String = ""

    /// The postcode or ZIP of the billing address.
    @objc public var billingCode: String = ""

    /// The country of the billing address.
    @objc public var billingCountry: String = ""

    /// The customer number of the customer. You can send in any additional information about the transaction in this field,
    /// which will be visible under the transaction in the RealControl application.
    @objc public var customerNumber: String = ""

    /// A variable reference also associated with this customer. You can send in any additional information about the transaction in this field,
    /// which will be visible under the transaction in the RealControl application.
    @objc public var variableReference: String = ""

    /// A product id associated with this product. You can send in any additional information about the transaction in this field,
    /// which will be visible under the transaction in the RealControl application.
    @objc public var productId: String = ""

    /// Used to set what language HPP is displayed in. Currently HPP is available in English, Spanish and German, with other languages to follow.
    /// If the field is not sent in, the default language is the language that is set in your account configuration. This can be set by your account manager.
    @objc public var language: String = ""

    /// Used to set what text is displayed on the payment button for card transactions. If this field is not sent in, "Pay Now" is displayed on the button by default.
    @objc public var cardPaymentButtonText: String = ""

    /// Enable card storage.
    @objc public var cardStorageEnable: String = ""

    /// Offer to save the card.
    @objc public var offerSaveCard: String = ""

    /// The payer reference.
    @objc public var payerReference: String = ""

    /// The payment reference.
    @objc public var paymentReference: String = ""

    /// Flag to indicate if the payer exists.
    @objc public var payerExists: String = ""

    /// Used to identify an OTB transaction.
    @objc public var validateCardOnly: String = ""

    /// Used to check HppRequest base64 encoding.
    /// - If set to true - the iOS library should decode the Base64 encoded values in the HPP request JSON
    /// - If set to false - the iOS library should just leave the values alone
    @objc public var isEncoded: Bool = false

    /// Transaction level configuration to enable/disable a DCC request. (Only if the merchant is configured).
    @objc public var dccEnable: String = ""

    /// Supplementary data to be sent to Realex Payments. This will be returned in the HPP response.
    @objc public var supplementaryData = [String: String]()

    /// Used to add additional headers and attach them to request
    @objc public var additionalHeaders: [String: String]?

    /// The HPPManager's delegate to receive the result of the interaction.
    @objc public weak var delegate: HPPManagerDelegate?
    
    /// The HPPManager's generic sdelegate to receive the result of the interaction.
    /// `T` is the generic type that defines the structure of the payment response.
    private var genericDelegate: AnyGenericHPPManagerDelegate<T>?

    /// Dictionary to hold the reqeust sent to HPP.
    fileprivate var HPPRequest: NSDictionary!

    /// The view owned by the HPP Manager, which encapsulates the web view.
    fileprivate var hppViewController: HPPViewController!
    
    public func setGenericDelegate<D: GenericHPPManagerDelegate>(_ delegate: D) where D.PaymentServiceResponse == T {
        self.genericDelegate = AnyGenericHPPManagerDelegate(delegate)
    }

    private let session: URLSession

    /// The initialiser which when HPPManager is created, also creaes and instance of the HPPViewController.
    /// - Parameter session: URLSession instance
    @objc public init(session: URLSession = .shared) {
        self.session = session
        super.init()
        self.hppViewController = HPPViewController()
        self.hppViewController.delegate = self
    }

    /// Presents the HPPManager's view modally
    /// - Parameter viewController: The view controller from which HPPManager will display it's view.
    @objc public func presentViewInViewController(_ viewController: UIViewController) {
        guard let producerURL = HPPRequestProducerURL, !producerURL.absoluteString.isEmpty else {
            let error = HPPManagerError.missingProducerURL()
            self.delegate?.HPPManagerFailedWithError(error)
            self.genericDelegate?.HPPManagerFailedWithError(error)
            return
        }
        getHPPRequest()
        let navigationController = UINavigationController(rootViewController: self.hppViewController)
        navigationController.modalPresentationStyle = .fullScreen
        viewController.present(navigationController, animated: true, completion: nil)
    }

    /// Converts a dictionay of string pairs into a html string reporesentation and encoded that as date for attaching to the request.
    /// - Parameter json: The dictionary of paramaters and values to be encoded.
    /// - Returns: The data encoded HTML string representation of the paramaters and values.
    private func httpBodyWithJSON(_ json: NSDictionary) -> Data {

        var parameters = [String: String]()
        for (key, value) in json {
            if let key = key as? String, let value = value as? String {
                parameters[key] = value
            }
        }
        parameters["HPP_VERSION"] = "2"
        parameters["HPP_POST_RESPONSE"] = self.HPPRequestProducerURL.scheme! + "://" + self.HPPRequestProducerURL.host!

        let parameterString = parameters.stringFromHttpParameters()
        return parameterString.data(using: String.Encoding.utf8)!
    }

    /// Returns the paramaters which have been set on HPPManager as HTML string.
    /// - Returns: The HTML string representation of the HPP paramaters which have been set.
    private func getParametersString() -> String {
        var parameters = [String: String]()
        parameters["MERCHANT_ID"] = self.merchantId
        parameters["ACCOUNT"] = self.account
        parameters["ORDER_ID"] = self.orderId
        parameters["AMOUNT"] = self.amount
        parameters["CURRENCY"] = self.currency
        parameters["TIMESTAMP"] = self.timestamp
        parameters["AUTO_SETTLE_FLAG"] = self.autoSettleFlag
        parameters["COMMENT1"] = self.commentOne
        parameters["COMMENT2"] = self.commentTwo
        parameters["RETURN_TSS"] = self.returnTss
        parameters["SHIPPING_CODE"] = self.shippingCode
        parameters["SHIPPING_CO"] = self.shippingCountry
        parameters["BILLING_CODE"] = self.billingCode
        parameters["BILLING_CO"] = self.billingCountry
        parameters["CUST_NUM"] = self.customerNumber
        parameters["VAR_REF"] = self.variableReference
        parameters["PROD_ID"] = self.productId
        parameters["HPP_LANG"] = self.language
        parameters["CARD_PAYMENT_BUTTON"] = self.cardPaymentButtonText
        parameters["CARD_STORAGE_ENABLE"] = self.cardStorageEnable
        parameters["OFFER_SAVE_CARD"] = self.offerSaveCard
        parameters["PAYER_REF"] = self.payerReference
        parameters["PMT_REF"] = self.paymentReference
        parameters["PAYER_EXIST"] = self.payerExists
        parameters["VALIDATE_CARD_ONLY"] = self.validateCardOnly
        parameters["DCC_ENABLE"] = self.dccEnable

        if self.supplementaryData != [:] {
            for (key,value) in self.supplementaryData {
                parameters.updateValue(value, forKey:key)
            }
        }

        return parameters
            .filter { !$0.value.isEmpty }
            .stringFromHttpParameters()
    }

    /// Encoded whatever paramaters have been set and makes a network call to the HPP Request Producer to get the encoded request to sent to HPP.
    fileprivate func getHPPRequest() {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var request = URLRequest(url: self.HPPRequestProducerURL,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 30.0)

        request.httpMethod = "POST"
        request.setValue(HPPHeader.Value.xWWWFormUrlEncoded, forHTTPHeaderField: HPPHeader.Field.contentType)
        request.setValue(HPPHeader.Value.all, forHTTPHeaderField: HPPHeader.Field.accept)
        if let additionalHeaders = additionalHeaders {
            additionalHeaders.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
        request.httpBody = getParametersString().data(using: String.Encoding.utf8)

        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in

            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                do {
                    if let receivedData = data {
                        self.HPPRequest = try JSONSerialization.jsonObject(with: receivedData, options: []) as? NSDictionary
                        if (self.isEncoded == true) {
                            self.HPPRequest = self.HPPRequest.decodeAllValues()
                        }
                        self.getPaymentForm()
                    } else {
                        self.HPPViewControllerFailedWithError(error)
                    }
                } catch {
                    self.HPPViewControllerFailedWithError(error)
                }
            }
        })
        dataTask.resume()
    }

    /// Makes a network request to HPP, passing the encoded HPP Reqeust we received from the HPP Request Producer, the responce is a HTML Payment form which is displayed in the Web View.
    fileprivate func getPaymentForm() {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var request = URLRequest(url: self.HPPURL,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 30.0)

        request.httpMethod = "POST"
        request.httpBody = httpBodyWithJSON(self.HPPRequest)
        request.setValue(HPPHeader.Value.xWWWFormUrlEncoded, forHTTPHeaderField: HPPHeader.Field.contentType)
        request.setValue(HPPHeader.Value.text, forHTTPHeaderField: HPPHeader.Field.accept)
        if let additionalHeaders = additionalHeaders {
            additionalHeaders.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }

        hppViewController.loadRequest(request)
    }

    /// Makes a network request to the HPP Response Consumer passing the responce from HPP.
    /// - Parameter hppResponse: The response from HPP which is to be decoded.
    private func decodeHPPResponse(_ hppResponse: String) {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var request = URLRequest(url: self.HPPResponseConsumerURL,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 30.0)

        request.httpMethod = "POST"
        request.setValue(HPPHeader.Value.xWWWFormUrlEncoded, forHTTPHeaderField: HPPHeader.Field.contentType)
        request.setValue(HPPHeader.Value.all, forHTTPHeaderField: HPPHeader.Field.accept)
        if let additionalHeaders = additionalHeaders {
            additionalHeaders.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
        let body = ["hppResponse": hppResponse]
        request.httpBody = body.stringFromHttpParameters().data(using: String.Encoding.utf8)

        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in

            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                do {
                    if let receivedData = data {
                        if var jsonData = try JSONSerialization.jsonObject(with: receivedData, options: []) as? [String: Any]{
                            switch jsonData["response"] {
                            case is String, nil:
                                self.decodeDataOnCompleted(receivedData)
                                break
                            case let response as [String:String]:
                                jsonData["responseCode"] = response["code"]
                                jsonData["responseMessage"] = response["message"]
                                jsonData["response"] = nil
                                self.decodeDataOnCompleted(jsonData: jsonData as? [String:String])
                                break
                            default:
                                let error = HPPManagerError.typeMismatch()
                                self.HPPViewControllerFailedWithError(error)
                                break
                            }
                        }else{
                            self.decodeDataOnCompleted(receivedData)
                        }
                    } else {
                        self.HPPViewControllerFailedWithError(error)
                    }
                } catch {
                    self.HPPViewControllerFailedWithError(error)
                }
            }
        })
        dataTask.resume()
    }
    
    private func decodeDataOnCompleted(_ receivedData: Data? = nil, jsonData: [String: String]? = nil ){
        do {
            if let data = receivedData {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                if let genericDelegate = self.genericDelegate {
                    genericDelegate.HPPManagerCompletedWithResult(decodedResponse)
                    return
                }
                guard let dictResponse = decodedResponse as? [String: Any] else {
                    let error = HPPManagerError.typeMismatch()
                    self.HPPViewControllerFailedWithError(error)
                    return
                }
                self.delegate?.HPPManagerCompletedWithResult(dictResponse)
            }
            
            if let data = jsonData{
                self.delegate?.HPPManagerCompletedWithResult(data)
                print(data)
            }
            
        } catch {
            self.HPPViewControllerFailedWithError(error)
        }
    }

    // MARK: - HPPViewControllerDelegate

    /// The delegate callback made by the HPP View controller when the interaction with HPP completes successfully.
    /// - Parameter hppResponse: The response the webview received from HPP.
    func HPPViewControllerCompletedWithResult(_ hppResponse: String) {
        decodeHPPResponse(hppResponse)
    }

    /// The delegate callback made by the HPP View controller when the interaction with HPP fails with an error.
    /// - Parameter error: The error which occured.
    func HPPViewControllerFailedWithError(_ error: Error?) {
        delegate?.HPPManagerFailedWithError(error)
        genericDelegate?.HPPManagerFailedWithError(error)
        hppViewController.dismiss(animated: true, completion: nil)
    }

    /// The delegate callback made by the HPP View controller when the user cancels the payment.
    func HPPViewControllerWillDismiss() {
        delegate?.HPPManagerCancelled()
        genericDelegate?.HPPManagerCancelled()
    }
}

private struct HPPHeader {

    struct Field {
        static let contentType = "Content-Type"
        static let accept = "Accept"
    }

    struct Value {
        static let xWWWFormUrlEncoded = "application/x-www-form-urlencoded"
        static let text = "text/html"
        static let all = "*/*"
    }
}
