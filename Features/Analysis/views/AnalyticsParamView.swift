//
//  AnalyticsParamView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 10.07.2025.
//

import UIKit

final class AnalyticsParamView: UIView {
    private lazy var titleLabel = UILabel()
    private lazy var spacer = UIView()
    private let stateView: UIView

    init(_ title: String, isDatePicker: Bool = true) {
        if isDatePicker {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            stateView = datePicker
        } else {
            let label = UILabel()
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 17, weight: .regular)
            stateView = label
        }
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)

        let stack = UIStackView(arrangedSubviews: [titleLabel, spacer, stateView])
        stack.axis = .horizontal
        stack.distribution = .fill // ?
        addSubview(stack)
        stack.pinTop(to: self)
        stack.pinBottom(to: self)
        stack.pinLeft(to: self, 10)
        stack.pinRight(to: self, 10)
    }

    var totalLabel: UILabel? {
        stateView as? UILabel
    }

    var datePicker: UIDatePicker? {
        stateView as? UIDatePicker
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
