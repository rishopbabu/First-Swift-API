//
//  CreateSongs.swift
//
//
//  Created by Rishop Babu on 06/02/24.
//

import Fluent

struct CreateSongs: AsyncMigration {
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("songs").delete()
    }
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema("songs")
            .id()
            .field("title", .string, .required)
            .create()
    }
}
