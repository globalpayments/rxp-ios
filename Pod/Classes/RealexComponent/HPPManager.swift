//
//  HPPManager.swift
//  rxp-ios
//
//  Copyright (c) 2015 Realex Payments. All rights reserved.
//

import UIKit

/**
 *  The delegate callbacks which allow the host app to receive all possible results form the component.
 */
@objc public protocol HPPManagerDelegate {
    
    optional func HPPManagerCompletedWithResult(result: Dictionary <String, String>);
    optional func HPPManagerFailedWithError(error: NSError?);
    optional func HPPManagerCancelled();
    
}

/// The main object the host app creates.
public class HPPManager: NSObject, UIWebViewDelegate, HPPViewControllerDelegate {
    
    
    /**
     * The request producer which takes the request from the component and encodes it using the shared secret stored on the server side.
     */
    public var HPPRequestProducerURL: NSURL!
    
    /**
     * The response consumer which takes the encoded response received back from HPP.
     */
    public var HPPResponseConsumerURL: NSURL!
    
    /**
     * The HPP server where the component sends the encoded request.
     */
    public var HPPURL: NSURL! = NSURL(string: "https://hpp.realexpayments.com/pay")
    
    /**
     * The merchant ID supplied by Realex Payments – note this is not the merchant number supplied by your bank.
     */
    public var merchantId:String! = ""
    
    /**
     * The sub-account to use for this transaction. If not present, the default sub-account will be used.
     */
    public var account:String! = ""
    
    /**
     * A unique alphanumeric id that’s used to identify the transaction. No spaces are allowed.
     */
    public var orderId:String! = ""
    
    /**
     * Total amount to authorise in the lowest unit of the currency – i.e. 100 euro would be entered as 10000.
     * If there is no decimal in the currency (e.g. JPY Yen) then contact Realex Payments. No decimal points are allowed.
     * Amount should be set to 0 for OTB transactions (i.e. where validate card only is set to 1).
     */
    public var amount:String! = ""
    
    /**
     * A three-letter currency code (Eg. EUR, GBP). A list of currency codes can be provided by your account manager.
     */
    public var currency:String! = ""
    
    /**
     * Date and time of the transaction. Entered in the following format: YYYYMMDDHHMMSS. Must be within 24 hours of the current time.
     */
    public var timestamp:String! = ""
    
    /**
     * Used to signify whether or not you wish the transaction to be captured in the next batch.
     * If set to "1" and assuming the transaction is authorised then it will automatically be settled in the next batch.
     * If set to "0" then the merchant must use the RealControl application to manually settle the transaction.
     * This option can be used if a merchant wishes to delay the payment until after the goods have been shipped.
     * Transactions can be settled for up to 115% of the original amount and must be settled within a certain period of time agreed with your issuing bank.
     */
    public var autoSettleFlag:String! = ""
    
    /**
     * A freeform comment to describe the transaction.
     */
    public var commentOne:String! = ""
    
    /**
     * A freeform comment to describe the transaction.
     */
    public var commentTwo:String! = ""
    
    /**
     * Used to signify whether or not you want a Transaction Suitability Score for this transaction.
     * Can be "0" for no and "1" for yes.
     */
    public var returnTss:String! = ""
    
    /**
     * The postcode or ZIP of the shipping address.
     */
    public var shippingCode:String! = ""
    
    /**
     * The country of the shipping address.
     */
    public var shippingCountry:String! = ""
    
    /**
     * The postcode or ZIP of the billing address.
     */
    public var billingCode:String! = ""
    
    /**
     * The country of the billing address.
     */
    public var billingCountry:String! = ""
    
    /**
     * The customer number of the customer. You can send in any additional information about the transaction in this field,
     * which will be visible under the transaction in the RealControl application.
     */
    public var customerNumber:String! = ""
    
    /**
     * A variable reference also associated with this customer. You can send in any additional information about the transaction in this field,
     * which will be visible under the transaction in the RealControl application.
     */
    public var variableReference:String! = ""
    
    /**
     * A product id associated with this product. You can send in any additional information about the transaction in this field,
     * which will be visible under the transaction in the RealControl application.
     */
    public var productId:String! = ""
    
    /**
     * Used to set what language HPP is displayed in. Currently HPP is available in English, Spanish and German, with other languages to follow.
     * If the field is not sent in, the default language is the language that is set in your account configuration. This can be set by your account manager.
     */
    public var language:String! = ""
    
    /**
     * Used to set what text is displayed on the payment button for card transactions. If this field is not sent in, "Pay Now" is displayed on the button by default.
     */
    public var cardPaymentButtonText:String! = ""
    
    /**
     * Enable card storage.
     */
    public var cardStorageEnable:String! = ""
    
    /**
     * Offer to save the card.
     */
    public var offerSaveCard:String! = ""
    
    /**
     * The payer reference.
     */
    public var payerReference:String! = ""
    
    /**
     * The payment reference.
     */
    public var paymentReference:String! = ""
    
    /**
     * Flag to indicate if the payer exists.
     */
    public var payerExists:String! = ""
    
    /**
     * Used to identify an OTB transaction.
     */
    public var validateCardOnly:String! = ""
    
