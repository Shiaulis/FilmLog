//
//  AppCore.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 27.11.2024.
//

import Foundation
import OSLog

final class AppCore {
    let databaseClient: DatabaseClient
    private let logger: Logger

    init() {
        self.databaseClient = DatabaseClient(containerName: "FilmLog")
        self.logger = Logger(subsystem: "com.shiaulis.FilmLog", category: "AppCore")
    }

    func applicationStarted() {
        do {
            self.logger.info("Starting application")
            try self.databaseClient.start()
        }
        catch {
            self.logger.error("Failed to start database client: \(error, privacy: .public)")
            fatalError("Failed to start database client")
        }
    }

    func applicationTerminated() {
        self.logger.info("Application terminated")
    }
}
