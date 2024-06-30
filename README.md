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


## Numbers (Simulator)

M2 Mac Mini Pro, Xcode 16 b2, **running in simulator**
Note: Core Data in the simulator seems to be about 40⨯ slower than on device!

- SwiftData and CoreData can grow big, e.g. SwiftData >6GB of RAM for the 1m 
  user inserts, or CoreData >2GB of RAM for the "complex" 100k run.
- SwiftData w/ 1m re-running w/ the fixed non-upsert implementation

Summary simple create, in seconds:

| Count     | SwiftData | CoreData | Realm | Lighter |
|-----------|-----------|----------|-------|---------|
|       100 |      0.02 |     0.01 | 0.003 |       - |
|     1,000 |      0.10 |     0.02 |  0.03 |       - |
|    10,000 |      2.02 |     0.62 |  0.07 |       - |
|   100,000 |    165.10 |    58.87 |  0.52 |    7.85 |
| 1,000,000 | (10333.91)|  4749.45 |  5.05 |       - |
| 2,000,000 |         - |        - |  9.74 |       - |

Summary complex create, in seconds:
- the Core Data numbers look odd compared to SwiftData, 
  maybe doing sth wrong here

| Count     | SwiftData | CoreData | Realm |
|-----------|-----------|----------|-------|
|       100 |      0.11 |     8.04 |  0.01 |
|     1,000 |      1.14 |    81.11 |  0.06 |
|    10,000 |     46.49 |   826.98 |  0.39 |
|   100,000 |   3835.28 |  8918.96 |  3.66 |
|   200,000 |  18408.65 | 19687.10 |  7.10 |
| 1,000,000 |         - |        - | 37.35 |

### Simple User Objects

