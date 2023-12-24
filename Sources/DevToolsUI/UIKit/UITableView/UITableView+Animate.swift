import UIKit
import DevToolsCore

public extension UITableView {
    func animateChangeSet(_ change: DevChangeSet, completion: ((Bool)->())? = nil) {
        performBatchUpdates {
            deleteRows(at: change.removed, with: .fade)
            insertRows(at: change.inserted, with: .fade)
            change.moved.forEach { move in
                moveRow(at: move.from, to: move.to)
            }
        } completion: { [weak self] completed in
            guard let self = self else {
                completion?(completed)
                return
            }
            performBatchUpdates {
                self.reloadRows(at: change.updated, with: .fade)
            } completion: { completed in
                completion?(completed)
            }
        }
    }
}