    /**
     * Transaction level configuration to enable/disable a DCC request. (Only if the merchant is configured).
     */
    public var dccEnable:String! = ""
    
    /**
     * Supplementary data to be sent to Realex Payments. This will be returned in the HPP response.
     */
    public var supplementaryData:Dictionary<String, String>! = [:]
    
    /**
     * The HPPManager's delegate to receive the result of the interaction.
     */
    public var delegate:HPPManagerDelegate?
    
    /**
     * Dictionary to hold the reqeust sent to HPP.
     */
    private var HPPRequest: NSDictionary!
    
    /**
     * The view owned by the HPP Manager, which encapsulates the web view.
     */
    private var hppViewController: HPPViewController!
    
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
    public func presentViewInViewController(viewController: UIViewController) {
        
        if  self.HPPRequestProducerURL.absoluteString != "" {
            self.getHPPRequest()
            let navigationController = UINavigationController(rootViewController: self.hppViewController)
            viewController.presentViewController(navigationController, animated: true, completion: nil)
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
    private func httpBodyWithJSON(json: NSDictionary) -> NSData {
        var parameters: Dictionary<String, String>! = [:]
        for (key, value) in json {
            
            parameters[key as! String] = value as? String
        }
        
        parameters["HPP_TEMPLATE_TYPE"] = "LIGHTBOX"
        parameters["HPP_ORIGIN"] = self.HPPRequestProducerURL.scheme + "://" + self.HPPRequestProducerURL.host!
        
        let parameterString = parameters.stringFromHttpParameters()
        return parameterString.dataUsingEncoding(NSUTF8StringEncoding)!;
    }
    
    /**
     Returns the paramaters which have been set on HPPManager as HTML string.
     
     - returns: The HTML string representation of the HPP paramaters which have been set.
     */
    private func getParametersString() -> String {
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
    private func getHPPRequest() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let request = NSMutableURLRequest(URL: self.HPPRequestProducerURL, cachePolicy: cachePolicy, timeoutInterval: 30.0)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.HTTPBody = self.getParametersString().dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            do {
                if let receivedData = data {
                    // success
                    self.HPPRequest = try NSJSONSerialization.JSONObjectWithData(receivedData, options: []) as! NSDictionary
                    self.getPaymentForm()
                }
                else {
                    // error
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.delegate?.HPPManagerFailedWithError!(error! as NSError)
                    self.hppViewController.dismissViewControllerAnimated(true, completion: nil)
                }
                
            } catch {
                // error
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.delegate?.HPPManagerFailedWithError!(error as NSError)
                self.hppViewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        dataTask.resume()
    }
    
    /**
     Makes a network request to HPP, passing the encoded HPP Reqeust we received from the HPP Request Producer, the responce is a HTML Payment form which is displayed in the Web View.
     */
    private func getPaymentForm() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let request = NSMutableURLRequest(URL: self.HPPURL, cachePolicy: cachePolicy, timeoutInterval: 30.0)
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        request.HTTPBody = self.httpBodyWithJSON(self.HPPRequest)
        
        
        //print("Request: \n" + (request.URL?.absoluteString)!)
        
        self.hppViewController.loadRequest(request)
        
    }
    
    /**
     Makes a network request to the HPP Response Consumer passing the responce from HPP.
     
     - parameter hppResponse: The response from HPP which is to be decoded.
     */
    private func decodeHPPResponse(hppResponse: String) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let request = NSMutableURLRequest(URL: self.HPPResponseConsumerURL, cachePolicy: cachePolicy, timeoutInterval: 30.0)
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        let parameters = "hppResponse=" + hppResponse
        
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            do {
                // Stop the spinner
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                if let receivedData = data {
                    // success
                    let decodedResponse = try NSJSONSerialization.JSONObjectWithData(receivedData, options: [NSJSONReadingOptions.AllowFragments]) as! Dictionary <String, String>
                    self.delegate?.HPPManagerCompletedWithResult!(decodedResponse)
                }
                else {
                    // error
                    self.delegate?.HPPManagerFailedWithError!(error! as NSError)
                    self.hppViewController.dismissViewControllerAnimated(true, completion: nil)
                }
                
            } catch {
                // error
                self.delegate?.HPPManagerFailedWithError!(error as NSError)
                self.hppViewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        dataTask.resume()
        
    }
    
    
    //MARK: - HPPViewControllerDelegate
    
    /**
    The delegate callback made by the HPP View controller when the interaction with HPP completes successfully.
    
    - parameter hppResponse: The response the webview received from HPP.
    */
    func HPPViewControllerCompletedWithResult(hppResponse: String) {
        
        self.decodeHPPResponse(hppResponse);
    }
    
    /**
     The delegate callback made by the HPP View controller when the interaction with HPP fails with an error.
     
     - parameter error: The error which occured.
     */
    func HPPViewControllerFailedWithError(error: NSError?) {
        self.delegate?.HPPManagerFailedWithError!(error)
        self.hppViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     The delegate callback made by the HPP View controller when the user cancels the payment.
     */
    func HPPViewControllerWillDismiss() {
        self.delegate?.HPPManagerCancelled!()
    }
    
}
