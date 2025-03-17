//
//  OnboardingView.swift
//  CustomObjectDetector
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var completionHandler: () -> Void
    
    var body: some View {
        ZStack {
            // Show the appropriate page based on the current index
            if currentPage == 0 {
                OnboardingPage1(
                    skipAction: {
                        // Skip directly to the main app
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        completionHandler()
                    },
                    nextAction: {
                        // Go to next page
                        withAnimation {
                            currentPage = 1
                        }
                    }
                )
            } else {
                OnboardingPage2(
                    getStartedAction: {
                        // Mark onboarding as completed and go to main app
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        completionHandler()
                    }
                )
            }
        }
    }
}
