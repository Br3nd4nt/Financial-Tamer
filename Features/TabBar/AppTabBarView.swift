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
                    Label(Constants.outcomeTitle, systemImage: Constants.outcomeIcon)
                }
                .tint(.accent)
                .tag(Tab.outcome)
            TransactionsListView(direction: .income)
                .tabItem {
                    Label(Constants.incomeTitle, systemImage: Constants.incomeIcon)
                }
                .tint(.accent)
                .tag(Tab.income)
            BalanceView()
                .tabItem {
                    Label(Constants.balanceTitle, systemImage: Constants.balanceIcon)
                }
                .tint(.accent)
                .tag(Tab.balance)
            Text(Constants.articlesTitle)
                .tabItem {
                    Label(Constants.articlesTitle, systemImage: Constants.articlesIcon)
                }
                .tag(Tab.articles)
            Text(Constants.settingsTitle)
                .tabItem {
                    Label(Constants.settingsTitle, systemImage: Constants.settingsIcon)
                }
                .tag(Tab.settings)
        }
        .tint(.activeTab)
        .onShake {
            print(Constants.shakeMessage)
        }
    }

    private enum Constants {
        static let outcomeTitle = "Расходы"
        static let outcomeIcon = "chart.line.downtrend.xyaxis"
        static let incomeTitle = "Доходы"
        static let incomeIcon = "chart.line.uptrend.xyaxis"
        static let balanceTitle = "Счет"
        static let balanceIcon = "chart.line.text.clipboard"
        static let articlesTitle = "Статьи"
        static let articlesIcon = "list.bullet.rectangle"
        static let settingsTitle = "Настройки"
        static let settingsIcon = "gearshape.2"
        static let shakeMessage = "Device shaken!"
    }
}
