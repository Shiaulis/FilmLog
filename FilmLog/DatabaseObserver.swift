//
//  DatabaseObserver.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 24.11.2024.
//

import Combine
import CoreData
import Foundation

struct CoreDataFetchPublisher<Entity: NSManagedObject>: Publisher {
    typealias Output = [Entity]
    typealias Failure = NSError

    private let fetchRequest: NSFetchRequest<Entity>
    private let context: NSManagedObjectContext

    init(fetchRequest: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        self.context = context
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = FetchSubscription(subscriber: subscriber, fetchRequest: fetchRequest, context: context)
        subscriber.receive(subscription: subscription)
    }

    private final class FetchSubscription<S: Subscriber>: NSObject, Subscription, NSFetchedResultsControllerDelegate where S.Input == [Entity], S.Failure == NSError {
        private var subscriber: S?
        private let context: NSManagedObjectContext
        private let fetchedResultsController: NSFetchedResultsController<Entity>

        init(subscriber: S, fetchRequest: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
            self.subscriber = subscriber
            self.context = context
            self.fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            self.fetchedResultsController.delegate = self
            performFetch()
        }

        func request(_: Subscribers.Demand) {
            // No backpressure handling is needed; updates are pushed automatically.
        }

        func cancel() {
            subscriber = nil
        }

        private func performFetch() {
            do {
                try fetchedResultsController.performFetch()
                sendCurrentResults()
            }
            catch let error as NSError {
                subscriber?.receive(completion: .failure(error))
            }
        }

        private func sendCurrentResults() {
            guard let results = fetchedResultsController.fetchedObjects else { return }
            _ = subscriber?.receive(results)
        }

        // MARK: - NSFetchedResultsControllerDelegate

        func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
            sendCurrentResults()
        }
    }
}
