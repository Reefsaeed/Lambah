//
//  OnboardingViewController.swift
//  CustomObjectDetector
//
//  Created by Reef Saeed on 15/03/2025.
//
import UIKit
import SwiftUI

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backC") ?? .systemBackground
        setupOnboardingView()
    }
    
    private func setupOnboardingView() {
        let onboardingView = OnboardingView { [weak self] in
            self?.presentMainApp()
        }
        
        let hostingController = UIHostingController(rootView: onboardingView)
        hostingController.view.backgroundColor = UIColor(named: "backC") ?? .systemBackground
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }
    
    private func presentMainApp() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else { return }
        
        window.rootViewController = mainVC
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
