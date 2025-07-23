//
//  AnalyticsParamView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 10.07.2025.
//

import UIKit

final class AnalyticsParamView: UIView {
    private enum Constants {
        static let fontSize: Double = 17
        static let fontWeight: UIFont.Weight = .regular
        static let textAlignment: NSTextAlignment = .right
        static let stackLeftRightPadding: Double = 10
    }
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
            label.textAlignment = Constants.textAlignment
            label.font = .systemFont(ofSize: Constants.fontSize, weight: Constants.fontWeight)
            stateView = label
        }
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Constants.fontSize, weight: Constants.fontWeight)

        let stack = UIStackView(arrangedSubviews: [titleLabel, spacer, stateView])
        stack.axis = .horizontal
        stack.distribution = .fill // ?
        addSubview(stack)
        stack.pinTop(to: self)
        stack.pinBottom(to: self)
        stack.pinLeft(to: self, Constants.stackLeftRightPadding)
        stack.pinRight(to: self, Constants.stackLeftRightPadding)
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
