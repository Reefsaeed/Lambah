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

            if currentPage == 0 {
                OnboardingPage1(
                    skipAction: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        completionHandler()
                    },
                    switchToNextPage: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 1
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            } else {
                OnboardingPage2(
                    getStartedAction: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        completionHandler()
                    },
                    switchToPreviousPage: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 0
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            }

            VStack {
                Spacer()

                ZStack {

                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 45, height: 20)

                    Circle()
                        .fill(Color(red: 0.2, green: 0.25, blue: 0.3))
                        .frame(width: 12, height: 12)
                        .offset(x: currentPage == 0 ? -12 : 12)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
                .padding(.bottom, 120)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    
                    if value.translation.width > threshold {
                        if currentPage > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                    } else if value.translation.width < -threshold {
                        if currentPage < 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                    }
                }
        )
    }
}
