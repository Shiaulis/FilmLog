//
//  FilmListViewModel.swift
//  FilmLog
//
//  Created by Andrius Shiaulis on 24.11.2024.
//

import Foundation
import Combine

/// Represents a film roll for analog photography
struct Film: Identifiable {
    let id: UUID
    let title: String  // Film name or identifier
    let brand: String  // Film brand (e.g., Kodak, Fujifilm)
    let iso: Int       // ISO rating of the film
}

final class FilmListViewModel {

    // MARK: - Properties

    private let controller: FilmListController

    private var selectedFilmID: Film.ID? {
        didSet {
            print("Selected film ID: \(selectedFilmID?.uuidString ?? "nil")")
        }
    }

    // MARK: - Init -
    init(controller: FilmListController) {
        self.controller = controller
    }

    // MARK: - Public Methods

    func makeFilmIDsPublisher() -> any Publisher<[Film.ID], Never> {
        self.controller.makeFilmListPublisher()
    }

    func getFilm(for id: UUID) -> Film? {
        do {
            return try self.controller.getFilm(for: id)
        }
        catch {
            fatalError("No film found for ID: \(id)")
        }
    }

    func selectFilm(with id: UUID) {
        self.selectedFilmID = id
    }

    func addFilm() {
        self.controller.addFilm()
    }

}
