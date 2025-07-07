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

final class PersistentCoreDataStoreTests: XCTestCase {
    enum Constant {
        static let mockDBModelName = "Model"
        static let mockID = "mockID"
        static let mockName = "mockName"
        static let queueName = "test.queue"
        static let randomSuffix = "fhsaggfhjfhjf"
    }
    var context: NSManagedObjectContext!
    let mockDTO = MockCD_DTO(id: Constant.mockID, name: Constant.mockName)
    lazy var sut = makeSUT()
    var cancelBag: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try configureCoreDataStack()
    }
}

extension PersistentCoreDataStoreTests {
    func makeSUT() -> DevCoreDataStore<MockCD_DTO, MockCD_Converter> {
        DevCoreDataStore(context: context, converter: MockCD_Converter())
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
        let container = NSPersistentContainer(name: Constant.mockDBModelName, managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        
        // Semaphore to wait for async loadPersistentStores
        let semaphore = DispatchSemaphore(value: 0)
        
        var loadError: Error?
        
        container.loadPersistentStores { _, error in
            if let error = error {
                loadError = error
            }
            semaphore.signal()
        }
        
        // Wait for the store to load (with timeout to avoid test hang)
        let timeout = DispatchTime.now() + .seconds(5)
        if semaphore.wait(timeout: timeout) == .timedOut {
            XCTFail("Timed out waiting for persistent store to load.")
        }
        
        if let error = loadError {
            throw error
        } else {
            context = container.newBackgroundContext()
        }
    }
    
    func makeIDPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }
    
    func makeNamePredicate(_ name: String) -> NSPredicate {
        NSPredicate(format: "name == %@", name)
    }
}
