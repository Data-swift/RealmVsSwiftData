//
//  CoreStudentDB.swift
//  RealmVsCoreData
//
//  Created by Jacob Bartlett on 30/04/2024.
//

import Foundation
import ManagedModels

final class CoreStudentDB: CoreDatabase {
    
    static let schema = Schema.model(for: [ CoreStudent.self, CoreSchool.self, CoreGrade.self ])
    static let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    typealias T = CoreStudent
    
    let container : ModelContainer

    init() throws {
        container = try ModelContainer(for: Self.schema, configurations: Self.configuration)
    }
}
