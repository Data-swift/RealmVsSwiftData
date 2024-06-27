//
//  CoreUsersTests.swift
//  RealmVsCoreData
//
//  Created by Jacob Bartlett on 02/05/2024.
//

import Foundation
import ManagedModels

func coreUsersPerformanceTests(with usersCount: Int = 100_000) {
    
    announce("CoreData: \(formatNumberWithCommas(usersCount)) Simple Objects")
    
    let db = try! CoreUserDB()
    
    try! db.deleteAll()
    
    var users = [CoreUser]()
    logExecutionTime("User instantiation") {
        users = (0..<usersCount).compactMap { _ in CoreUser() }
    }
    
    logExecutionTime("Create users") {
        try! db.create(users)
    }
    
    logExecutionTime("Fetch users named `Jane` in age order") {
        let predicate = NSPredicate(format: "firstName = %@", "Jane")
        let janes = try! db.read(predicate: predicate, sortBy: NSSortDescriptor(key: "age", ascending: true))
        print("\(janes.count) users named `Jane`")
    }
    
    logExecutionTime("Rename users named `Jane` to `Wendy`") {
        let predicate = NSPredicate(format: "firstName = %@", "Jane")
        
        try! db.update { ctx in
            let fetchDescriptor = NSFetchRequest<CoreUser>()
            fetchDescriptor.entity = CoreUser.entity()
            fetchDescriptor.predicate = predicate
            let janes = try ctx.fetch(fetchDescriptor)
            print("\(janes.count) users named `Jane` being renamed to `Wendy`")
            for jane in janes {
                jane.firstName = "Wendy"
            }
            try ctx.save()
            print("\(janes.count) users renamed to `Wendy`")
        }
    }
    
    measureSize(of: db)
    
    logExecutionTime("Delete all users") {
        try! db.deleteAll()
    }
}
