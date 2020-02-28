//
//  HPPManager.swift
//  rxp-ios

import UIKit

/**
 *  The delegate callbacks which allow the host app to receive all possible results form the component.
 */
@objc public protocol HPPManagerDelegate {

    @objc optional func HPPManagerCompletedWithResult(_ result: Dictionary <String, String>);
    @objc optional func HPPManagerFailedWithError(_ error: NSError?);
    @objc optional func HPPManagerCancelled();
    @objc optional func HPPManagerDismissed();
}

/**
 *  The delegate callbacks which allow the host app to receive all possible results from the component using a generic decodable type.
 */
public protocol GenericHPPManagerDelegate: class {
    
    associatedtype PaymentServiceResponse: Decodable
    func HPPManagerCompletedWithResult(_ result: PaymentServiceResponse)
    func HPPManagerFailedWithError(_ error: Error?)
    func HPPManagerCancelled()
    
}

/**
 *  A type-erased implementer of the `GenericHPPManagerDelegate` protocol
 */
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
        self.completed(result)
    }
    
    public func HPPManagerFailedWithError(_ error: Error?) {
        self.failed(error)
    }
    
    public func HPPManagerCancelled() {
        self.cancelled()
    }
    
}

// Used to handle nil errors in Result types
enum ResultOptionalError<T: Any, Failure: Error> {
    case success(T)
    case failure(Failure?)
}

/// The main object the host app creates.
/// A convenience payment manager for payment service responses that have a `[String: String]` structure
open class HPPManager: GenericHPPManager<[String: String]> { }

/// The main object the host app creates.
/// A payment manager that can decode payment service responses that have a generic structure
open class GenericHPPManager<T: Decodable>: NSObject, UIWebViewDelegate, HPPViewControllerDelegate {

    /**
     * Callback for current running data task.
     */
    typealias DataTaskCallback = ((ResultOptionalError<T, Error>) -> Void)

    /**
     * The request producer which takes the request from the component and encodes it using the shared secret stored on the server side.
     */
    open var HPPRequestProducerURL: URL!

    /**
     * The response consumer which takes the encoded response received back from HPP.
     */
    open var HPPResponseConsumerURL: URL!

    /**
     * The HPP server where the component sends the encoded request.
     */
    open var HPPURL: URL! = URL(string: "https://pay.realexpayments.com/pay")

    /**
     * The merchant ID supplied by Realex Payments – note this is not the merchant number supplied by your bank.
     */
    open var merchantId:String! = ""

    /**
     * The sub-account to use for this transaction. If not present, the default sub-account will be used.
     */
    open var account:String! = ""

    /**
     * A unique alphanumeric id that’s used to identify the transaction. No spaces are allowed.
     */
    open var orderId:String! = ""

    /**
     * Total amount to authorise in the lowest unit of the currency – i.e. 100 euro would be entered as 10000.
     * If there is no decimal in the currency (e.g. JPY Yen) then contact Realex Payments. No decimal points are allowed.
     * Amount should be set to 0 for OTB transactions (i.e. where validate card only is set to 1).
     */
    open var amount:String! = ""

    /**
     * A three-letter currency code (Eg. EUR, GBP). A list of currency codes can be provided by your account manager.
     */
    open var currency:String! = ""

    /**
     * Date and time of the transaction. Entered in the following format: YYYYMMDDHHMMSS. Must be within 24 hours of the current time.
     */
    open var timestamp:String! = ""

    /**
     * Used to signify whether or not you wish the transaction to be captured in the next batch.
     * If set to "1" and assuming the transaction is authorised then it will automatically be settled in the next batch.
     * If set to "0" then the merchant must use the RealControl application to manually settle the transaction.
     * This option can be used if a merchant wishes to delay the payment until after the goods have been shipped.
     * Transactions can be settled for up to 115% of the original amount and must be settled within a certain period of time agreed with your issuing bank.
     */
    open var autoSettleFlag:String! = ""

    /**
     * A freeform comment to describe the transaction.
     */
    open var commentOne:String! = ""

    /**
     * A freeform comment to describe the transaction.
     */
    open var commentTwo:String! = ""

    /**
     * Used to signify whether or not you want a Transaction Suitability Score for this transaction.
     * Can be "0" for no and "1" for yes.
     */
    open var returnTss:String! = ""

    /**
     * The postcode or ZIP of the shipping address.
     */
    open var shippingCode:String! = ""

    /**
     * The country of the shipping address.
     */
    open var shippingCountry:String! = ""

    /**
     * The postcode or ZIP of the billing address.
     */
    open var billingCode:String! = ""

    /**
     * The country of the billing address.
     */
    open var billingCountry:String! = ""

