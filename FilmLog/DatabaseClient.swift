//
//  DatabaseClient.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 24.11.2024.
//

import CoreData
import Foundation

final class DatabaseClient {
    enum Error: Swift.Error {
        case entityNotFound
        case failedToCreateEntity(name: String)
    }

    // MARK: - Core Data Stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FilmLog")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    private var mainContext: NSManagedObjectContext {
        self.persistentContainer.viewContext
    }

    // MARK: - Core Data Operations

    /// Save changes to the context
    func save() throws {
        guard self.mainContext.hasChanges else { return }
        try self.mainContext.save()
    }

    /// Fetch entities of a specific type
    func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil) throws -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate

        return try self.mainContext.fetch(fetchRequest)
    }

    /// Create a new entity
    func create<T: NSManagedObject>(_ objectType: T.Type) throws -> T {
        let entityName = String(describing: objectType)
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.mainContext) else {
            throw Error.failedToCreateEntity(name: entityName)
        }

        return T(entity: entity, insertInto: self.mainContext)
    }

    /// Delete an entity
    func delete(_ object: NSManagedObject) throws {
        self.mainContext.delete(object)
        try save()
    }

    func makeFilmListPublisher() -> CoreDataFetchPublisher<FLFilm> {
        let fetchRequest: NSFetchRequest<FLFilm> = FLFilm.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FLFilm.title, ascending: true)]
        return CoreDataFetchPublisher(fetchRequest: fetchRequest, context: self.mainContext)
    }
}
