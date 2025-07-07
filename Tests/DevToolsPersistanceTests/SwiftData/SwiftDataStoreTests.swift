//
//  PersistentCoreDataStoreTests.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import XCTest
import Combine
import DevToolsPersistance
import SwiftData
import DevToolsCore

final class SwiftDataStoreTests: XCTestCase {
    enum Constant {
        static let mockID = "mockID"
        static let mockName = "mockName"
        static let randomSuffix = "fhsaggfhjfhjf"
    }
    private var container: ModelContainer!
    let mockDTO = MockSD_DTO(id: Constant.mockID, name: Constant.mockName)
    lazy var sut = makeSUT()
    var cancelBag: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try configureSwiftDataStack()
    }
}

extension SwiftDataStoreTests {
    func makeSUT() -> DevSwiftDataStore<MockSD_DTO, MockSD_Converter> {
        DevSwiftDataStore(container: container, converter: MockSD_Converter(), queue: .main)
    }
    
    func configureSwiftDataStack() throws {
        lazy var container: ModelContainer = {
            // 2) Build your Schema with all your @Model types
            let schema = Schema([
              MockSD.self,
            ])

            // 3) Tell SwiftData “in-memory only” so it never writes to disk or iCloud
            let config = ModelConfiguration(
              schema: schema,
              isStoredInMemoryOnly: true
            )

            // 4) Create the container—fatalError on failure is fine in tests
            do {
              return try ModelContainer(
                for: schema,
                configurations: [config]
              )
            } catch {
              fatalError("Could not create in-memory ModelContainer: \(error)")
            }
          }()
        self.container = container
    }
    
    func makeIDPredicate(_ id: String) -> Predicate<MockSD> {
        #Predicate { $0.id == id }
    }
    
    func makeIDPredicate(contains ids: [String]) -> Predicate<MockSD> {
        #Predicate { ids.contains($0.id) }
    }

    func makeNamePredicate(_ name: String) -> Predicate<MockSD> {
        #Predicate { $0.name == name }
    }
}
