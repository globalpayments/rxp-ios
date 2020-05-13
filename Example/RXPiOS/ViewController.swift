//
//  ViewController.swift
//  RXPiOS
//

import UIKit
import RXPiOS

final class ViewController: UIViewController, HPPManagerDelegate {

    @IBOutlet weak var result_textView: UITextView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.isHidden = true
    }

    @IBAction func payButtonAction(_ sender: AnyObject) {

        let hppManager = HPPManager()
        hppManager.isEncoded = false
        hppManager.HPPRequestProducerURL = URL(string: "https://www.example.com/HppRequestProducer")
        hppManager.HPPURL = URL(string: "https://pay.sandbox.realexpayments.com/pay")
        hppManager.HPPResponseConsumerURL = URL(string: "https://www.example.com/HppResponseConsumer")
        hppManager.enableUserAgent = true
        hppManager.additionalHeaders = ["custom_header_1": "test param 1",
                                        "custom_header_2": "test param 2",
                                        "custom_header_3": "test param 3"]
        hppManager.delegate = self
        hppManager.presentViewInViewController(self)

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        payButton.isEnabled = false
    }


    //MARK: - HPPManagerDelegate

    func HPPManagerCompletedWithResult(_ result: Dictionary <String, String>) {
        DispatchQueue.main.async() {
            self.displayResult(result: NSString(format: "%@", result) as String)
        }
    }

    func HPPManagerFailedWithError(_ error: NSError?) {
        if let hppError = error {
            displayResult(result: hppError.localizedDescription)
        }
    }

    func HPPManagerCancelled() {
        self.displayResult(result: "Cancelled by User")
    }

    func displayResult(result: String) {
        self.result_textView.text = NSString(format: "%@", result) as String
        self.result_textView.textAlignment = .left
        self.activityIndicator.stopAnimating();
        self.payButton.isEnabled = true;
    }
}
