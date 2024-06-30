//
//  SwiftDatabase.swift
//  RealmVsSwiftData
//
//  Created by Jacob Bartlett on 03/04/2024.
//

import Foundation
import SwiftData

protocol SwiftDatabase<T>: Database 
where T: PersistentModel,
      Sorting == SortDescriptor<T>,
      Filtering == Predicate<T> {
    var container: ModelContainer { get }
    func update(execute: ( ModelContext ) throws -> Void) throws
}

extension SwiftDatabase {
    
    var fileURL: URL? {
        container.configurations.first?.url
    }
    
    func create(_ items: [T]) throws {
        let context = ModelContext(container)
        for item in items {
            context.insert(item)
        }
        try context.save()
    }
    
    func create(_ item: T) throws {
        let context = ModelContext(container)
        context.insert(item)
        try context.save()
    }
    
    func read(predicate: Filtering?, sortBy sortDescriptors: [SortDescriptor<T>]) throws -> [T] {
        let context = ModelContext(container)
        if let predicate {
            let fetchDescriptor = FetchDescriptor<T>(
                predicate: predicate,
                sortBy: sortDescriptors
            )
            return try context.fetch(fetchDescriptor)
            
        } else {
            let fetchDescriptor = FetchDescriptor<T>(
                sortBy: sortDescriptors
            )
            return try context.fetch(fetchDescriptor)
        }
    }
    
    func update(execute: ( ModelContext ) throws -> Void) throws {
        let context = ModelContext(container)
        try execute(context)
        try context.save()
    }
    
    func delete(_ item: T) throws {
        let context = ModelContext(container)
        let idToDelete = item.persistentModelID
        try context.delete(model: T.self, where: #Predicate { item in
            item.persistentModelID == idToDelete
        })
        try context.save()
    }
    
    func delete(_ items: [T]) throws {
        let context = ModelContext(container)
        let idsToDelete = Set(items.map { $0.persistentModelID })
        try context.delete(model: T.self, where: #Predicate { item in
            idsToDelete.contains(item.persistentModelID)
        })
        try context.save()
    }
    
    func deleteAll() throws {
        let context = ModelContext(container)
        try context.delete(model: T.self)
        try context.save()
    }
}
