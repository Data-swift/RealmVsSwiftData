//
//  SwiftUsersTests.swift
//  RealmVsSwiftData
//
//  Created by Jacob Bartlett on 02/05/2024.
//

import Foundation
import SwiftData

func swiftUsersPerformanceTests(with usersCount: Int = 100_000) {
    
    announce("SwiftData: \(formatNumberWithCommas(usersCount)) Simple Objects")
    
    let db = try! SwiftUserDB()
    
    try! db.deleteAll()
    
    var users = [SwiftUser]()
    logExecutionTime("User instantiation") {
        users = (0..<usersCount).compactMap { _ in try! SwiftUser() }
    }
    
    logExecutionTime("Create users") {
        try! db.create(users)
    }
    
    logExecutionTime("Fetch users named `Jane` in age order") {
        let predicate = #Predicate<SwiftUser> { $0.firstName == "Jane" }
        let janes = try! db.read(predicate: predicate, sortBy: SortDescriptor(\.age))
        print("\(janes.count) users named Jane")
    }
    
    logExecutionTime("Rename users named `Jane` to `Wendy`") {
        let predicate = #Predicate<SwiftUser> { $0.firstName == "Jane" }
        try! db.update { context in
            let fetchDescriptor = FetchDescriptor<SwiftUser>(predicate: predicate)
            let janes = try context.fetch(fetchDescriptor)
            for jane in janes {
                jane.firstName = "Wendy"
            }
            try context.save()
            print("\(janes.count) users renamed to `Wendy`")
        }
    }
    
    measureSize(of: db)
    
    logExecutionTime("Delete all users") {
        try! db.deleteAll()
    }
}
