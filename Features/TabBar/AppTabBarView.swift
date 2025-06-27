//
//  AppTabBarView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import SwiftUI

struct AppTabBarView: View {
    enum Tab: Hashable {
        case outcome, income, balance, articles, settings
    }
    @State private var selectedTab: Tab = .balance
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Label("Расходы", systemImage: "chart.line.downtrend.xyaxis")
                }
                .tint(.accent)
                .tag(Tab.outcome)
            TransactionsListView(direction: .income)
                .tabItem {
                    Label("Доходы", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tint(.accent)
                .tag(Tab.income)
            BalanceView()
                .tabItem {
                    Label("Счет", systemImage: "chart.line.text.clipboard")
                }
                .tint(.accent)
                .tag(Tab.balance)
            Text("Статьи")
                .tabItem {
                    Label("Статьи", systemImage: "list.bullet.rectangle")
                }
                .tag(Tab.articles)
            Text("Настройки")
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.2")
                }
                .tag(Tab.settings)
        }
        .tint(.activeTab) 
        .onShake {
            print("Device shaken!")
        }
    }
}
