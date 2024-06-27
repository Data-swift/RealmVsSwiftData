//
//  CoreDatabase.swift
//  RealmVsCoreData
//
//  Created by Jacob Bartlett on 03/04/2024.
//

import Foundation
import ManagedModels

protocol CoreContextRegistrator: NSManagedObject {
    func insertWithAllDependencies(into context: ModelContext)
}

protocol CoreDatabase<T>: Database
where T: NSManagedObject & CoreContextRegistrator,
      Sorting == NSSortDescriptor,
      Filtering == NSPredicate {
    var container: ModelContainer { get }
    static var configuration: ModelConfiguration { get }
    func update(execute: ( ModelContext ) throws -> Void) throws
}

extension CoreDatabase {
  
    
    var fileURL: URL? {
        container.configurations.first?.url
    }
    
    func create(_ items: [T]) throws {
        let context = ModelContext(container)
        items.forEach { $0.insertWithAllDependencies(into: context) }
        try context.save()
    }
    
    func create(_ item: T) throws {
        let context = ModelContext(container)
        item.insertWithAllDependencies(into: context)
        try context.save()
    }
    
    func read(predicate: Filtering?, sortBy sortDescriptors: [NSSortDescriptor]) throws -> [T] {
        let context = ModelContext(container)
        let fetchDescriptor = NSFetchRequest<T>()
        fetchDescriptor.entity = T.entity()
        if let predicate {
            fetchDescriptor.predicate = predicate
        }
        fetchDescriptor.sortDescriptors = sortDescriptors
        return try context.fetch(fetchDescriptor)
    }
    
    func update(execute: ( ModelContext ) throws -> Void) throws {
        let context = ModelContext(container)
        try execute(context)
        try context.save()
    }
    
    func delete(_ item: T) throws {
        let context = ModelContext(container)
        context.delete(item)
        try context.save()
    }
    
    func delete(_ items: [T]) throws {
        let context = ModelContext(container)
        let deleteRequest = NSBatchDeleteRequest(objectIDs: items.map(\.objectID))
        try context.execute(deleteRequest)
        try context.save()
    }
    
    func deleteAll() throws { // no bulk delete in CD?
        let context = ModelContext(container)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: T.fetchRequest())
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error as NSError {
            print("Could not delete all data. \(error), \(error.userInfo)")
            fatalError("Did not delete all data")
        }
    }
}
