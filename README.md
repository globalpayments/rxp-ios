# Realex Payments iOS Library
You can find more information on how to use this library and sign up for a free Realex Payments sandbox account at https://developer.realexpayments.com

## Requirements

- iOS 9.0+
- Xcode 7.1.1+

## Installation

### Cocoapods

1. To integrate the Realex Payments iOS Library into your Xcode project using CocoaPods, specify it in your podfile:

```
pod 'RXPiOS', '~> 1.7.0'
```

2. Then, run the following command:

```
$ pod install
```

### Swift Package Manager

1. To integrate the Realex Payments iOS Library into your Xcode project using Swift Package Manager, add it as a dependency in your Package.swift file:

```
dependencies: [
    .package(url: "https://github.com/globalpayments/rxp-ios", branch: "master")
]
```

### Manual

If you prefer not to use a dependency manager, you can integrate the Realex Payments iOS Library into your project manually.

- Download the the latest release from GitHub:

https://github.com/realexpayments/rxp-ios/releases

- Drag and drop the folder 'RealexComponent' into Xcode to use the HPP part of the library.
- Run the following command:
```
$ pod install
```
- If you want to use the card data validation library, drag and drop the folder 'RealexRemote' into your Xcode project.


## Using the HPP Library

### Instantiate

To instantiate an instance of the HPP manager do the following:

```
let hppManager = HPPManager()
```

### Integrate With Your Server

The HPP Manager requires three server URLs.

1) **Request Producer URL**: utilizing one of the Realex HPP server SDKs; this URL creates the necessary request JSON for the component using the shared secret stored on the server side.

2) **HPP URL**: the location where the component sends the encoded request. The default for live transactions is https://pay.realexpayments.com/pay

3) **Response Consumer URL**: utilizing one of the Realex HPP server SDKs; takes the encoded response received back from HPP checks the validity of the hash and decodes the response.

```
hppManager.HPPRequestProducerURL = URL(string: "https://myserver.com/hppRequestProducer")
hppManager.HPPURL = URL(string: "https://pay.realexpayments.com/pay")
hppManager.HPPResponseConsumerURL = URL(string: "https://myserver.com/hppResponseConsumer")
```

### Set Delegate

Next you set the object which will act as the delegate for the HPPManager. The delegate should implement the HPPManagerDelegate protocol and so will receive the response from the HPP Manager:

```
hppManager.delegate = self
```

### Delegate Callbacks

There are three possible outcomes from the HPP interaction:

1) It concluded successfully. This returns the decoded JSON from HPP, parsed as a native Dictionary of name / value pairs.

2) It failed with an error. This returns an object of the Error Class, you can access properties such as code and localizedDescription for more details on the error.

3) It was cancelled by the user.

The HPP Manager's delegate should implement the following three functions to receive back the result from the HPP Manager:

```
func HPPManagerCompletedWithResult(_ result: [String: String])
func HPPManagerFailedWithError(_ error: Error?)
func HPPManagerCancelled()
```

### Present Payment Form

Using the presentViewInViewController() method the HPP Manager will process the given parameters, get the request from the server, send the encoded request to HPP and present the form received back:

```
hppManager.presentViewInViewController(self)
```

### Consume HPP Response JSON

On the server-side using one of our server SDKs, setup your Response Consumer to take in the response JSON and create the HPP Response:

```
RealexHpp realexHpp = new RealexHpp("secret");
HppResponse hppResponse = realexHpp.responseFromJson(responseJson);
```

### Alternative Setup

In case if your client-side code requires another type than `[String: String]` when receiving `HPPManagerCompletedWithResult` delegate, you need to set up the library differently

1) Change `HPPManagerDelegate` into `GenericHPPManagerDelegate`

2) Change `HPPManager()` into `GenericHPPManager<HPPResponse>()` where `HPPResponse` is a custom defined struct or class.

3) Change function signature

```
from
func HPPManagerCompletedWithResult(_ result: [String: String]) { ... }
into
func HPPManagerCompletedWithResult(_ result: HPPResponse) { ... }
```

Example:

```
final class ViewController: UIViewController, GenericHPPManagerDelegate { 

func pay() {
    let hppManager = GenericHPPManager<HPPResponse>()
    hppManager.setGenericDelegate(self)
    ...
}

func HPPManagerCompletedWithResult(_ result: HPPResponse) { ... }

func HPPManagerFailedWithError(_ error: Error?) { ... }

func HPPManagerCancelled() { ... }

}
```

**Note**: By default, HPPManager is using `[Stirng: String]` type.

## FAQ

### Set HPP Properties

You can also set whatever HPP properties you need to in the component, for example:

```
hppManager.merchantId = "realexsandbox"
hppManager.account = "internet"
hppManager.amount = "100"
hppManager.currency = "EUR"
```

These will be sent to the *Request Producer URL*, your server-side code must be setup to take in these values and pass them to the HPP server-side SDK for them to be included in the request.

Note, in addition to the predefined properties, you can add any amount of additional arbitrary properties as follows:

```
hppManager.supplementaryData["UNKNOWN_1"] = "Unknown value 1"
hppManager.supplementaryData["UNKNOWN_2"] = "Unknown value 2"
```

Also, in addition to predefined header values, you can add any amount of additional values as follows:

```
hppManager.additionalHeaders = ["custom-header-1": "test param 1",
                                "custom-header-2": "test param 2",
                                "custom-header-3": "test param 3"]
```

### Testing

Realex Payments maintain separate endpoints for live and test transactions. You’ll need to override the HPP URL in the SDK to facilitate testing. Use the code below:

```
hppManager.HPPURL = URL(string: "https://pay.sandbox.realexpayments.com/pay")
```

## License

See the LICENSE file.
