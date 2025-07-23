//
//  AnalyticsTransactionCell.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 12.07.2025.
//

import UIKit

final class AnalyticsCategoryCell: UITableViewCell {
    private let wrap = UIView()
    private let categoryEmojiLabel = UILabel()
    private let categoryNameLabel = UILabel()
    private let categoryDescriptionLabel = UILabel()
    private let spacer = UIView()
    private let categoryPercentageLabel = UILabel()
    private let categoryAmountLabel = UILabel()

    static let reuseId = "AnalyticsCategoryCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        wrap.isUserInteractionEnabled = false
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        addSubview(wrap)
        wrap.pinVertical(to: self, 10)
        wrap.pinHorizontal(to: self, 10)

        let firstStack = UIStackView(arrangedSubviews: [categoryNameLabel, categoryDescriptionLabel])
        firstStack.axis = .vertical
        firstStack.distribution = .fill

        categoryPercentageLabel.textAlignment = .right
        categoryAmountLabel.textAlignment = .right
        let secondStack = UIStackView(arrangedSubviews: [categoryPercentageLabel, categoryAmountLabel])
        secondStack.axis = .vertical

        let stack = UIStackView(arrangedSubviews: [categoryEmojiLabel, firstStack, spacer, secondStack])
        stack.axis = .horizontal
        stack.distribution = .fill
        wrap.addSubview(stack)
        stack.pinTop(to: wrap)
        stack.pinBottom(to: wrap)
        stack.pinLeft(to: wrap)
        stack.pinRight(to: wrap)
    }

    func configure(with category: CategoryAnalytics, currencySymbol: String) {
        categoryEmojiLabel.text = "\(category.emoji)"
        categoryNameLabel.text = category.name
        categoryDescriptionLabel.text = category.description
        let value = (category.percentage * Decimal(100)).doubleValue
        categoryPercentageLabel.text = "\(Int(value.rounded(.toNearestOrAwayFromZero)))%"
        categoryAmountLabel.text = category.totalValue.formattedWithSeparator(currencySymbol: currencySymbol)
    }
}
