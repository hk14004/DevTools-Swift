//
//  SwiftDataStoreTests.swift
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
    var sut: DevSwiftDataStore<MockSD_DTO, MockSD_Converter>!
    var cancelBag: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configureSwiftDataStack()
        sut = makeSUT()   // eagerly initialise on main thread
    }
}

extension SwiftDataStoreTests {
    func makeSUT() -> DevSwiftDataStore<MockSD_DTO, MockSD_Converter> {
        DevSwiftDataStore(container: container, converter: MockSD_Converter())
    }

    func configureSwiftDataStack() throws {
        let schema = Schema([MockSD.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
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
