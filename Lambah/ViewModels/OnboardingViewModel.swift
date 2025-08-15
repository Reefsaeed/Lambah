//
//  OnboardingViewModel.swift
//  Lambah
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    
    private let totalPages = 2
    
    func moveToNextPage() {
        if currentPage < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }
    
    func moveToPreviousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage -= 1
            }
        }
    }
    
    func skipOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func handleSwipeGesture(translation: CGFloat) {
        let threshold: CGFloat = 50
        
        if translation > threshold {
            moveToPreviousPage()
        } else if translation < -threshold {
            moveToNextPage()
        }
    }
    
    var shouldShowDots: Bool {
        return totalPages > 1
    }
    
    var isFirstPage: Bool {
        return currentPage == 0
    }
    
    var isLastPage: Bool {
        return currentPage == totalPages - 1
    }
}
