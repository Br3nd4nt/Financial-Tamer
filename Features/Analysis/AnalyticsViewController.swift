//
//  AnalysisViewController.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 10.07.2025.
//

import UIKit

final class AnalyticsViewController: UIViewController {
    private let headerView = AnalyticsHeaderView()
    private let tableTitleLabel = UILabel()
    private let categoriesTableView = UITableView(frame: .zero)
    private let viewModel: AnalyticsViewModel
    private var headerWidthConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.backgroundColor = .systemGroupedBackground
        makeTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.loadTransactions()
            reloadData()
        }
    }

    init(_ direction: Direction) {
        viewModel = AnalyticsViewModel(direction: direction)
        headerView.startDatePicker!.date = viewModel.dayStart
        super.init(nibName: nil, bundle: nil)
        viewModel.onReloadData = reloadData
        viewModel.setStartDateForPicker = { date in
            self.headerView.startDatePicker?.date = date
        }
        viewModel.setEndDateForPicker = { date in
            self.headerView.endDatePicker?.date = date
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeTable() {
        let initialWidth = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: initialWidth, height: 1))
        headerContainer.backgroundColor = .clear
        headerContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerWidthConstraint = headerContainer.widthAnchor.constraint(equalToConstant: initialWidth)
        headerWidthConstraint?.isActive = true

        headerContainer.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.pinTop(to: headerContainer)
        headerView.pinLeft(to: headerContainer)
        headerView.pinRight(to: headerContainer)

        tableTitleLabel.text = "Категории"
        tableTitleLabel.textColor = .secondaryLabel
        headerContainer.addSubview(tableTitleLabel)
        tableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableTitleLabel.pinTop(to: headerView.bottomAnchor, 10)
        tableTitleLabel.pinLeft(to: headerContainer, 10)
        tableTitleLabel.pinRight(to: headerContainer, 10)
        tableTitleLabel.pinBottom(to: headerContainer, 0)

        let headerHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 10 + tableTitleLabel.intrinsicContentSize.height
        let minHeaderHeight: CGFloat = 120
        headerContainer.frame = CGRect(x: 0, y: 0, width: initialWidth, height: max(headerHeight, minHeaderHeight))

        categoriesTableView.tableHeaderView = headerContainer
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoriesTableView)
        categoriesTableView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        categoriesTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor)
        categoriesTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor)
        categoriesTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        categoriesTableView.backgroundColor = .systemBackground
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.separatorStyle = .singleLine
        categoriesTableView.isScrollEnabled = true
        categoriesTableView.allowsSelection = false
        categoriesTableView.register(AnalyticsCategoryCell.self, forCellReuseIdentifier: AnalyticsCategoryCell.reuseId)

        guard let startDatePicker = headerView.startDatePicker else {
            return
        }
        startDatePicker.addTarget(viewModel, action: #selector(viewModel.startDateChanged), for: .valueChanged)
        guard let endDatePicker = headerView.endDatePicker else {
            return
        }
        endDatePicker.addTarget(viewModel, action: #selector(viewModel.endDateChanged), for: .valueChanged)
        headerView.selector.addTarget(viewModel, action: #selector(viewModel.sortOptionChanged), for: .valueChanged)
    }

    private func reloadData() {
        print("categoryRows count:", viewModel.categoryRows.count)
        categoriesTableView.reloadData()
        headerView.changeTotal(viewModel.total)
        updateTableHeaderLayout()
    }

    private func updateTableHeaderLayout() {
        guard let header = categoriesTableView.tableHeaderView else { return }
        let targetWidth = categoriesTableView.bounds.width
        headerWidthConstraint?.constant = targetWidth
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let headerHeight = header.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        if header.frame.width != targetWidth || header.frame.height != headerHeight {
            header.frame = CGRect(x: 0, y: 0, width: targetWidth, height: headerHeight)
            header.layoutIfNeeded()
            categoriesTableView.tableHeaderView = header
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }
}

extension AnalyticsViewController: UITableViewDelegate {}

extension AnalyticsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoryRows.count * 1000
//        viewModel.categoryRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnalyticsCategoryCell.reuseId, for: indexPath) as? AnalyticsCategoryCell
        guard let cell else {
            return UITableViewCell()
        }
        // остаток от деления только ради тестирования скролла со множеством элементов
        cell.configure(with: viewModel.categoryRows[indexPath.row % viewModel.categoryRows.count])
        return cell
    }
}

#Preview {
    let navController = UINavigationController()
    let analyticsVC = AnalyticsViewController(.income)

    let previousVC = UIViewController()
    previousVC.title = "Главная"
    previousVC.view.backgroundColor = .systemGroupedBackground


    navController.setViewControllers([previousVC, analyticsVC], animated: false)

    return navController
}
