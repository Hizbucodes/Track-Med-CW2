//
//  OnboardingView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-21.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboarding: Bool

    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding1",
            title: "Stay on Track, Stay Healthy",
            subtitle: "Never miss a dose with smart reminders tailored to your schedule.",
            buttonTitle: "Next"
        ),
        OnboardingPage(
            imageName: "onboarding2",
            title: "Your Health, Our Priority",
            subtitle: "Effortlessly manage your meds and watch your progress over time",
            buttonTitle: "Next"
        ),
        OnboardingPage(
            imageName: "onboarding3",
            title: "Simplify Your Routine",
            subtitle: "Set it and forget it–let us handle your medication reminders",
            buttonTitle: "Get Started"
        )
    ]

    @State private var currentPage = 0

    var body: some View {
        VStack {
            Spacer()
            Image(pages[currentPage].imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .accessibilityLabel(Text(pages[currentPage].title))
                .accessibilityHint(Text(pages[currentPage].subtitle))
            Spacer()
            VStack {
                Text(pages[currentPage].title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                Text(pages[currentPage].subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(pages[currentPage].title). \(pages[currentPage].subtitle)")
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.black : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)
                }
            }
            .padding(.bottom, 24)
            .accessibilityElement()
            .accessibilityLabel("Step \(currentPage + 1) of \(pages.count)")
            
            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    withAnimation { isOnboarding = false }
                }
            }) {
                Text(pages[currentPage].buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(30)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
            .accessibilityLabel(pages[currentPage].buttonTitle)
            .accessibilityHint(currentPage < pages.count - 1 ?
                "Shows next onboarding screen" :
                "Completes onboarding and starts the TrackMed"
            )
        }
        .background(Color.white.ignoresSafeArea())
    }
}
