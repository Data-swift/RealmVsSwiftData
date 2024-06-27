# Perf Test for CoreData, SwiftData and Realm

Comparing the performance characteristics of Realm, SwiftData and CoreData.

Code accompanying the Emerge Tools blog article:
[SwiftData vs Realm: Performance Comparison](https://www.emergetools.com/blog/posts/swiftdata-vs-realm-performance-comparison)
by Jacob Bartlett.

Original repositoy: https://github.com/jacobsapps/RealmVsSwiftData

Michal Tsai's coverage: https://mjtsai.com/blog/2024/06/24/swiftdata-vs-realm-performance-comparison/


## Issues

- UUID init is superfluous in all but Realm? CD/SQLite can do the primary keys.
- Delete all users could be just a database table drop/recreate?


## Links

- [SwiftData vs Realm: Performance Comparison](https://www.emergetools.com/blog/posts/swiftdata-vs-realm-performance-comparison)
- [RealmVsSwiftData](https://github.com/jacobsapps/RealmVsSwiftData) original repository
- Storages
  - [Realm](https://www.mongodb.com/docs/atlas/device-sdks/) by MongoDB
  - [SwiftData](https://developer.apple.com/documentation/swiftdata) by Apple
  - [Core Data](https://developer.apple.com/documentation/coredata/) by Apple
    - [ManagedModels](https://github.com/Data-swift/ManagedModels)) by [Helge Heß](https://helgehess.eu/),
      access Core Data in a SwiftData like fashion
  - [Lighter.swift](https://github.com/Lighter-swift) by [Helge Heß](https://helgehess.eu/), direct SQLite access


## Numbers

M2 Mac Mini Pro, Xcode 16 b2, running in simulator

- SwiftData and CoreData can grow big, e.g. SwiftData >6GB of RAM for the 1m 
  user inserts, or CoreData >2GB of RAM for the "complex" 100k run.

### Simple User Objects

```
💽 ===============
💽 SwiftData: 1.000.000 Simple Objects
===============
💽 User instantiation: 6.5249
💽 Create users: 9913.5297 (2.75h)
207 users named Jane
💽 Fetch users named `Jane` in age order: 1.7491
207 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 133.1398
💽 DB file size: 101.51 MB
💽 Delete all users: 17.4455

💽 ===============
💽 Realm: 1.000.000 Simple Objects
===============
💽 User instantiation: 1.6368
💽 Create users: 4.8281
199 users named Jane
💽 Fetch users named `Jane` in age order: 0.0110
199 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0101
💽 DB file size: 75.64 MB
💽 Delete all users: 0.0120

💽 ===============
💽 CoreData: 1.000.000 Simple Objects
===============
💽 User instantiation: 1.9408
💽 Create users: 4270.8671 (~1:15h)
205 users named `Jane`
💽 Fetch users named `Jane` in age order: 0.8116
205 users named `Jane` being renamed to `Wendy`
205 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 1.5780
💽 DB file size: 72.57 MB
💽 Delete all users: 70.3943

💽 ===============
💽 Lighter: 1.000.000 Simple Objects
===============
💽 User instantiation: 0.4484
💽 Create users: 7.8463
💽 Create index: 0.3628
218 users named Jane
💽 Fetch users named `Jane` in age order: 0.0016
218 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0100
💽 DB file size: 79.65 MB
💽 Delete all users: 10.0460
```

### Complex Student/School/Grade Objects

```
💽 ===============
💽 CoreData: 1.000 Complex Objects
===============
💽 Student instantiation: 0.0220
Created 1000 students.
💽 Create students: 0.2168
43 students with an A* in Physics
💽 Read students with A* in Physics: 0.0051
De-graded 0 students.
💽 Fail the cheating Maths students: 0.0006
💽 DB file size: 0.05 MB
💽 Delete all students: 0.0063
💽 ===============
💽 CoreData: 10.000 Complex Objects
===============
CoreData: debug: PostSaveMaintenance: incremental_vacuum with freelist_count - 120 and pages_to_free 107
💽 Student instantiation: 0.1986
Created 10000 students.
💽 Create students: 16.1095
385 students with an A* in Physics
💽 Read students with A* in Physics: 0.1160
De-graded 0 students.
💽 Fail the cheating Maths students: 0.0038
💽 DB file size: 4.73 MB
💽 Delete all students: 0.0857
💽 ===============
💽 CoreData: 100.000 Complex Objects
===============
💽 Student instantiation: 1.8890
Created 100000 students.
💽 Create students: 1631.6497 ~28min
4032 students with an A* in Physics
💽 Read students with A* in Physics: 9.4956
De-graded 0 students.
💽 Fail the cheating Maths students: 0.0299
💽 DB file size: 48.77 MB
CoreData: debug: PostSaveMaintenance: fileSize 49415312 greater than prune threshold
CoreData: debug: PostSaveMaintenance: incremental_vacuum with freelist_count - 12457 and pages_to_free 12429
CoreData: annotation: PostSaveMaintenance: wal_checkpoint(TRUNCATE) 
💽 Delete all students: 29.9509
```
