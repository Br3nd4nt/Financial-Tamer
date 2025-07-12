//
//  AnalysisViewController.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 10.07.2025.
//

import UIKit

final class AnalyticsViewController: UIViewController {
    private let titleLabel = UILabel()
    private let headerView = AnalyticsHeaderView()
    private let tableTitleLabel = UILabel()
    private let categoriesTableView = UITableView(frame: .zero)
    private let viewModel: AnalyticsViewModel
    private var tableViewHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.backgroundColor = .systemGroupedBackground
        makeTitle()
        makeHeader()
        makeTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.loadTransactions() // ????
            reloadData()
        }
    }

    init(_ direction: Direction) {
//        viewModel = AnalyticsViewModel(direction: direction, startDate: Date(timeIntervalSince1970: 0))
        viewModel = AnalyticsViewModel(direction: direction)
        headerView.startDatePicker!.date = viewModel.dayStart
        super.init(nibName: nil, bundle: nil)
        viewModel.onReloadData = reloadData
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeTitle() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 10)
        titleLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, 10)
        titleLabel.text = "Анализ"
        titleLabel.textColor = .label
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
    }

    private func makeHeader() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.pinTop(to: titleLabel.bottomAnchor, 10)
        headerView.pinLeft(to: view)
        headerView.pinRight(to: view)
        guard let startDatePicker = headerView.startDatePicker else {
            return
        }
        startDatePicker.addTarget(viewModel, action: #selector(viewModel.startDateChanged), for: .valueChanged)
        guard let endDatePicker = headerView.endDatePicker else {
            return
        }
        endDatePicker.addTarget(viewModel, action: #selector(viewModel.endDateChanged), for: .valueChanged)
    }

    private func makeTable() {
        view.addSubview(tableTitleLabel)
        tableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableTitleLabel.pinTop(to: headerView.bottomAnchor, 10)
        tableTitleLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, 10)

        tableTitleLabel.text = "Категории"
        tableTitleLabel.textColor = .secondaryLabel

        view.addSubview(categoriesTableView)
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        categoriesTableView.pinTop(to: tableTitleLabel.bottomAnchor, 5)
        categoriesTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, 10)
        categoriesTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, 10)
        tableViewHeightConstraint = categoriesTableView.setHeight(100)
        categoriesTableView.backgroundColor = .systemBackground
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.separatorStyle = .singleLine
        categoriesTableView.isScrollEnabled = false
        categoriesTableView.allowsSelection = false
        categoriesTableView.register(AnalyticsCategoryCell.self, forCellReuseIdentifier: AnalyticsCategoryCell.reuseId)
    }

    private func reloadData() {
        tableTitleLabel.isHidden = viewModel.categoryRows.isEmpty
        categoriesTableView.isHidden = viewModel.categoryRows.isEmpty
        categoriesTableView.reloadData()
        headerView.changeTotal(viewModel.total)
        updateTableViewHeight()
    }

    private func updateTableViewHeight() {
        categoriesTableView.layoutIfNeeded()
        let contentHeight = categoriesTableView.contentSize.height
        let maxHeight = view.bounds.height
            - headerView.frame.maxY
            - tableTitleLabel.frame.height
            - view.safeAreaInsets.bottom
            - 20

        if contentHeight < maxHeight {
            tableViewHeightConstraint?.constant = contentHeight
            categoriesTableView.isScrollEnabled = false
        } else {
            tableViewHeightConstraint?.constant = maxHeight
            categoriesTableView.isScrollEnabled = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
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