    /**
     * The customer number of the customer. You can send in any additional information about the transaction in this field,
     * which will be visible under the transaction in the RealControl application.
     */
    open var customerNumber:String! = ""

    /**
     * A variable reference also associated with this customer. You can send in any additional information about the transaction in this field,
     * which will be visible under the transaction in the RealControl application.
     */
    open var variableReference:String! = ""

    /**
     * A product id associated with this product. You can send in any additional information about the transaction in this field,
     * which will be visible under the transaction in the RealControl application.
     */
    open var productId:String! = ""

    /**
     * Used to set what language HPP is displayed in. Currently HPP is available in English, Spanish and German, with other languages to follow.
     * If the field is not sent in, the default language is the language that is set in your account configuration. This can be set by your account manager.
     */
    open var language:String! = ""

    /**
     * Used to set what text is displayed on the payment button for card transactions. If this field is not sent in, "Pay Now" is displayed on the button by default.
     */
    open var cardPaymentButtonText:String! = ""

    /**
     * Enable card storage.
     */
    open var cardStorageEnable:String! = ""

    /**
     * Offer to save the card.
     */
    open var offerSaveCard:String! = ""

    /**
     * The payer reference.
     */
    open var payerReference:String! = ""

    /**
     * The payment reference.
     */
    open var paymentReference:String! = ""

    /**
     * Flag to indicate if the payer exists.
     */
    open var payerExists:String! = ""

    /**
     * Used to identify an OTB transaction.
     */
    open var validateCardOnly:String! = ""

    /**
	* Used to check HppRequest base64 encoding.
	If set to true - the iOS library should decode the Base64 encoded values in the HPP request JSON

	If set to false - the iOS library should just leave the values alone
     */
    open var isEncoded:Bool! = false
	/**
	* Transaction level configuration to enable/disable a DCC request. (Only if the merchant is configured).
	*/
	open var dccEnable:String! = ""

    /**
    * CSS text to style HPP page
    */
    open var css:String?

    /**
     * Supplementary data to be sent to Realex Payments. This will be returned in the HPP response.
     */
    open var supplementaryData:Dictionary<String, String>! = [:]

    /**
     * The HPPManager's delegate to receive the result of the interaction.
     */
    open weak var delegate:HPPManagerDelegate?
    
    /**
     * The HPPManager's generic delegate to receive the result of the interaction.
     * `T` is the generic type that defines the structure of the payment response.
     */
    private var genericDelegate: AnyGenericHPPManagerDelegate<T>?
    

    /**
     * Dictionary to hold the reqeust sent to HPP.
     */
    fileprivate var HPPRequest: NSDictionary!

    /**
     * The view owned by the HPP Manager, which encapsulates the web view.
     */
    fileprivate var hppViewController: HPPViewController!

    fileprivate var currentDataTask: URLSessionDataTask?
    
    open func setGenericDelegate<D: GenericHPPManagerDelegate>(_ delegate: D) where D.PaymentServiceResponse == T {
        self.genericDelegate = AnyGenericHPPManagerDelegate(delegate)
    }

    /**
     The initialiser which when HPPManager is created, also creaes and instance of the HPPViewController.

     */
    override public init() {
        super.init()
        self.hppViewController = HPPViewController()
        self.hppViewController.delegate = self
    }

    /**
     Presents the HPPManager's view modally

     - parameter viewController: The view controller from which HPPManager will display it's view.
     */
    open func presentViewInViewController(_ viewController: UIViewController) {

        if  self.HPPRequestProducerURL.absoluteString != "" {
            self.getHPPRequest()
            let navigationController = UINavigationController(rootViewController: self.hppViewController)
            viewController.present(navigationController, animated: true, completion: nil)
        } else {
            // error
            print("HPPRequestProducerURL can't be blank")
        }
    }

    /**
     Converts a dictionay of string pairs into a html string reporesentation and encoded that as date for attaching to the request.

     - parameter json: The dictionary of paramaters and values to be encoded.

     - returns: The data encoded HTML string representation of the paramaters and values.
     */
    fileprivate func httpBodyWithJSON(_ json: NSDictionary) -> Data {

        var parameters: Dictionary<String, String>! = [:]
        for (key, value) in json {

            parameters[key as! String] = value as? String
        }
		parameters["HPP_VERSION"] = "2"
		parameters["HPP_POST_RESPONSE"] = self.HPPRequestProducerURL.scheme! + "://" + self.HPPRequestProducerURL.host!

        let parameterString = parameters.stringFromHttpParameters()
        return parameterString.data(using: String.Encoding.utf8)!;
    }

