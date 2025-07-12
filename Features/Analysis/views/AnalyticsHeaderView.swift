//
//  AnalyticsHeaderView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 11.07.2025.
//

import UIKit

final class AnalyticsHeaderView: UIView {
    private let startDateRow = AnalyticsParamView("Начало")
    private let endDateRow = AnalyticsParamView("Конец")
    private let totalRow = AnalyticsParamView("Всего", isDatePicker: false)

    init() {
        super.init(frame: .zero)
        let views = [startDateRow, endDateRow, totalRow]
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = .systemBackground
        for (index, view) in views.enumerated() {
            stack.addArrangedSubview(view)
            view.setHeight(44)
            if index < views.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .systemGray4
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.setHeight(1)
                stack.addArrangedSubview(separator)
            }
        }
        self.addSubview(stack)
        stack.pinTop(to: self)
        stack.pinBottom(to: self)
        stack.pinLeft(to: self, 10)
        stack.pinRight(to: self, 10)
        stack.layer.cornerRadius = 12
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

    func changeTotal(_ total: Decimal) {
        guard let label = totalRow.totalLabel else {
            return
        }
        label.text = total.formattedWithSeparator(currencySymbol: "₽")
    }
}

#Preview {
    AnalyticsHeaderView()
}
