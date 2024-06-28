//
//  SwiftStudentsTests.swift
//  RealmVsSwiftData
//
//  Created by Jacob Bartlett on 02/05/2024.
//

import Foundation
import SwiftData // FetchDescriptor

func swiftStudentsPerformanceTests(with studentsCount: Int = 10_000) {
    
    announce("SwiftData: \(formatNumberWithCommas(studentsCount)) Complex Objects")
        
    let db = try! SwiftStudentDB()
    try! db.deleteAll()
    var students = [SwiftStudent]()
    
    logExecutionTime("Student instantiation") {
        let schoolCount = 100
        let firstSchool = SwiftSchool(name: "Falconwood College", location: "Falconwood", type: .comprehensive)
        let schools = [firstSchool] + (1..<schoolCount).compactMap { _ in try? SwiftSchool() }
        let studentsPerSchool = studentsCount / schoolCount
        for school in schools {
            students.append(contentsOf: (0..<studentsPerSchool).compactMap { _ in
                try? SwiftStudent(school: school)
            })
        }
    }
    
    logExecutionTime("Create students") {
        try! db.create(students)
    }
    
    logExecutionTime("Read students with A* in Physics") {
        let physics = SwiftGrade.Subject.physics.rawValue
        let aStarGrade = SwiftGrade.Grade.aStar.rawValue
        let predicate = #Predicate<SwiftStudent> { student in
            student.grades.contains(where: {
                $0.subject == physics
                && $0.grade == aStarGrade
            })
        }
        let studentsWithAStarInPhysics = try! db.read(predicate: predicate)
        print("\(studentsWithAStarInPhysics.count) students with an A* in Physics")
    }
    
    logExecutionTime("Fail the cheating Maths students") {
        let maths = SwiftGrade.Subject.maths.rawValue
        let predicate = #Predicate<SwiftStudent> { student in
            (student.school?.name == "Falconwood College")
            && (student.grades.contains(where: { $0.subject == maths }))
        }
        try! db.update { context in
            let fetchDescriptor = FetchDescriptor<SwiftStudent>(predicate: predicate)
            let studentsWhoCheatedAtMaths = try context.fetch(fetchDescriptor)
            for student in studentsWhoCheatedAtMaths {
                for grade in student.grades {
                    grade.grade = SwiftGrade.Grade.f.rawValue
                }
            }
            try context.save()
        }
    }
    
    measureSize(of: db)
    
    logExecutionTime("Delete all students") {
        try! db.deleteAll()
    }
}
