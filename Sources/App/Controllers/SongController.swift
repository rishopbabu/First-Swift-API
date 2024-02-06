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
    }
    
    
    func index(req: Request) async throws -> [Song] {
        try await Song.query(on: req.db).all()
    }
    
}