    /**
     Returns the paramaters which have been set on HPPManager as HTML string.

     - returns: The HTML string representation of the HPP paramaters which have been set.
     */
    fileprivate func getParametersString() -> String {
        var parameters: Dictionary<String, String>! = [:]

        if self.merchantId != "" {
            parameters["MERCHANT_ID"] = self.merchantId
        }
        if self.account != "" {
            parameters["ACCOUNT"] = self.account
        }
        if self.orderId != "" {
            parameters["ORDER_ID"] = self.orderId
        }
        if self.amount != "" {
            parameters["AMOUNT"] = self.amount
        }
        if self.currency != "" {
            parameters["CURRENCY"] = self.currency
        }
        if self.timestamp != "" {
            parameters["TIMESTAMP"] = self.timestamp
        }

        if self.autoSettleFlag != "" {
            parameters["AUTO_SETTLE_FLAG"] = self.autoSettleFlag
        }
        if self.commentOne != "" {
            parameters["COMMENT1"] = self.commentOne
        }
        if self.commentTwo != "" {
            parameters["COMMENT2"] = self.commentTwo
        }
        if self.returnTss != "" {
            parameters["RETURN_TSS"] = self.returnTss
        }
        if self.shippingCode != "" {
            parameters["SHIPPING_CODE"] = self.shippingCode
        }
        if self.shippingCountry != "" {
            parameters["SHIPPING_CO"] = self.shippingCountry
        }
        if self.billingCode != "" {
            parameters["BILLING_CODE"] = self.billingCode
        }
        if self.billingCountry != "" {
            parameters["BILLING_CO"] = self.billingCountry
        }
        if self.customerNumber != "" {
            parameters["CUST_NUM"] = self.customerNumber
        }
        if self.variableReference != "" {
            parameters["VAR_REF"] = self.variableReference
        }
        if self.productId != "" {
            parameters["PROD_ID"] = self.productId
        }
        if self.language != "" {
            parameters["HPP_LANG"] = self.language
        }
		if self.cardPaymentButtonText != "" {
            parameters["CARD_PAYMENT_BUTTON"] = self.cardPaymentButtonText
        }
        if self.cardStorageEnable != "" {
            parameters["CARD_STORAGE_ENABLE"] = self.cardStorageEnable
        }
        if self.offerSaveCard != "" {
            parameters["OFFER_SAVE_CARD"] = self.offerSaveCard
        }
        if self.payerReference != "" {
            parameters["PAYER_REF"] = self.payerReference
        }
        if self.paymentReference != "" {
            parameters["PMT_REF"] = self.paymentReference
        }
        if self.payerExists != "" {
            parameters["PAYER_EXIST"] = self.payerExists
        }
        if self.validateCardOnly != "" {
            parameters["VALIDATE_CARD_ONLY"] = self.validateCardOnly
        }
        if self.dccEnable != "" {
            parameters["DCC_ENABLE"] = self.dccEnable
        }


        if  self.supplementaryData != [:] {
            for (key,value) in self.supplementaryData {
                parameters.updateValue(value, forKey:key)
            }
        }

        //print("Request parameters: \n" + parameters.description)

        return parameters.stringFromHttpParameters()
    }

