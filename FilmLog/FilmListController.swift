//
//  FilmListController.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 24.11.2024.
//

import Combine
import CoreData
import Foundation

final class FilmListController {
    enum Error: Swift.Error {
        case filmNotFound
    }

    private let databaseClient = DatabaseClient()

    // MARK: - Publisher for Film List

    func makeFilmListPublisher() -> any Publisher<[Film.ID], NSError> {
        let fetchPublisher: CoreDataFetchPublisher<FLFilm> = databaseClient.makeFilmListPublisher()
        return fetchPublisher.map { films in
            print()
            return films.map(\.id!)
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Get a Film by ID

    func getFilm(for id: Film.ID) throws -> Film {
        // Fetch the film with the given ID from the database
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let fetchedFilms: [FLFilm] = try databaseClient.fetch(FLFilm.self, predicate: predicate)

        guard let fetchedFilm = fetchedFilms.first else {
            throw Error.filmNotFound
        }

        // Map FLFilm (CoreData model) to Film (Swift model)
        return Film(id: fetchedFilm.id!, title: fetchedFilm.title!, brand: fetchedFilm.brand!, iso: fetchedFilm.iso!)
    }

    // MARK: - Add a New Film

    func addFilm(title: String, brand: String, iso: Int) throws {
        // Create a new film in Core Data
        let newFilm: FLFilm = try databaseClient.create(FLFilm.self)
        newFilm.id = UUID()
        newFilm.title = title
        newFilm.brand = brand
        newFilm.iso = "\(iso)"

        // Save changes to the database
        try databaseClient.save()
    }
}
