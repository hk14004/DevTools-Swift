//
//  ManagedObjectPublisher.swift
//  
//
//  Created by Hardijs Ķirsis on 05/04/2023.
//

import Foundation
import CoreData
import Combine
import DevTools

struct ManagedObjectCollectionPublisher<Object: NSManagedObject>: Publisher {
    
    // MARK: Types
    
    typealias Output = [Object]
    typealias Failure = Error
    
    // MARK: Properties
    
    let fetchRequest: NSFetchRequest<Object>
    let context: NSManagedObjectContext
    
    // MARK: Init
    
    init(fetchRequest: NSFetchRequest<Object>, context: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        self.context = context
    }
    
    // MARK: Methods
    
    func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        let inner = Inner(
            downstream: subscriber,
            fetchRequest: fetchRequest,
            context: context
        )
        subscriber.receive(subscription: inner)
    }
}

extension ManagedObjectCollectionPublisher {
    
    private class Inner<Downstream: Subscriber>: NSObject, Subscription, NSFetchedResultsControllerDelegate
    where Downstream.Input == [Object],
          Downstream.Failure == Error
    {
        // MARK: Properties
        
        private var lastSentState: [Object] = []
        private var demand: Subscribers.Demand = .none
        private let downstream: Downstream
        private var fetchedResultsController: NSFetchedResultsController<Object>?
        
        // MARK: Init
        
        init(
            downstream: Downstream,
            fetchRequest: NSFetchRequest<Object>,
            context: NSManagedObjectContext
        ) {
            self.downstream = downstream
            fetchedResultsController
            = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
            super.init()
            fetchedResultsController!.delegate = self
            do {
                try fetchedResultsController!.performFetch()
                fulfillDemand()
            } catch {
                downstream.receive(completion: .failure(error))
            }
        }
        
        // MARK: Methods
        
        // Public
        
        func controllerDidChangeContent(
            _ controller: NSFetchedResultsController<NSFetchRequestResult>
        ) {
            fulfillDemand()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
            fulfillDemand()
        }
        
        func cancel() {
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
        }
        
        // Private
        
        private func fulfillDemand() {
            if demand > 0 {
                lastSentState = Array(fetchedResultsController?.fetchedObjects ?? [])
                let newDemand = downstream.receive(lastSentState)
                demand += newDemand
                demand -= 1
            }
        }
    }
}
