//
//  AnalyticsHeaderView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 11.07.2025.
//

import UIKit
import PieChart

final class AnalyticsHeaderView: UIView {
    private enum Constants {
        static let startTitle = "Начало"
        static let endTitle = "Конец"
        static let totalTitle = "Всего"
        static let selectorTitle = "Выберите метод сортировки"
        static let stackLeftRightPadding: Double = 10
        static let stackCornerRadius: Double = 12
        static let selectorTopPadding: Double = 5
        static let selectorLeftPadding: Double = 5
        static let selectorRightPadding: Double = 5
        static let selectorBottomPadding: Double = 5
        static let separatorColor = UIColor.systemGray4
        static let separatorHeight: Double = 1
        static let rowHeight: Double = 44
        static let selectorDefaultIndex = 1
    }
    private let startDateRow = AnalyticsParamView(Constants.startTitle)
    private let endDateRow = AnalyticsParamView(Constants.endTitle)
    private let selectorWrap = UIView()
    private let selectorTitle = UILabel()
    let pieChartView = PieChartView()
    // need to setup target later in the man viewcontroller
    let selector = UISegmentedControl()
    private let totalRow = AnalyticsParamView(Constants.totalTitle, isDatePicker: false)

    init() {
        super.init(frame: .zero)
        setupSelector()
        let views = [startDateRow, endDateRow, selectorWrap, totalRow, pieChartView]
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = .systemBackground
        for (index, view) in views.enumerated() {
            stack.addArrangedSubview(view)
            if view == pieChartView {
                // Для PieChart даем больше места
                view.setHeight(mode: .grOE, 200)
            } else {
                view.setHeight(mode: .grOE, Constants.rowHeight)
            }
            if index < views.count - 1 {
                let separator = UIView()
                separator.backgroundColor = Constants.separatorColor
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.setHeight(Constants.separatorHeight)
                stack.addArrangedSubview(separator)
            }
        }
        self.addSubview(stack)
        stack.pinTop(to: self)
        stack.pinBottom(to: self)
        stack.pinLeft(to: self, Constants.stackLeftRightPadding)
        stack.pinRight(to: self, Constants.stackLeftRightPadding)
        stack.layer.cornerRadius = Constants.stackCornerRadius
    }

    private func setupSelector() {
        selectorWrap.addSubview(selectorTitle)
        selectorTitle.text = Constants.selectorTitle
        selectorTitle.pinTop(to: selectorWrap, Constants.selectorTopPadding)
        selectorTitle.pinLeft(to: selectorWrap, Constants.selectorLeftPadding)
        let options = TransactionSortOption.allCases
        for (index, value) in options.enumerated() {
            selector.insertSegment(withTitle: value.rawValue, at: index, animated: false)
        }
        selectorWrap.addSubview(selector)
        selector.selectedSegmentIndex = Constants.selectorDefaultIndex
        selector.pinTop(to: selectorTitle.bottomAnchor, Constants.selectorTopPadding)
        selector.pinLeft(to: selectorWrap, Constants.selectorLeftPadding)
        selector.pinRight(to: selectorWrap, Constants.selectorRightPadding)
        selector.pinBottom(to: selectorWrap, Constants.selectorBottomPadding)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var startDatePicker: UIDatePicker? {
        startDateRow.datePicker
    }

    var endDatePicker: UIDatePicker? {
        endDateRow.datePicker
    }

    func changeTotal(_ total: Decimal, currencySymbol: String) {
        guard let label = totalRow.totalLabel else {
            return
        }
        label.text = total.formattedWithSeparator(currencySymbol: currencySymbol)
    }

    func updatePieChart(_ data: [Entity]) {
        print("AnalyticsHeaderView: updatePieChart called with \(data.count) entities")
        pieChartView.entities = data
        pieChartView.setNeedsDisplay()
        pieChartView.layoutIfNeeded()
    }
}

#Preview {
    let header = AnalyticsHeaderView()
    header.changeTotal(1000, currencySymbol: "₽")
    return header
}
