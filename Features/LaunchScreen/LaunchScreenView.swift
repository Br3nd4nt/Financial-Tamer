//
//  LaunchScreenView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 25.07.2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive = true

    var body: some View {
        ZStack {
            if isActive {
                LottieView(filename: "upload.json")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isActive = false
                            }
                        }
                    }
            } else {
                AppTabBarView()
            }
        }
    }
}
