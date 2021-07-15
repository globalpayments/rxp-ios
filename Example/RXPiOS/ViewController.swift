import UIKit
import RXPiOS

final class ViewController: UIViewController, HPPManagerDelegate, GenericHPPManagerDelegate {

    typealias PaymentServiceResponse = HPPResponse

    @IBOutlet private weak var resultTextView: UITextView!
    @IBOutlet private weak var payButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.stopAnimating()
    }

    @IBAction private func payButtonAction() {
        setLoadingState()

        // Default implementation
        let hppManager = HPPManager()
        hppManager.delegate = self

        // Use in case of custom response
//        let hppManager = GenericHPPManager<HPPResponse>()
//        hppManager.setGenericDelegate(self)

        hppManager.isEncoded = false
        hppManager.HPPRequestProducerURL = URL(string: "https://www.example.com/HppRequestProducer")
        hppManager.HPPURL = URL(string: "https://pay.sandbox.realexpayments.com/pay")
        hppManager.HPPResponseConsumerURL = URL(string: "https://www.example.com/HppResponseConsumer")
        hppManager.additionalHeaders = ["custom_header_1": "test param 1",
                                        "custom_header_2": "test param 2",
                                        "custom_header_3": "test param 3"]
        hppManager.presentViewInViewController(self)
    }

    private func setLoadingState() {
        activityIndicator.startAnimating()
        payButton.isEnabled = false
    }

    private func display(result: String) {
        activityIndicator.stopAnimating()
        resultTextView.text = result
        payButton.isEnabled = true
    }

    // MARK: HPPManagerDelegate or GenericHPPManagerDelegate

    // Is called in case of GenericHPPManager<HPPResponse>()
    func HPPManagerCompletedWithResult(_ result: HPPResponse) {
        display(result: result.description)
    }

    // Is called in case of regular HPPManager()
    func HPPManagerCompletedWithResult(_ result: [String: Any]) {
        display(result: NSString(format: "%@", result) as String)
    }

    func HPPManagerFailedWithError(_ error: Error?) {
        if let error = error {
            display(result: error.localizedDescription)
        }
    }

    func HPPManagerCancelled() {
        display(result: "Canceled by user")
    }
}
