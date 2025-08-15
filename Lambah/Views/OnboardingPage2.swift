//
//  OnboardingPage2.swift
//  CustomObjectDetector
//
//  Created by Reef Saeed on 15/03/2025.
//

import SwiftUI

struct OnboardingPage2: View {
    var getStartedAction: () -> Void
    var switchToPreviousPage: () -> Void
    
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
            
            VStack {
                Spacer()
                
                // Image centered
                Image("ph2")
                    .resizable()
                    .frame(width: 300, height: 300)
                
                // Title
                Text("Expert Guidance & Solutions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primyC)
                    .padding(.top, 30)
                
                // Description text
                Text("Get detailed explanations of what each warning means and what actions you should take")
                    .fontWeight(.regular)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondryC)
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                
                Spacer()
                Spacer() // Extra spacer to push content up (same as page 1)
                
                // Start button - keeping original position
                Button(action: {
                    getStartedAction()
                }) {
                    Text("Start")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .padding(.horizontal, 80)
                        .padding(.vertical, 15)
                        .background(Color("yellow1"))
                        .cornerRadius(18)
                }
                .padding(.bottom, 50)
            }
        }
    }
}
