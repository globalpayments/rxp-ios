import UIKit
import RXPiOS

final class ViewController: UIViewController, HPPManagerDelegate {

    @IBOutlet private weak var resultTextView: UITextView!
    @IBOutlet private weak var payButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
    }

    @IBAction private func payButtonAction() {
        setLoadingState()

        let hppManager = HPPManager()
        hppManager.isEncoded = false
        hppManager.HPPRequestProducerURL = URL(string: "https://www.example.com/HppRequestProducer")
        hppManager.HPPURL = URL(string: "https://pay.sandbox.realexpayments.com/pay")
        hppManager.HPPResponseConsumerURL = URL(string: "https://www.example.com/HppResponseConsumer")
        hppManager.additionalHeaders = ["custom_header_1": "test param 1",
                                        "custom_header_2": "test param 2",
                                        "custom_header_3": "test param 3"]
        hppManager.delegate = self
        hppManager.presentViewInViewController(self)
    }

    private func setLoadingState() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        payButton.isEnabled = false
    }

    //MARK: - HPPManagerDelegate

    func HPPManagerCompletedWithResult(_ result: [String: String]) {
        displayResult(result: NSString(format: "%@", result) as String)
    }

    func HPPManagerFailedWithError(_ error: Error?) {
        if let hppError = error {
            displayResult(result: hppError.localizedDescription)
        }
    }

    func HPPManagerCancelled() {
        displayResult(result: "Cancelled by User")
    }

    func displayResult(result: String) {
        self.resultTextView.text = result
        self.activityIndicator.stopAnimating()
        self.payButton.isEnabled = true
    }
}
