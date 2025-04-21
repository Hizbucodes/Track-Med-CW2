//
//  SplashScreenView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-21.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.97, blue: 1.0).ignoresSafeArea()
            VStack {
                Spacer()
                Image("splash_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .clipShape(Circle())
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(isActive: .constant(true))
    }
}

