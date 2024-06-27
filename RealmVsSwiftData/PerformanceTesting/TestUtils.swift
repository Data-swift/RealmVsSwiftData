//
//  TestPlan.swift
//  RealmVsSwiftData
//
//  Created by Jacob Bartlett on 10/04/2024.
//

import Foundation

func runAllPerformanceTests() {
    for num in [100, 1_000, 10_000, 100_000, 1_000_000] { //, 2_000_000, 10_000_000] {
        swiftUsersPerformanceTests(with: num)
    }
    
    for num in [100, 1_000, 10_000, 100_000, 1_000_000] { //, 2_000_000, 10_000_000] {
        coreUsersPerformanceTests(with: num)
    }
  
    for num in [100, 1_000, 10_000, 100_000, 1_000_000, 2_000_000] { //, 10_000_000] {
        realmUsersPerformanceTests(with: num)
    }
    
    for num in [100, 1_000, 10_000, 100_000, 200_000] { //, 1_000_000] {
        swiftStudentsPerformanceTests(with: num)
    }
    
    for num in [100, 1_000, 10_000, 100_000, 200_000] { //, 1_000_000] {
        coreStudentsPerformanceTests(with: num)
    }
    
    for num in [100, 1_000, 10_000, 100_000, 200_000, 1_000_000] {
        realmStudentsPerformanceTests(with: num)
    }

    deleteAllDatabaseFiles()
}

func deleteAllDatabaseFiles() {
    if let swiftUserDB = try? SwiftUserDB() {
        delete(db: swiftUserDB)
    }
    if let swiftStudentDB = try? SwiftStudentDB() {
        delete(db: swiftStudentDB)
    }
    if let coreUserDB = try? CoreUserDB() {
        delete(db: coreUserDB)
    }
    if let coreStudentDB = try? CoreStudentDB() {
        delete(db: coreStudentDB)
    }
    let realmUserDB = RealmUserDB()
    delete(db: realmUserDB)
    let realmStudentDB = RealmStudentDB()
    delete(db: realmStudentDB)
}

// Run these individually to avoid memory caused by one framework to affect the other
// This seems less accurate than Xcode instruments, so I'll measure peak memory manually
//func runMemoryProfiling() {
//    let baselineMemory = reportMemory()
//    measurePeakMemoryUsage(baseline: baselineMemory) {
//        swiftUsersPerformanceTests(with: 100)
//        swiftStudentsPerformanceTests(with: 100)
//        realmUsersPerformanceTests(with: 100)
//        realmStudentsPerformanceTests(with: 100)
//    }
//}

func logExecutionTime(_ title: String, _ execute: () -> Void) {
    let start = CFAbsoluteTimeGetCurrent()
    execute()
    let diff = CFAbsoluteTimeGetCurrent() - start
    print("💽 \(title): \(String(format: "%.4f", diff))")
}

func announce(_ string: String) {
    print()
    print("💽 ===============")
    print("💽 \(string)")
    print("===============")
}

private let formatter = NumberFormatter()

func formatNumberWithCommas(_ number: Int) -> String {
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? ""
}

private let fileManager = FileManager.default

func measureSize(of db: any Database) {
    if let fileURL = db.fileURL,
       let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
       let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
        let sizeInMB = Double(fileSize) / Double(1024 * 1024)
        print("💽 DB file size: \(String(format: "%.2f MB", sizeInMB))")
    }
}

func delete(db: any Database) {
    if let fileURL = db.fileURL {
        try? fileManager.removeItem(at: fileURL)
    }
}

func measurePeakMemoryUsage(baseline baselineMemory: Double, _ execute: () -> Void) {
    execute()
    let memoryUsage = reportMemory()
    let aboveBaseline = memoryUsage - baselineMemory
    print("💽 Peak memory usage: \(String(format: "%.2f MB", aboveBaseline))")
}

private func reportMemory() -> Double {
    var taskInfo = task_vm_info_data_t()
    var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
    let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_,
                      task_flavor_t(TASK_VM_INFO),
                      $0,
                      &count)
        }
    }
    let usedMB = Double(taskInfo.phys_footprint) / Double(1024 * 1024)
    return result == KERN_SUCCESS ? usedMB : 0
}
