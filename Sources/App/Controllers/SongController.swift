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
    }
    
    
    func index(req: Request) async throws -> [Song] {
        try await Song.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Song {
        let song = try req.content.decode(Song.self)
        try await song.save(on: req.db)
        return song
    }
    
}
