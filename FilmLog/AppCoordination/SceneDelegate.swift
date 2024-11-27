//
//  SceneDelegate.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 23.11.2024.
//

import OSLog
import UIKit

final class SceneCoordinator: UIResponder, UIWindowSceneDelegate {
    // MARK: - Properties -

    var window: UIWindow?
    private let factory: SceneFactory
    private let logger: Logger

    // MARK: - Initializers -

    override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.factory = SceneFactory(appCore: appDelegate.appCore)
        self.logger = Logger(subsystem: "com.shiaulis.FilmLog", category: "SceneCoordinator")
    }

    // MARK: - UIWindowSceneDelegate -

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = self.factory.makeFilmListViewController()
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_: UIScene) {
        self.logger.info("Scene did enter background")
    }

    func sceneWillEnterForeground(_: UIScene) {
        self.logger.info("Scene will enter foreground")
    }

    func sceneDidBecomeActive(_: UIScene) {
        self.logger.info("Scene did become active")
    }

    func sceneWillResignActive(_: UIScene) {
        self.logger.info("Scene will resign active")
    }
}
