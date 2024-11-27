//
//  SceneFactory.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 28.11.2024.
//

import Foundation
import UIKit

final class SceneFactory {
    private let appCore: AppCore

    init(appCore: AppCore) {
        self.appCore = appCore
    }

    func makeFilmListViewController() -> UIViewController {
        let controller = FilmListController(databaseClient: self.appCore.databaseClient)
        let viewModel = FilmListViewModel(controller: controller)
        let viewController = FilmListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
