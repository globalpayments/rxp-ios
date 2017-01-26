//
//  ViewController.swift
//  RXPiOS
//

import UIKit
import RXPiOS

class ViewController: UIViewController, HPPManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func payButtonAction(sender: AnyObject) {

        let hppManager = HPPManager()

        hppManager.HPPRequestProducerURL = NSURL(string: "https://myserver.com/hppRequestProducer")
        hppManager.HPPURL = NSURL(string: "https://pay.sandbox.realexpayments.com/pay")
        hppManager.HPPResponseConsumerURL = NSURL(string: "https://myserver.com/hppResponseConsumer")

        hppManager.merchantId = "realexsandbox"
        hppManager.account = "internet"
        hppManager.amount = "100"
        hppManager.currency = "EUR"

        hppManager.delegate = self
        hppManager.presentViewInViewController(self)
    }


    //MARK: - HPPManagerDelegate

    func HPPManagerCompletedWithResult(result: Dictionary <String, String>) {
        // success
        print(NSString(format: "%@", result) as String)
    }

    func HPPManagerFailedWithError(error: NSError?) {
        // error
        if let hppError = error {
            print(hppError.localizedDescription)
        }
    }

    func HPPManagerCancelled() {
        // cancelled
        print("Cancelled by user.")
    }
}
