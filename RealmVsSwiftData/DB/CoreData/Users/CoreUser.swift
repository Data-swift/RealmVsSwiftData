//
//  User.swift
//  RealmVsCoreData
//
//  Created by Jacob Bartlett on 02/04/2024.
//

import Foundation
import ManagedModels

@Model
final class CoreUser: NSManagedObject, User {
    
    enum UserError: Error {
        case nameNotFound
    }
    
    @Attribute(.unique) var id: UUID
    var firstName: String
    var surname: String
    var age: Int
    
    convenience init() {
        guard let firstName = firstNames.randomElement(),
              let surname = surnames.randomElement() else {
            //throw UserError.nameNotFound
            fatalError("Name not found")
        }
        self.init(firstName: firstName, surname: surname, age: Int.random(in: 0..<99))
    }
	
	convenience init(moc: ModelContext? = nil) {
		guard let firstName = firstNames.randomElement(),
			  let surname = surnames.randomElement() else {
			//throw UserError.nameNotFound
			fatalError("Name not found")
		}
		self.init(context: moc, firstName: firstName, surname: surname, age: Int.random(in: 0..<99))
	}
    
	convenience init(context: ModelContext? = nil, firstName: String, surname: String, age: Int) {
        self.init(context: context)
        self.id = UUID()
        self.firstName = firstName
        self.surname = surname
        self.age = age
    }
}

extension CoreUser: CoreContextRegistrator {
    func insertWithAllDependencies(into context: ModelContext) {
        context.insert(self)
    }
}
