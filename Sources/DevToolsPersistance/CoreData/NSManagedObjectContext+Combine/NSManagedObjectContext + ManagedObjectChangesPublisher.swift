//
//  NSManagedObjectContext + ManagedObjectChangesPublisher.swift
//  
//
//  Created by Hardijs Ķirsis on 05/04/2023.
//

import Foundation
import CoreData
import Combine

extension NSManagedObjectContext {
    func changesPublisher<Object: NSManagedObject>(
        for fetchRequest: NSFetchRequest<Object>
    ) -> ManagedObjectChangesPublisher<Object> {
        ManagedObjectChangesPublisher(
            fetchRequest: fetchRequest,
            context: self
        )
    }
    
    func collectionPublisher<Object: NSManagedObject>(
        for fetchRequest: NSFetchRequest<Object>
    ) -> ManagedObjectCollectionPublisher<Object> {
        ManagedObjectCollectionPublisher(
            fetchRequest: fetchRequest,
            context: self
        )
    }
}
