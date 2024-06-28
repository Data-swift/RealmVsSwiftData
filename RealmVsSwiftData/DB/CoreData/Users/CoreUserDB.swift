//
//  CoreUserDB.swift
//  RealmVsCoreData
//
//  Created by Jacob Bartlett on 02/04/2024.
//

import Foundation
import ManagedModels

final class CoreUserDB: CoreDatabase {    
    
    static let schema = Schema([ CoreUser.self ], version: .init(1, 0, 0))
    static let configuration = ModelConfiguration(name: "CoreUserDB", schema: schema, isStoredInMemoryOnly: false)

    typealias T = CoreUser
    
    let container : ModelContainer

    init() throws {
        container = try ModelContainer(for: Self.schema, configurations: Self.configuration)
    }
}
