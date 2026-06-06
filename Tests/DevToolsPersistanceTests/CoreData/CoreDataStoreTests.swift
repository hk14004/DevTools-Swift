//
//  PersistentCoreDataStoreTests.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import XCTest
import Combine
import DevToolsPersistance
import CoreData
import DevToolsCore

final class CoreDataStoreTests: XCTestCase {
    enum Constant {
        static let mockDBModelName = "Model"
        static let mockID = "mockID"
        static let mockName = "mockName"
        static let randomSuffix = "fhsaggfhjfhjf"
    }
    var container: NSPersistentContainer!
    let mockDTO = MockCD_DTO(id: Constant.mockID, name: Constant.mockName)
    lazy var sut = makeSUT()
    var cancelBag: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configureCoreDataStack()
    }
}

extension CoreDataStoreTests {
    func makeSUT() -> DevCoreDataStore<MockCD_DTO, MockCD_Converter> {
        DevCoreDataStore(container: container, converter: MockCD_Converter())
    }

    func configureCoreDataStack() throws {
        guard let modelURL = Bundle.module.url(
            forResource: Constant.mockDBModelName,
            withExtension: "momd"
        ) else {
            XCTFail("Failed to load model URL from test bundle")
            return
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("Failed to load Core Data model from test bundle")
            return
        }
        let persistentContainer = NSPersistentContainer(
            name: Constant.mockDBModelName,
            managedObjectModel: model
        )
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.persistentStoreDescriptions = [description]

        let semaphore = DispatchSemaphore(value: 0)
        var loadError: Error?
        persistentContainer.loadPersistentStores { _, error in
            loadError = error
            semaphore.signal()
        }
        if semaphore.wait(timeout: .now() + .seconds(5)) == .timedOut {
            XCTFail("Timed out waiting for persistent store to load.")
        }
        if let error = loadError { throw error }
        container = persistentContainer
    }

    func makeIDPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }

    func makeNamePredicate(_ name: String) -> NSPredicate {
        NSPredicate(format: "name == %@", name)
    }
}
