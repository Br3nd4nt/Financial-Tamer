//
//  AnalyticsViewControllerWrapper.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 11.07.2025.
//

import SwiftUI

struct AnalyticsViewControllerWrapper: UIViewControllerRepresentable {
    private let direction: Direction

    init(_ direction: Direction) {
        self.direction = direction
    }
    func makeUIViewController(context: Context) -> AnalyticsViewController {
        let vc = AnalyticsViewController(direction)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGroupedBackground
        appearance.backgroundColor = .cyan

        vc.navigationController?.navigationBar.standardAppearance = appearance
        vc.navigationController?.navigationBar.scrollEdgeAppearance = appearance

        return vc
    }

    func updateUIViewController(_ uiViewController: AnalyticsViewController, context: Context) {
    }
}
