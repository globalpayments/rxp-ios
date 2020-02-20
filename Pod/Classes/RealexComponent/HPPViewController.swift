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
    @objc optional func HPPViewControllerWillDismiss()
    @objc optional func HPPViewControllerCompletedWithResult(_ result: String);
    @objc optional func HPPViewControllerFailedWithError(_ error: NSError?);
}

/// The Web View Controller which encapsulates the management of the webivew and the interaction with the HPP web page.
class HPPViewController: UIViewController, WKNavigationDelegate,  WKUIDelegate, WKScriptMessageHandler, UIWebViewDelegate {

    @IBOutlet var containerView : UIView? = nil

    var cssString: String?
    var webView: WKWebView?
    var legacyWebView: UIWebView?

    var delegate:HPPViewControllerDelegate?


    /**
     Initialise the correct webview for the OS version being run on.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 9.0, *) {
            // use WKWebView on iOS 9.0 and later
            self.initialiseWebView()
        } else {
            // use UIView
            self.initaliseLegacyWebView()
        }

        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(HPPViewController.closeView))
        self.navigationItem.leftBarButtonItem = cancelButton

    }

    /**
     initialises the WKWebview.

     */
    fileprivate func initialiseWebView() {

        let viewScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum- scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);";
        let viewScript = WKUserScript(source: viewScriptString, injectionTime: .atDocumentStart, forMainFrameOnly: true)

        let userContentController = WKUserContentController()
        userContentController.addUserScript(viewScript)
        userContentController.add(self, name: "callbackHandler")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)

        self.webView?.navigationDelegate = self;
        self.view = self.webView
    }

    /**
     Initalises UIWebview.

     */
    fileprivate func initaliseLegacyWebView() {

        self.legacyWebView = UIWebView(frame: self.view.bounds)
        self.legacyWebView?.delegate = self
        self.view = self.legacyWebView

    }

    /**
     Called if the user taps the cancel button.
     */
    @objc func closeView() {
        self.delegate?.HPPViewControllerWillDismiss!()
        self.dismiss(animated: true, completion: nil)
    }

    /**
     Loads the network request and displays the result in the webview.

     - parameter request: The network request to be loaded.
     */
    func loadRequest (_ request: URLRequest) {

        if #available(iOS 9.0, *) {
            //load request in new WKWebView
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in

                if error != nil {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false

                    self.delegate?.HPPViewControllerFailedWithError!(error as NSError?)
                    self.dismiss(animated: true, completion: nil)
                }
                else if data?.count == 0 {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false

                    self.delegate?.HPPViewControllerFailedWithError!(nil)
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    let htmlString = String(data: data!, encoding: String.Encoding.utf8)
                    self.webView!.loadHTMLString(htmlString!, baseURL: request.url)

                }
            })
            dataTask.resume()
        }
        else {
            //load request in legacy UIWebView
            self.legacyWebView?.loadRequest(request)
        }
    }

    /**
     Sets the CSS string to be used to style the loaded HPP page
    */
    func setCSS(_ css: String?) {
        cssString = css
    }

    //MARK: - WKWebView Delegate Callbacks


    /* Start the network activity indicator when the web view is loading */
    func webView(_ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation){
            // Start the network activity indicator when the web view is loading
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    /* Stop the network activity indicator when the loading finishes */
    func webView(_ webView: WKWebView,
        didFinish navigation: WKNavigation){
        if let css = cssString {
            let js = "var style = document.createElement('style'); style.innerHTML = \"\(css)\"; document.head.appendChild(style);"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    /* Stop the network activity indicator when the loading fails and report back to HPPManager */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.delegate?.HPPViewControllerFailedWithError!(error as NSError?)
    }

    /* allow all requests to be loaded */
    func webView(_ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void){

            decisionHandler(.allow)

    }

    /* allow all navigation actions */
    func webView(_ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            decisionHandler(.allow)

    }

    //MARK: - Javascript Message Callback

    /* Delegate callback which receives any massages from the Javascript bridge. */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if let messageString = message.body as? String {
            self.delegate?.HPPViewControllerCompletedWithResult!(messageString)
        }
        else {
            print("Something went wrong")
            self.delegate?.HPPViewControllerFailedWithError!(nil)
        }

        self.dismiss(animated: true, completion: nil)
    }


    //MARK: - Legacy UIWebView Delegate Callbacks


    /* intercepts any URL load requests and checks the URL Scheme, if it is custom scheme 'callbackhandler' this is a message from the webpage and is reported back to the HPP Manager. */
    func webView(_ webView: UIWebView,
        shouldStartLoadWith request: URLRequest,
        navigationType: UIWebView.NavigationType) -> Bool {

            if (request.url?.scheme == "callbackhandler") {

                let message = request.url?.host!.removingPercentEncoding
                self.delegate?.HPPViewControllerCompletedWithResult!(message!)
                self.dismiss(animated: true, completion: nil)
            }
            return true
    }

    /* Start the network activity indicator when the web view is loading */
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

    }

    /* Stop the network activity indicator when the loading finishes */
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

    }

    /* Stop the network activity indicator when the loading fails and report back to HPPManager */
    func webView(_ webView: UIWebView,
        didFailLoadWithError error: Error) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.delegate?.HPPViewControllerFailedWithError!(error as NSError?)
    }

}
