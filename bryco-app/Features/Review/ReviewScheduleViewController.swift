import SwiftUI
import UIKit

/// The review schedule, built in UIKit with View Code: no storyboard, Auto Layout in code,
/// a list-style compositional layout and a diffable data source.
final class ReviewScheduleViewController: UIViewController {

    nonisolated private enum Section: Int, CaseIterable, Sendable {
        case dueNow
        case upcoming

        var title: String {
            switch self {
            case .dueNow: "Para revisar agora"
            case .upcoming: "Próximas revisões"
            }
        }
    }

    private var schedule: ReviewSchedule
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private var dataSource: UICollectionViewDiffableDataSource<Section, ReviewScheduleItem>!

    init(schedule: ReviewSchedule) {
        self.schedule = schedule
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; this screen is built in code.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(BryqoTheme.background)
        setUpCollectionView()
        configureDataSource()
        apply(schedule, animated: false)
    }

    /// Replaces the schedule, animating row changes through the diffable data source.
    func update(with schedule: ReviewSchedule) {
        guard schedule != self.schedule else { return }
        self.schedule = schedule
        apply(schedule, animated: true)
    }

    // MARK: - Layout

    private func setUpCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .clear
        configuration.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }

    // MARK: - Data

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ReviewScheduleItem> { cell, _, item in
            var content = UIListContentConfiguration.subtitleCell()
            content.text = item.title
            content.secondaryText = item.detail
            content.image = UIImage(systemName: item.isDue ? "arrow.triangle.2.circlepath" : "calendar")
            content.imageProperties.tintColor = item.isDue ? UIColor(BryqoTheme.river) : UIColor(BryqoTheme.textSecondary)
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.textProperties.color = UIColor(BryqoTheme.textPrimary)
            content.secondaryTextProperties.color = UIColor(BryqoTheme.textSecondary)
            cell.contentConfiguration = content

            var background = UIBackgroundConfiguration.listCell()
            background.backgroundColor = UIColor(BryqoTheme.surface)
            cell.backgroundConfiguration = background
            cell.accessibilityLabel = "\(item.title), \(item.detail)"
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else { return }
            var content = UIListContentConfiguration.header()
            content.text = section.title
            header.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }

    private func apply(_ schedule: ReviewSchedule, animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ReviewScheduleItem>()
        for section in Section.allCases {
            let items = section == .dueNow ? schedule.dueNow : schedule.upcoming
            guard !items.isEmpty else { continue }
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
        setNeedsUpdateContentUnavailableConfiguration()
    }

    // MARK: - Empty state

    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        guard schedule.isEmpty else {
            contentUnavailableConfiguration = nil
            return
        }
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.image = UIImage(systemName: "calendar.badge.checkmark")
        configuration.text = "Nenhuma revisão agendada"
        configuration.secondaryText = "Conclua uma lição e ela volta aqui no momento certo para você revisar."
        contentUnavailableConfiguration = configuration
    }
}
