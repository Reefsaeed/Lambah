//
//  OnboardingPage1.swift
//  CustomObjectDetector
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import SwiftUI

struct OnboardingPage1: View {
    var skipAction: () -> Void
    var switchToNextPage: () -> Void
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#3A4354"), location: 0.0),
                    .init(color: Color(hex: "#3A4354"), location: 0.0),
                    .init(color: Color(hex: "#F5F5F5"), location: 0.5),
                    .init(color: Color(hex: "#F5F5F5"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Skip button positioned at top-right
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        skipAction()
                    }) {
                        Text("Skip")
                            .fontWeight(.regular)
                            .font(.system(size: 20))
                            .foregroundColor(Color("yellow1"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    .padding(.top, 55)
                    .padding(.trailing, 10)
                }
                Spacer()
            }
            
            // Main content - centered
            VStack {
                Spacer()
                
                // Phone image
                Image("ph")
                    .resizable()
                    .frame(width: 300, height: 300)
                
                // Title
                Text("Instant Dashboard Detection")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primyC)
                    .padding(.top, 30)
                
                // Description text
                Text("Point your camera at your dashboard and instantly identify any warning lights with AI-powered detection")
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondryC)
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                
                Spacer()
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
