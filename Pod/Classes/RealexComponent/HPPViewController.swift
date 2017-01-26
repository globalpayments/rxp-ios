//
//  HPPViewController.swift
//  rxp-ios
//

import UIKit
import WebKit

/**
 *  THe delegate callbacks which allow the HPPManager to receive back the results from the webview.
 */
@objc protocol HPPViewControllerDelegate {
    optional func HPPViewControllerWillDismiss()
    optional func HPPViewControllerCompletedWithResult(result: String);
    optional func HPPViewControllerFailedWithError(error: NSError?);
}

/// The Web View Controller which encapsulates the management of the webivew and the interaction with the HPP web page.
class HPPViewController: UIViewController, WKNavigationDelegate,  WKUIDelegate, WKScriptMessageHandler, UIWebViewDelegate {

    @IBOutlet var containerView : UIView? = nil

    var webView: WKWebView?
    var legacyWebView: UIWebView?

    var delegate:HPPViewControllerDelegate?


    /**
     Initialise the correct webview for the OS version being run on.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 9.0, *) {
            // use WKWebView on iOS 9.0 and later
            self.initialiseWebView()
        } else {
            // use UIView
            self.initaliseLegacyWebView()
        }

        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "closeView")
        self.navigationItem.leftBarButtonItem = cancelButton

    }

    /**
     initialises the WKWebview.

     */
    private func initialiseWebView() {

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

    /**
     Initalises UIWebview.

     */
    private func initaliseLegacyWebView() {

        self.legacyWebView = UIWebView(frame: self.view.bounds)
        self.legacyWebView?.delegate = self
        self.view = self.legacyWebView

    }

    /**
     Called if the user taps the cancel button.
     */
    func closeView() {
        self.delegate?.HPPViewControllerWillDismiss!()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /**
     Loads the network request and displays the result in the webview.

     - parameter request: The network request to be loaded.
     */
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
            // Start the network activity indicator when the web view is loading
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    /* Stop the network activity indicator when the loading finishes */
    func webView(webView: WKWebView,
        didFinishNavigation navigation: WKNavigation){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    /* Stop the network activity indicator when the loading fails and report back to HPPManager */
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.delegate?.HPPViewControllerFailedWithError!(error)
    }

    /* allow all requests to be loaded */
    func webView(webView: WKWebView,
        decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse,
        decisionHandler: (WKNavigationResponsePolicy) -> Void){

            decisionHandler(.Allow)

    }

    /* allow all navigation actions */
    func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {

            decisionHandler(.Allow)

    }

    //MARK: - Javascript Message Callback

    /* Delegate callback which receives any massages from the Javascript bridge. */
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {

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


    /* intercepts any URL load requests and checks the URL Scheme, if it is custom scheme 'callbackhandler' this is a message from the webpage and is reported back to the HPP Manager. */
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

    /* Start the network activity indicator when the web view is loading */
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    }

    /* Stop the network activity indicator when the loading finishes */
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

    }

    /* Stop the network activity indicator when the loading fails and report back to HPPManager */
    func webView(webView: UIWebView,
        didFailLoadWithError error: NSError?) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.delegate?.HPPViewControllerFailedWithError!(error)
    }

}