    /**
     Encoded whatever paramaters have been set and makes a network call to the HPP Request Producer to get the encoded request to sent to HPP.
     */
    fileprivate func getHPPRequest() {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
		let request: NSMutableURLRequest = NSMutableURLRequest(url: self.HPPRequestProducerURL, cachePolicy: cachePolicy, timeoutInterval: 30.0)

		request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.httpBody = self.getParametersString().data(using: String.Encoding.utf8)


        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            do {
                if let receivedData = data {
                    // success
                    self.HPPRequest = try JSONSerialization.jsonObject(with: receivedData, options: []) as? NSDictionary
					//	let hppMutableRequest = NSMutableDictionary.init(dictionary: self.HPPRequest)
					if (self.isEncoded == true)
					{
						self.HPPRequest = self.HPPRequest.DecodeAllValues()
					}

                    self.getPaymentForm()
                }
                else {
                    // error
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                        // Allow 0.5s for hppViewController to present, before dismissing
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self?.delegate?.HPPManagerFailedWithError!(error! as NSError)
                        self?.genericDelegate?.HPPManagerFailedWithError(error)
                        self?.hppViewController.dismiss(animated: true, completion: nil)
                    })
                }

            } catch {
                // error
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.delegate?.HPPManagerFailedWithError!(error as NSError)
                self.genericDelegate?.HPPManagerFailedWithError(error)
                self.hppViewController.dismiss(animated: true, completion: nil)
            }
        })
        dataTask.resume()
    }

    /**
     Makes a network request to HPP, passing the encoded HPP Reqeust we received from the HPP Request Producer, the responce is a HTML Payment form which is displayed in the Web View.
     */
    fileprivate func getPaymentForm() {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let request = NSMutableURLRequest(url: self.HPPURL, cachePolicy: cachePolicy, timeoutInterval: 30.0)

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        request.httpBody = self.httpBodyWithJSON(self.HPPRequest)


        //print("Request: \n" + (request.URL?.absoluteString)!)
        self.hppViewController.setCSS(css)
        self.hppViewController.loadRequest(request as URLRequest)

    }

    /**
     Makes a network request to the HPP Response Consumer passing the responce from HPP.

     - parameter hppResponse: The response from HPP which is to be decoded.
     */
    fileprivate func decodeHPPResponse(_ hppResponse: String) {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        retry(task: { [weak self] (taskCallback) in
            self?.dataTask(hppResponse, callback: taskCallback)
        }, finalCallback: { result in
            switch result {
            case .success(let decodedResponse):
                self.delegate?.HPPManagerCompletedWithResult?(decodedResponse as! Dictionary <String, String>)
                self.genericDelegate?.HPPManagerCompletedWithResult(decodedResponse)
            case .failure(let error):
                self.delegate?.HPPManagerFailedWithError!(error as NSError?)
                self.genericDelegate?.HPPManagerFailedWithError(error)
                self.hppViewController.dismiss(animated: true, completion: nil)
            }
        })

    }

    /**
     Start a data task to make a network request to the HPP Response Consumer, with a completion callback.
     */
    private func dataTask(_ hppResponse: String, callback: @escaping DataTaskCallback) {
        let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        var request = URLRequest(url: self.HPPResponseConsumerURL, cachePolicy: cachePolicy, timeoutInterval: 30.0)

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        let parameters = "hppResponse=" + hppResponse

        request.httpBody = parameters.data(using: String.Encoding.utf8)

        let session = URLSession.shared
        currentDataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if let receivedData = data, let decodedResponse = try? JSONDecoder().decode(T.self, from: receivedData) {
                callback(.success(decodedResponse))
            } else {
                callback(.failure(error))
            }
        })
        currentDataTask?.resume()
    }

    /**
     Retry mechanism for data tasks.
     */
    private func retry(times: Int = 4, delay: TimeInterval = 0.5, task: @escaping (@escaping DataTaskCallback) -> Void, finalCallback: @escaping DataTaskCallback) {
        if times <= 0 {
            return
        }
        task() { [weak self] result in
            self?.currentDataTask?.cancel()
            switch result {
            case .success(let decodedResponse):
                finalCallback(.success(decodedResponse))
                return
            case .failure(let error):
                if times <= 1 {
                    self?.currentDataTask?.cancel()
                    finalCallback(.failure(error))
                    return
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                self?.retry(times: times - 1, delay: delay, task: task, finalCallback: finalCallback)
            })
        }
    }


    //MARK: - HPPViewControllerDelegate

    /**
    The delegate callback made by the HPP View controller when the interaction with HPP completes successfully.

    - parameter hppResponse: The response the webview received from HPP.
    */
    func HPPViewControllerCompletedWithResult(_ hppResponse: String) {

        self.decodeHPPResponse(hppResponse);
    }

    /**
     The delegate callback made by the HPP View controller when the interaction with HPP fails with an error.

     - parameter error: The error which occured.
     */

    func HPPViewControllerFailedWithError(_ error: NSError?) {
        self.delegate?.HPPManagerFailedWithError!(error)
        self.genericDelegate?.HPPManagerFailedWithError(error)
        self.hppViewController.dismiss(animated: true, completion: nil)
    }

    /**
     The delegate callback made by the HPP View controller when the user cancels the payment.
     */
    func HPPViewControllerWillCancel() {
        self.delegate?.HPPManagerCancelled!()
        self.genericDelegate?.HPPManagerCancelled()
    }

    func HPPViewControllerWillDismiss() {
        self.delegate?.HPPManagerDismissed?()
    }

}
extension NSDictionary {
	//: ### Base64 encoding a string

	func DecodeAllValues() -> NSMutableDictionary
	{
		let dic: NSMutableDictionary! = NSMutableDictionary.init(capacity: self.count)
		for value in self {
			if (value.value as? String) != ""
			{
				dic[value.key] = (value.value as?String)?.base64Decoded()

			}
			else{
				dic[value.key] = value.value

			}
		}

		return dic
	}

}
extension String
{
	func base64Encoded() -> String? {
		if let data = self.data(using: .utf8) {
			return data.base64EncodedString()
		}
		return nil
	}

	//: ### Base64 decoding a string
	func base64Decoded() -> String? {
		if let data = Data(base64Encoded: self) {
			return String(data: data, encoding: .utf8)
		}
		return nil
	}
}
