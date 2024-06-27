//
//  CoreStudent.swift
//  RealmVsCoreData
//
//  Created by Jacob Bartlett on 30/04/2024.
//

import Foundation
import ManagedModels

enum CoreDataError: Error {
    case dataNotFound
}

@Model
final class CoreStudent: NSManagedObject, User {
    
    @Attribute(.unique) var id: UUID
    var firstName: String
    var surname: String
    var age: Int
    @Relationship(deleteRule: .cascade, inverse: \CoreSchool.students) var school: CoreSchool?
    @Relationship(deleteRule: .cascade, inverse: \CoreGrade.student) var grades: [CoreGrade]
    
    convenience init(school: CoreSchool) throws {
        guard let firstName = firstNames.randomElement(),
              let surname = surnames.randomElement() else {
            throw CoreDataError.dataNotFound
        }
        self.init(firstName: firstName, surname: surname,
                  age: Int.random(in: 11..<18), grades: CoreGrade.randomGrades(in: school.modelContext))
    }
    
    convenience init(id: UUID = UUID(), firstName: String, surname: String, age: Int, grades: [CoreGrade]) {
        self.init(context: nil)
        self.id = id
        self.firstName = firstName
        self.surname = surname
        self.age = age
        self.grades = grades
        grades.forEach { $0.student = self }
    }
}

extension CoreStudent: CoreContextRegistrator {
    func insertWithAllDependencies(into context: ModelContext) {
        context.insert(self)
        if let school, !context.insertedObjects.contains(school) {
            context.insert(school)
        }
        precondition(!grades.isEmpty)
        grades.forEach { context.insert($0) }
    }
}

@Model
final class CoreSchool: NSManagedObject {
   
    enum SchoolError: Error {
        case dataNotFound
    }
    
    enum SchoolType: String, Codable, CaseIterable {
        case comprehensive
        case grammar
        case `private`
        case religious
    }
    
    @Attribute(.unique) var id: UUID
    var name: String
    var location: String
    var type: SchoolType
    var students: [CoreStudent]
    
    convenience init() {
        guard let name = schoolNames.randomElement(),
              let location = schoolLocations.randomElement(),
              let type = SchoolType.allCases.randomElement() else {
            //throw CoreDataError.dataNotFound
            fatalError("Data not found")
        }
        self.init(name: name, location: location, type: type)
    }
    
    convenience init(id: UUID = UUID(), name: String, location: String, type: SchoolType, students: [CoreStudent] = []) {
        self.init(context: nil)
        self.id = id
        self.name = name
        self.location = location
        self.type = type
        self.students = students
        students.forEach { $0.school = self }
    }
}

@Model
final class CoreGrade: NSManagedObject {
    
    enum Subject: String, CaseIterable, CustomStringConvertible {
        case maths
        case english
        case literature
        case physics
        case chemistry
        case biology
        case history
        case geography
        case french
        case german
        case music
        case art
        case physicalEducation
        case religiousStudies
        var description: String { rawValue }
    }
    
    enum Grade: String, CaseIterable, CustomStringConvertible {
        case aStar
        case a
        case b
        case c
        case d
        case e
        case f
        case u
        var description: String { rawValue }
    }
    
    enum ExamBoard: String, CaseIterable, CustomStringConvertible {
        case aqa
        case edexcel
        case ocr
        var description: String { rawValue }
    }
    
    @Attribute(.unique) var id: UUID
    // CoreData macros and predicates don't behave well with enums
    var subject: Subject
    var grade: Grade
    var examBoard: ExamBoard
    var student: CoreStudent?
    
    convenience init() {
        guard let subject = Subject.allCases.randomElement(),
              let grade = Grade.allCases.randomElement(),
              let examBoard = ExamBoard.allCases.randomElement() else {
            //throw CoreDataError.dataNotFound
            fatalError("Data not found")
        }
        self.init(subject: subject, examBoard: examBoard, grade: grade)
    }
    
    convenience init(id: UUID = UUID(), subject: Subject, examBoard: ExamBoard, grade: Grade) {
        self.init(context: nil)
        self.id = id
        self.subject = subject
        self.examBoard = examBoard
        self.grade = grade
    }
    
    static func randomGrades(in ctx: ModelContext?) -> [CoreGrade] {
        let max = Int.random(in: 1..<7)
        return (0...max).compactMap { _ in
            CoreGrade()
        }
    }
}
