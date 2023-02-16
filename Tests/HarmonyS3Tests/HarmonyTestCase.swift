//
//  HarmonyTestCase.swift
//  HarmonyTests
//
//  Created by Joseph Mattiello on 10/21/17.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import XCTest
@testable import Harmony

import CoreData

class HarmonyTestCase: XCTestCase {
    var persistentContainer: NSPersistentContainer!
    var recordController: RecordController!

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    var performSaveInTearDown = true

    // Must use same NSManagedObjectModel instance for all tests or else Bad Things Happen™.
    private static let managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: HarmonyTestCase.self).url(forResource: "HarmonyTests", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!

        let harmonyModel = NSManagedObjectModel.harmonyModel(byMergingWith: [managedObjectModel])!
        return harmonyModel
    }()

    override func setUp() {
        super.setUp()

        try? FileManager.default.createDirectory(at: FileManager.default.documentsDirectory, withIntermediateDirectories: true, attributes: nil)

        performSaveInTearDown = true

        prepareDatabase()
    }

    override func tearDown() {
        if performSaveInTearDown {
            // Ensure all tests result in saveable NSManagedObject state.
            XCTAssertNoThrow(try recordController.viewContext.save())
        }

        recordController.viewContext.automaticallyMergesChangesFromParent = false

        deletePersistentStores(for: persistentContainer.persistentStoreCoordinator)
        deletePersistentStores(for: recordController.persistentStoreCoordinator)

        super.tearDown()
    }

    private func deletePersistentStores(for persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        for store in persistentStoreCoordinator.persistentStores {
            guard store.type != NSInMemoryStoreType else { continue }

            do {
                try persistentStoreCoordinator.destroyPersistentStore(at: store.url!, ofType: NSSQLiteStoreType, options: store.options)
                try FileManager.default.removeItem(at: store.url!)
            } catch let error where error._code == NSCoreDataError {
                print(error)
            } catch {
                print(error)
            }
        }
    }
}

extension HarmonyTestCase {
    func prepareDatabase() {
        preparePersistentContainer()
        prepareRecordController()
    }

    func preparePersistentContainer() {
        let managedObjectModel = HarmonyTestCase.managedObjectModel
        persistentContainer = NSPersistentContainer(name: "HarmonyTests", managedObjectModel: managedObjectModel)
        persistentContainer.persistentStoreDescriptions.forEach { $0.shouldAddStoreAsynchronously = false; $0.shouldMigrateStoreAutomatically = false }

        persistentContainer.loadPersistentStores { _, error in
            assert(error == nil)
        }

        NSManagedObjectContext.harmonyTestsFactoryDefault = persistentContainer.viewContext
    }

    func prepareRecordController() {
        recordController = RecordController(persistentContainer: persistentContainer)
        recordController.shouldAddStoresAsynchronously = false
        recordController.persistentStoreDescriptions.forEach { $0.shouldMigrateStoreAutomatically = false }
        recordController.automaticallyRecordsManagedObjects = false

        recordController.start { errors in
            assert(errors.isEmpty)
        }

        NSManagedObjectContext.harmonyFactoryDefault = recordController.viewContext
    }
}

extension HarmonyTestCase {
    func waitForRecordControllerToProcessUpdates() {
        let expectation = XCTNSNotificationExpectation(name: .recordControllerDidProcessUpdates)
        wait(for: [expectation], timeout: 2.0)
    }
}
