//
//  LottieView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 25.07.2025.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let filename: String

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        animationView.pinWidth(to: view)
        animationView.pinHeight(to: view)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