```
💽 ===============
💽 SwiftData: 100 Simple Objects
===============
💽 User instantiation: 0.0031
💽 Create users: 0.0166
0 users named Jane
💽 Fetch users named `Jane` in age order: 0.0021
0 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0002
💽 DB file size: 0.07 MB
💽 Delete all users: 0.0009

💽 ===============
💽 SwiftData: 1.000 Simple Objects
===============
💽 User instantiation: 0.0059
💽 Create users: 0.0989
0 users named Jane
💽 Fetch users named `Jane` in age order: 0.0005
0 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0004
💽 DB file size: 0.08 MB
💽 Delete all users: 0.0029

💽 ===============
💽 SwiftData: 10.000 Simple Objects
===============
💽 User instantiation: 0.0577
💽 Create users: 2.0238
4 users named Jane
💽 Fetch users named `Jane` in age order: 0.0029
4 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0080
💽 DB file size: 0.18 MB
💽 Delete all users: 0.0217

💽 ===============
💽 SwiftData: 100.000 Simple Objects
===============
💽 User instantiation: 0.5708
💽 Create users: 165.1004 (2:45min)
26 users named Jane
💽 Fetch users named `Jane` in age order: 0.0480
26 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.1953
💽 DB file size: 11.01 MB
💽 Delete all users: 0.2946

💽 ===============
💽 SwiftData: 1.000.000 Simple Objects
===============
💽 User instantiation: 5.5942
💽 Create users: 10333.9109 (~2:52h)
237 users named Jane
💽 Fetch users named `Jane` in age order: 1.9051
237 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 170.9562
💽 DB file size: 110.82 MB
💽 Delete all users: 16.4258

💽 ===============
💽 CoreData: 100 Simple Objects
===============
💽 User instantiation: 0.0010
💽 Create users: 0.0057
0 users named `Jane`
💽 Fetch users named `Jane` in age order: 0.0006
0 users named `Jane` being renamed to `Wendy`
0 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0002
💽 DB file size: 0.03 MB
💽 Delete all users: 0.0002

💽 ===============
💽 CoreData: 1.000 Simple Objects
===============
💽 User instantiation: 0.0021
💽 Create users: 0.0178
0 users named `Jane`
💽 Fetch users named `Jane` in age order: 0.0002
0 users named `Jane` being renamed to `Wendy`
0 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0003
💽 DB file size: 0.03 MB
💽 Delete all users: 0.0008

💽 ===============
💽 CoreData: 10.000 Simple Objects
===============
💽 User instantiation: 0.0206
💽 Create users: 0.6172
0 users named `Jane`
💽 Fetch users named `Jane` in age order: 0.0012
0 users named `Jane` being renamed to `Wendy`
0 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0013
💽 DB file size: 0.03 MB
💽 Delete all users: 0.0076

💽 ===============
💽 CoreData: 100.000 Simple Objects
===============
💽 User instantiation: 0.1903
💽 Create users: 58.8672 (1min)
29 users named `Jane`
💽 Fetch users named `Jane` in age order: 0.0278
29 users named `Jane` being renamed to `Wendy`
29 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0537
💽 DB file size: 7.28 MB
💽 Delete all users: 0.0971

💽 ===============
💽 CoreData: 1.000.000 Simple Objects
===============
💽 User instantiation: 1.9665
💽 Create users: 4749.4489 (~1:20h)
202 users named `Jane`
💽 Fetch users named `Jane` in age order: 0.7345
202 users named `Jane` being renamed to `Wendy`
202 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 1.4318
💽 DB file size: 72.67 MB
💽 Delete all users: 64.1758

💽 ===============
💽 Realm: 100 Simple Objects
===============
💽 User instantiation: 0.0005
💽 Create users: 0.0038
0 users named Jane
💽 Fetch users named `Jane` in age order: 0.0037
0 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0022
💽 DB file size: 0.02 MB
💽 Delete all users: 0.0012

💽 ===============
💽 Realm: 1.000 Simple Objects
===============
💽 User instantiation: 0.0021
💽 Create users: 0.0260
0 users named Jane
💽 Fetch users named `Jane` in age order: 0.0001
0 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0021
💽 DB file size: 0.12 MB
💽 Delete all users: 0.0024

💽 ===============
💽 Realm: 10.000 Simple Objects
===============
💽 User instantiation: 0.0190
💽 Create users: 0.0680
2 users named Jane
💽 Fetch users named `Jane` in age order: 0.0003
2 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0017
💽 DB file size: 1.00 MB
💽 Delete all users: 0.0028

💽 ===============
💽 Realm: 100.000 Simple Objects
===============
💽 User instantiation: 0.1950
💽 Create users: 0.5171
23 users named Jane
💽 Fetch users named `Jane` in age order: 0.0010
23 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0053
💽 DB file size: 6.00 MB
💽 Delete all users: 0.0094

💽 ===============
💽 Realm: 1.000.000 Simple Objects
===============
💽 User instantiation: 1.6582
💽 Create users: 5.0533
204 users named Jane
💽 Fetch users named `Jane` in age order: 0.0134
204 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0129
💽 DB file size: 55.33 MB
💽 Delete all users: 0.0287

💽 ===============
💽 Realm: 2.000.000 Simple Objects
===============
💽 User instantiation: 3.2950
💽 Create users: 9.7441
410 users named Jane
💽 Fetch users named `Jane` in age order: 0.0206
410 users renamed to `Wendy`
💽 Rename users named `Jane` to `Wendy`: 0.0319
💽 DB file size: 112.11 MB
💽 Delete all users: 0.0446

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
💽 SwiftData: 100 Complex Objects
===============
💽 Student instantiation: 0.0058
💽 Create students: 0.1101
3 students with an A* in Physics
💽 Read students with A* in Physics: 0.0021
💽 Fail the cheating Maths students: 0.0005
💽 DB file size: 0.73 MB
💽 Delete all students: 0.0034

💽 ===============
💽 SwiftData: 1.000 Complex Objects
===============
💽 Student instantiation: 0.0367
💽 Create students: 1.1428
43 students with an A* in Physics
💽 Read students with A* in Physics: 0.0185
💽 Fail the cheating Maths students: 0.0170
💽 DB file size: 1.13 MB
💽 Delete all students: 0.0194

💽 ===============
💽 SwiftData: 10.000 Complex Objects
===============
💽 Student instantiation: 0.3201
💽 Create students: 46.4866
390 students with an A* in Physics
💽 Read students with A* in Physics: 1.4684
💽 Fail the cheating Maths students: 0.7190
💽 DB file size: 7.83 MB
💽 Delete all students: 0.2226

💽 ===============
💽 SwiftData: 100.000 Complex Objects
===============
💽 Student instantiation: 3.2821
💽 Create students: 3835.2785 (>1h)
3951 students with an A* in Physics
💽 Read students with A* in Physics: 107.9419
💽 Fail the cheating Maths students: 76.1356
💽 DB file size: 71.50 MB
💽 Delete all students: 11.1390

💽 ===============
💽 SwiftData: 200.000 Complex Objects
===============
💽 Student instantiation: 6.7132
💽 Create students: 18408.6534 (>5h)
7948 students with an A* in Physics
💽 Read students with A* in Physics: 419.5726
💽 Fail the cheating Maths students: 314.0178
💽 DB file size: 174.85 MB
💽 Delete all students: 35.4886

💽 ===============
💽 CoreData: 100 Complex Objects
===============
💽 Student instantiation: 0.0046
Created 100 students.
💽 Create students: 8.0364      // this looks odd?
3 students with an A* in Physics
💽 Read students with A* in Physics: 0.0760
De-graded 0 students.
💽 Fail the cheating Maths students: 0.0960
💽 DB file size: 0.05 MB
💽 Delete all students: 0.1633

💽 ===============
💽 CoreData: 1.000 Complex Objects
===============
💽 Student instantiation: 0.0194
Created 1000 students.
💽 Create students: 81.1106
42 students with an A* in Physics
💽 Read students with A* in Physics: 0.3628
De-graded 0 students.
💽 Fail the cheating Maths students: 0.0963
💽 DB file size: 0.05 MB
💽 Delete all students: 0.1683

💽 ===============
💽 CoreData: 10.000 Complex Objects
===============
💽 Student instantiation: 0.1919
Created 10000 students.
💽 Create students: 826.9841 (~14min)
398 students with an A* in Physics
💽 Read students with A* in Physics: 3.0860
De-graded 0 students.
💽 Fail the cheating Maths students: 0.0997
💽 DB file size: 4.79 MB
💽 Delete all students: 0.2481

💽 ===============
💽 CoreData: 100.000 Complex Objects
===============
💽 Student instantiation: 1.9152
Created 100000 students.
💽 Create students: 8918.9621 (~2:28h)
3877 students with an A* in Physics
💽 Read students with A* in Physics: 32.5651
De-graded 0 students.
💽 Fail the cheating Maths students: 0.1078
💽 DB file size: 48.77 MB
💽 Delete all students: 104.8843

💽 ===============
💽 CoreData: 200.000 Complex Objects
===============
CoreData: debug: PostSaveMaintenance: incremental_vacuum with freelist_count - 28 and pages_to_free 15
💽 Student instantiation: 3.8674
CoreData: debug: PostSaveMaintenance: fileSize 103580952 greater than prune threshold
CoreData: annotation: PostSaveMaintenance: wal_checkpoint(TRUNCATE) 
Created 200000 students.
💽 Create students: 19687.0992
7817 students with an A* in Physics
💽 Read students with A* in Physics: 73.8052
De-graded 0 students.
💽 Fail the cheating Maths students: 0.1214
💽 DB file size: 98.21 MB
CoreData: debug: PostSaveMaintenance: fileSize 99308512 greater than prune threshold
CoreData: debug: PostSaveMaintenance: incremental_vacuum with freelist_count - 25098 and pages_to_free 25055
CoreData: annotation: PostSaveMaintenance: wal_checkpoint(TRUNCATE) 
💽 Delete all students: 237.7696

💽 ===============
💽 Realm: 100 Complex Objects
===============
💽 Student instantiation: 0.0028
💽 Create students: 0.0121
14 students with an A* in Physics
💽 Read students with A* in Physics: 0.0043
💽 Fail the cheating Maths students: 0.0025
💽 DB file size: 123.56 MB
💽 Delete all students: 0.0023

💽 ===============
💽 Realm: 1.000 Complex Objects
===============
💽 Student instantiation: 0.0129
💽 Create students: 0.0551
137 students with an A* in Physics
💽 Read students with A* in Physics: 0.0016
💽 Fail the cheating Maths students: 0.0023
💽 DB file size: 123.56 MB
💽 Delete all students: 0.0035

💽 ===============
💽 Realm: 10.000 Complex Objects
===============
💽 Student instantiation: 0.1318
💽 Create students: 0.3925
1386 students with an A* in Physics
💽 Read students with A* in Physics: 0.0158
💽 Fail the cheating Maths students: 0.0024
💽 DB file size: 123.56 MB
💽 Delete all students: 0.0142

💽 ===============
💽 Realm: 100.000 Complex Objects
===============
💽 Student instantiation: 1.3089
💽 Create students: 3.6597
13292 students with an A* in Physics
💽 Read students with A* in Physics: 0.1867
💽 Fail the cheating Maths students: 0.0063
💽 DB file size: 123.56 MB
💽 Delete all students: 0.1508

💽 ===============
💽 Realm: 200.000 Complex Objects
===============
💽 Student instantiation: 2.4842
💽 Create students: 7.0981
26652 students with an A* in Physics
💽 Read students with A* in Physics: 0.3773
💽 Fail the cheating Maths students: 0.0062
💽 DB file size: 123.56 MB
💽 Delete all students: 0.2842

💽 ===============
💽 Realm: 1.000.000 Complex Objects
===============
💽 Student instantiation: 12.5471
💽 Create students: 37.3543
132480 students with an A* in Physics
💽 Read students with A* in Physics: 2.0903
💽 Fail the cheating Maths students: 0.0149
💽 DB file size: 364.42 MB
💽 Delete all students: 1.3790
```
