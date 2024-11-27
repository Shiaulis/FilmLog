//
//  DatabaseClient.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 24.11.2024.
//

import CoreData
import Foundation
import OSLog

final class DatabaseClient {
    enum Error: Swift.Error {
        case entityNotFound
        case failedToCreateEntity(name: String)
    }

    // MARK: - Properties -

    private let persistentContainer: NSPersistentContainer
    private let logger: Logger

    // MARK: - Initializers -

    init(containerName: String) {
        self.persistentContainer = NSPersistentContainer(name: containerName)
        self.logger = Logger(subsystem: "com.shiaulis.FilmLog", category: "DatabaseClient")
    }

    func start() throws {
        self.logger.info("Starting database client")
        try loadPersistentStores()
    }

    // MARK: - Private -

    private func loadPersistentStores() throws {
        var loadError: Swift.Error?
        self.persistentContainer.loadPersistentStores { _, error in
            loadError = error
        }

        if let loadError {
            self.logger.error("Failed to load persistent stores: \(loadError, privacy: .public)")
            throw loadError
        }
        else {
            self.logger.info("Persistent stores loaded successfully")
        }
    }

    // MARK: - Core Data Operations

    /// Save changes to the context
    func save() throws {
        let mainContext = self.persistentContainer.viewContext
        guard mainContext.hasChanges else { return }
        try mainContext.save()
    }

    /// Fetch entities of a specific type
    func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil) throws -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate

        return try self.persistentContainer.viewContext.fetch(fetchRequest)
    }

    /// Create a new entity
    func create<T: NSManagedObject>(_ objectType: T.Type) throws -> T {
        let entityName = String(describing: objectType)
        let context = self.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw Error.failedToCreateEntity(name: entityName)
        }

        return T(entity: entity, insertInto: context)
    }

    /// Delete an entity
    func delete(_ object: NSManagedObject) throws {
        self.persistentContainer.viewContext.delete(object)
        try save()
    }

    func makeFilmListPublisher() -> CoreDataFetchPublisher<FLFilm> {
        let fetchRequest: NSFetchRequest<FLFilm> = FLFilm.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FLFilm.title, ascending: true)]
        let context = self.persistentContainer.viewContext
        return CoreDataFetchPublisher(fetchRequest: fetchRequest, context: context)
    }
}
