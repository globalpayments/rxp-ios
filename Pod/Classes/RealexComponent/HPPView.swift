//
//  HPPView.swift
//  HippoTrade
//
//  Created by James Wolfe on 15/12/2022.
//



import UIKit
import SwiftUI


@available(iOS 13, *)
public struct HPPView: UIViewControllerRepresentable {
    
    var manager: Binding<HPPManager>
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager)
    }

    public class Coordinator: NSObject {
        var manager: Binding<HPPManager>

        init(manager: Binding<HPPManager>) {
            self.manager = manager
        }
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<HPPView>) -> UINavigationController {
        return UINavigationController(rootViewController: context.coordinator.manager.wrappedValue.viewController())
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<HPPView>) { }
}
