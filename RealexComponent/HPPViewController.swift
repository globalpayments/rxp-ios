//
//  HPPViewController.swift
//  rxp-ios
//
//  Copyright © 2015 realexpayments. All rights reserved.
//

import UIKit
import WebKit

@objc protocol HPPViewControllerDelegate {
    optional func HPPViewControllerWillDismiss()
    optional func HPPViewControllerCompletedWithResult(result: String);
    optional func HPPViewControllerFailedWithError(error: NSError?);
}

class HPPViewController: UIViewController, WKNavigationDelegate,  WKUIDelegate, WKScriptMessageHandler, UIWebViewDelegate {
    
    @IBOutlet var containerView : UIView? = nil
    
    var webView: WKWebView?
    var legacyWebView: UIWebView?
    
    var delegate:HPPViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 9.0, *) {
            //use WKWebView on iOS 9.0 and later
            self.initialiseWebView()
        } else {
            //use UIView
            self.initaliseLegacyWebView()
        }
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "closeView")
        self.navigationItem.leftBarButtonItem = cancelButton
        
    }
    
    func initialiseWebView() {
        
        let viewScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        let viewScript = WKUserScript(source: viewScriptString, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(viewScript)
        userContentController.addScriptMessageHandler(self, name: "callbackHandler")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        
        self.webView?.navigationDelegate = self;
        self.view = self.webView
    }
    
    func initaliseLegacyWebView() {
        
        self.legacyWebView = UIWebView(frame: self.view.bounds)
        self.legacyWebView?.delegate = self
        self.view = self.legacyWebView
        
    }
    
    
    func closeView() {
        self.delegate?.HPPViewControllerWillDismiss!()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadRequest (request: NSURLRequest) {
        
        if #available(iOS 9.0, *) {
            //load request in new WKWebView
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                
                if error != nil {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    self.delegate?.HPPViewControllerFailedWithError!(error)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else if data?.length == 0 {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    self.delegate?.HPPViewControllerFailedWithError!(nil)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    let htmlString = String(data: data!, encoding: NSUTF8StringEncoding)
                    self.webView!.loadHTMLString(htmlString!, baseURL: request.URL)
                    
                }
            }
            dataTask.resume()
        }
        else {
            //load request in legacy UIWebView
            self.legacyWebView?.loadRequest(request)
        }
    }
    
    
    //MARK: - WKWebView Delegate Callbacks
    
    
    /* Start the network activity indicator when the web view is loading */
    func webView(webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    /* Stop the network activity indicator when the loading finishes */
    func webView(webView: WKWebView,
        didFinishNavigation navigation: WKNavigation){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    /* Stop the network activity indicator when the loading fails */
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.delegate?.HPPViewControllerFailedWithError!(error)
    }
    
    
    func webView(webView: WKWebView,
        decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse,
        decisionHandler: (WKNavigationResponsePolicy) -> Void){
            
            decisionHandler(.Allow)
            
    }
    
    func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            
            decisionHandler(.Allow)
            
    }
    
    //MARK: - Javascript Message Callback
    
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        //String(data: hppResponse, encoding: NSUTF8StringEncoding)!
        
        
        if let messageString = message.body as? String {
            self.delegate?.HPPViewControllerCompletedWithResult!(messageString)
        }
        else {
            print("Something went wrong")
            self.delegate?.HPPViewControllerFailedWithError!(nil)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: - Legacy UIWebView Delegate Callbacks
    
    func webView(webView: UIWebView,
        shouldStartLoadWithRequest request: NSURLRequest,
        navigationType: UIWebViewNavigationType) -> Bool {
            
            if (request.URL?.scheme == "callbackhandler") {
                
                let message = request.URL?.host!.stringByRemovingPercentEncoding!
                self.delegate?.HPPViewControllerCompletedWithResult!(message!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            return true
    }
    
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    func webView(webView: UIWebView,
        didFailLoadWithError error: NSError?) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.delegate?.HPPViewControllerFailedWithError!(error)
    }
    
}
