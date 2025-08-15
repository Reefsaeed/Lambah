//
//  OnboardingView.swift
//  Lambah
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    var completionHandler: () -> Void
    
    var body: some View {
        ZStack {
            if viewModel.isFirstPage {
                OnboardingPage1(
                    skipAction: {
                        viewModel.skipOnboarding()
                        completionHandler()
                    },
                    switchToNextPage: {
                        viewModel.moveToNextPage()
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            } else {
                OnboardingPage2(
                    getStartedAction: {
                        viewModel.completeOnboarding()
                        completionHandler()
                    },
                    switchToPreviousPage: {
                        viewModel.moveToPreviousPage()
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            }

            if viewModel.shouldShowDots {
                VStack {
                    Spacer()

                    ZStack {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 45, height: 20)

                        Circle()
                            .fill(Color(red: 0.2, green: 0.25, blue: 0.3))
                            .frame(width: 12, height: 12)
                            .offset(x: viewModel.currentPage == 0 ? -12 : 12)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    viewModel.handleSwipeGesture(translation: value.translation.width)
                }
        )
    }
}
