//
//  HPPManager.swift
//  rxp-ios
//
//  Copyright © 2015 realexpayments. All rights reserved.
//

import UIKit

/**
 *  The delegate callbacks which allow the host app to receive all possible results form the component.
 */
@objc protocol HPPManagerDelegate {
    
    optional func HPPManagerCompletedWithResult(result: Dictionary <String, String>);
    optional func HPPManagerFailedWithError(error: NSError?);
    optional func HPPManagerCancelled();
    
}

/// The main object the host app creates.
class HPPManager: NSObject, UIWebViewDelegate, HPPViewControllerDelegate {
    
    var hppViewController: HPPViewController!
    var HPPRequestProducerURL: NSURL!
    var HPPResponseConsumerURL: NSURL!
    var HPPURL: NSURL! = NSURL(string: "https://hpp.realexpayments.com/pay")
    var HPPRequest: NSDictionary!
    
    var merchantId:String! = ""
    var account:String! = ""
    var orderId:String! = ""
    var amount:String! = ""
    var currency:String! = ""
    var timestamp:String! = ""
    
    var autoSettleFlag:String! = ""
    var commentOne:String! = ""
    var commentTwo:String! = ""
    var returnTss:String! = ""
    var shippingCode:String! = ""
    var shippingCountry:String! = ""
    var billingCode:String! = ""
    var billingCountry:String! = ""
    var customerNumber:String! = ""
    var variableReference:String! = ""
    var productId:String! = ""
    var language:String! = ""
    var cardPaymentButtonText:String! = ""
    var cardStorageEnable:String! = ""
    var offerSaveCard:String! = ""
    var payerReference:String! = ""
    var paymentReference:String! = ""
    var payerExists:String! = ""
    var validateCardOnly:String! = ""
    var dccEnable:String! = ""
    var supplementaryData:Dictionary<String, String>! = [:]
    
    var delegate:HPPManagerDelegate?
    
    /**
     The initialiser which when HPPManager is created, also creaes and instance of the HPPViewController.
     
     */
    override init() {
        super.init()
        self.hppViewController = HPPViewController()
        self.hppViewController.delegate = self
    }
    
    /**
     Presents the HPPManager's view modally
     
     - parameter viewController: The view controller from which HPPManager will display it's view.
     */
    func presentViewInViewController(viewController: UIViewController) {
        
        if  self.HPPRequestProducerURL.absoluteString != "" {
            self.getHPPRequest()
            let navigationController = UINavigationController(rootViewController: self.hppViewController)
            viewController.presentViewController(navigationController, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: "Alert", message: "HPPRequestProducerURL can't be blank", delegate: nil, cancelButtonTitle: "OK");
            alert.show()
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
        
        print("Request parameters: \n" + parameters.description)
        
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
        
        
        print("Request: \n" + (request.URL?.absoluteString)!)
        
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
