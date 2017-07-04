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


    @IBAction func payButtonAction(_ sender: AnyObject) {

        let hppManager = HPPManager()

        hppManager.HPPRequestProducerURL = URL(string: "https://myserver.com/hppRequestProducer")
        hppManager.HPPURL = URL(string: "https://pay.sandbox.realexpayments.com/pay")
        hppManager.HPPResponseConsumerURL = URL(string: "https://myserver.com/hppResponseConsumer")

        hppManager.delegate = self
        hppManager.presentViewInViewController(self)
    }


    //MARK: - HPPManagerDelegate

    func HPPManagerCompletedWithResult(_ result: Dictionary <String, String>) {
        // success
        print(NSString(format: "%@", result) as String)
    }

    func HPPManagerFailedWithError(_ error: NSError?) {
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
