//
//  OnboardingViewController.swift
//  CustomObjectDetector
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import UIKit
import SwiftUI

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OnboardingViewController loaded")
        // Create and configure the SwiftUI onboarding view
        let onboardingView = OnboardingView(completionHandler: {
            // This will be called when onboarding is complete
            self.presentMainApp()
        })
        
        // Create a UIHostingController to wrap the SwiftUI view
        let hostingController = UIHostingController(rootView: onboardingView)
        
        // Add the hosting controller as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Configure the hosting controller's view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    private func presentMainApp() {
        // Get the main storyboard
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Get the main view controller from the storyboard
        guard let mainViewController = mainStoryboard.instantiateInitialViewController() else {
            fatalError("Could not load Main storyboard")
        }
        
        // Present the main view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainViewController
            
            // Add a smooth transition animation
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}

