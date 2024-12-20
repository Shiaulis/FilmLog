//
//  FilmListViewController.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 23.11.2024.
//

import Combine
import UIKit

final class FilmListViewController: UICollectionViewController {
    enum Section {
        case main
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Film.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Film.ID>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, UUID>

    private let viewModel: FilmListViewModel
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, UUID>!
    private var disposables: Set<AnyCancellable> = []

    init(viewModel: FilmListViewModel) {
        self.viewModel = viewModel

        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)

        super.init(collectionViewLayout: layout)
        self.title = "Film Rolls"

        let uiAction = UIAction { [weak self] _ in
            self?.viewModel.addFilm()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: uiAction)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        bindViewModel()
    }

    // MARK: - Data Source Configuration

    private func configureDataSource() {
        let cellRegistration = CellRegistration { [weak self] cell, _, id in
            guard let self, let film = self.viewModel.getFilm(for: id) else {
                fatalError("No film found for ID: \(id)")
            }

            var content = cell.defaultContentConfiguration()
            content.text = film.title
            content.secondaryText = "Brand: \(film.brand), ISO: \(film.iso)"
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
            cell.contentConfiguration = content
        }

        self.diffableDataSource =
            DataSource(collectionView: collectionView) { collectionView, indexPath, id -> UICollectionViewCell? in
                collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: id)
            }
    }

    private func bindViewModel() {
        self.viewModel.makeFilmIDsPublisher()
            .sink(receiveCompletion: { completion in
                assertionFailure("Failed to receive film IDs: \(completion)")
            }, receiveValue: { value in
                self.applySnapshot(value)
            })
            .store(in: &self.disposables)
    }

    // MARK: - Snapshot

    private func applySnapshot(_ ids: [Film.ID]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(ids, toSection: .main)

        self.diffableDataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Item Selection

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        self.viewModel.selectFilm(with: id)
    }
}
