//
//  CoreStudentsTests.swift
//  RealmVsCoreData
//
//  Created by Jacob Bartlett on 02/05/2024.
//

import Foundation
import ManagedModels

func coreStudentsPerformanceTests(with studentsCount: Int = 10_000) {
    
    announce("CoreData: \(formatNumberWithCommas(studentsCount)) Complex Objects")
        
    let db = try! CoreStudentDB()
    try! db.deleteAll()
    var students = [CoreStudent]()
    
    logExecutionTime("Student instantiation") {
        let schoolCount = 100
        let firstSchool = CoreSchool(name: "Falconwood College", location: "Falconwood", type: .comprehensive)
        let schools = [firstSchool] + (1..<schoolCount).compactMap { _ in CoreSchool() }
        let studentsPerSchool = max(1, studentsCount / schoolCount)
        for school in schools {
            students.append(contentsOf: (0..<studentsPerSchool).compactMap { _ in try! CoreStudent(school: school) })
        }
    }

    logExecutionTime("Create students") {
        try! db.create(students)
        print("Created \(students.count) students.")
    }

    logExecutionTime("Read students with A* in Physics") {
        let physics = CoreGrade.Subject.physics
        let aStarGrade = CoreGrade.Grade.aStar
        
        let predicate = NSPredicate(
            format: "SUBQUERY(grades, $grade, $grade.subject = %@ AND $grade.grade = %@).@count > 0",
            argumentArray: [ physics, aStarGrade ]
        )
        let studentsWithAStarInPhysics = try! db.read(predicate: predicate)
        print("\(studentsWithAStarInPhysics.count) students with an A* in Physics")
    }
    
    logExecutionTime("Fail the cheating Maths students") {
        let maths = CoreGrade.Subject.maths
        let predicate = NSPredicate(
            format: "school.name == %@ AND SUBQUERY(grades, $grade, $grade.subject = %@).@count > 0",
            argumentArray: [ "Falconwood College", maths ]
        )
        
        try! db.update { context in
            let fetchDescriptor = NSFetchRequest<CoreStudent>()
            fetchDescriptor.entity = CoreStudent.entity()
            fetchDescriptor.predicate = predicate
            let studentsWhoCheatedAtMaths = try context.fetch(fetchDescriptor)

            for student in studentsWhoCheatedAtMaths {
                for grade in student.grades where grade.subject == maths {
                    grade.grade = .f
                }
            }
            try context.save()
            print("De-graded \(studentsWhoCheatedAtMaths.count) students.")
        }
    }
    
    measureSize(of: db)
    
    logExecutionTime("Delete all students") {
        try! db.deleteAll()
    }
}
