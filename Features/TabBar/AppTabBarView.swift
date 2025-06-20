//
//  AppTabBarView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import SwiftUI

struct AppTabBarView: View {
    var body: some View {
        TabView {
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Label("Расходы", systemImage: "chart.line.downtrend.xyaxis")
                }
            TransactionsListView(direction: .income)
                .tabItem {
                    Label("Доходы", systemImage: "chart.line.uptrend.xyaxis")
                }
            Text("Счет")
                .tabItem {
                    Label("Счет", systemImage: "chart.line.text.clipboard")
                }
            Text("Статьи")
                .tabItem {
                    Label("Статьи", systemImage: "list.bullet.rectangle")
                }
            Text("Настройки")
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.2")
                }
        }
    }
}
