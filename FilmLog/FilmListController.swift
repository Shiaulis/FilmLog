//
//  FilmListController.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 24.11.2024.
//

import Foundation
import Combine

protocol FilmListController {

    func makeFilmListPublisher() -> any Publisher<[Film.ID], Never>
    func getFilm(for id: Film.ID) throws -> Film
    func addFilm()

}

final class InMemoryFilmListController: FilmListController {

    enum Error: Swift.Error {
        case filmNotFound
    }

    private var inMemoryDatabase: [Film] = [
        Film(id: UUID(), title: "Kodak Portra 400", brand: "Kodak", iso: 400),
        Film(id: UUID(), title: "Fujifilm Pro 400H", brand: "Fujifilm", iso: 400),
        Film(id: UUID(), title: "Ilford HP5 Plus", brand: "Ilford", iso: 400),
        Film(id: UUID(), title: "YKodak Tri-X 400", brand: "Kodak", iso: 400),
    ]

    private var subject = CurrentValueSubject<[Film.ID], Never>([])

    func makeFilmListPublisher() -> any Publisher<[Film.ID], Never> {
        sendUpdate()
        return self.subject.eraseToAnyPublisher()
    }

    func getFilm(for id: Film.ID) throws -> Film {
        guard let film = self.inMemoryDatabase.first(where: { $0.id == id }) else {
            throw Error.filmNotFound
        }

        return film
    }

    func addFilm() {
        let film = Film(id: UUID(), title: "New Film", brand: "Generic", iso: 100)
        self.inMemoryDatabase.append(film)
        sendUpdate()
    }

    private func sendUpdate() {
        self.inMemoryDatabase.sort(by: { $0.title < $1.title })
        self.subject.send(self.inMemoryDatabase.map(\.id))
    }

}
