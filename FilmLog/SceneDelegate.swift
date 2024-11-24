//
//  SceneDelegate.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 23.11.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let controller = InMemoryFilmListController()
        let viewModel = FilmListViewModel(controller: controller)
        let viewController = FilmListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        self.window!.rootViewController = navigationController
        self.window!.makeKeyAndVisible()
    }

}
