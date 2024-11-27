//
//  AppDelegate.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 23.11.2024.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    let appCore = AppCore()

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.appCore.applicationStarted()
        return true
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    func applicationWillTerminate(_: UIApplication) {
        self.appCore.applicationTerminated()
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
