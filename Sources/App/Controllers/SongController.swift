//
//  SongController.swift
//
//
//  Created by Rishop Babu on 06/02/24.
//

import Fluent
import Vapor

struct SongController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws  {
        let songs = routes.grouped("songs")
        songs.get(use: index)
        songs.post(use: create)
        songs.get(":title", use: show)
        songs.put(":title", use: update)
        songs.delete(":title", use: delete)
    }
    
    
    func index(req: Request) async throws -> GetAllResponse {
        do {
            let songs = try await Song.query(on: req.db).all()
            if songs.isEmpty {
                return GetAllResponse(status: .notFound, message: "The requested Song is not in the List")
            }
            return GetAllResponse(status: .ok, message: "Fetched all songs.", allSongs: songs)
        } catch {
            return GetAllResponse(status: .internalServerError, message: "Failed to fetch songs: \(error)")
        }
    }
    
    func create(req: Request) async throws -> AddedResponse {
        do {
            let song = try req.content.decode(Song.self)
            try await song.save(on: req.db)
            return AddedResponse(status: .accepted, message: "Data created successfully", addedSong: song)
        } catch {
            return AddedResponse(status: .internalServerError, message: "Failed to create data: \(error)")
        }
    }
    
    func show(req: Request) async throws -> GetOneResponse {
        guard let title = req.parameters.get("title") else {
            return GetOneResponse(status: .badRequest, message: "Title parameter is missing")
        }
        
        guard let song = try await Song.query(on: req.db)
            .filter(\.$title == title)
            .first() else {
            return GetOneResponse(status: .notFound, message: "The requested Song is not in the List")
        }
        return GetOneResponse(status: .ok, message: "Fetched succesfully", song: song)
    }
    
    func update(req: Request) async throws -> UpdateResponse {
        guard let title = req.parameters.get("title") else {
            //throw Abort(.badRequest, reason: "Title parameter is missing")
            return UpdateResponse(status: .badRequest, message: "Title parameter is missing")
        }
        
        guard let song = try await Song.query(on: req.db)
            .filter(\.$title == title)
            .first() else {
            return UpdateResponse(status: .notFound, message: "The requested Song is not in the List")
        }
        
        let updateSong = try req.content.decode(Song.self)
        song.title = updateSong.title
        try await song.save(on: req.db)
        return UpdateResponse(status: .ok, message: "Updated succesfully", updatedSong: song)
    }
    
    func delete(req: Request) async throws -> DeleteResponse {
        guard let title = req.parameters.get("title") else {
            return DeleteResponse(status: .badRequest, message: "Title parameter is missing")
        }
        
        guard let song = try await Song.query(on: req.db)
            .filter(\.$title == title)
            .first() else {
            return DeleteResponse(status: .notFound, message: "The requested Song is not in the List")
        }
        
        try await song.delete(on: req.db)
        return DeleteResponse(status: .ok, message: "Deleted succesfully", deletedSong: song)
    }
    
}


struct DeleteResponse: Content {
    let status: HTTPStatus
    let message: String
    let deletedSong: Song?
    
    init(status: HTTPStatus, message: String, deletedSong: Song? = nil) {
        self.status = status
        self.message = message
        self.deletedSong = deletedSong
    }
}

struct UpdateResponse: Content {
    let status: HTTPStatus
    let message: String
    let updatedSong: Song?
    
    init(status: HTTPStatus, message: String, updatedSong: Song? = nil) {
        self.status = status
        self.message = message
        self.updatedSong = updatedSong
    }
}
struct AddedResponse: Content {
    let status: HTTPStatus
    let message: String
    let addedSong: Song?
    
    init(status: HTTPStatus, message: String, addedSong: Song? = nil) {
        self.status = status
        self.message = message
        self.addedSong = addedSong
    }
}

struct GetAllResponse: Content {
    let status: HTTPStatus
    let message: String
    let allSongs: [Song]?
    
    init(status: HTTPStatus, message: String, allSongs: [Song]? = nil) {
        self.status = status
        self.message = message
        self.allSongs = allSongs
    }
}

struct GetOneResponse: Content {
    let status: HTTPStatus
    let message: String
    let song: Song?
    
    init(status: HTTPStatus, message: String, song: Song? = nil) {
        self.status = status
        self.message = message
        self.song = song
    }
}
