//
//  Array+DevTableSection+Snapshot.swift
//
//
//  Created by Hardijs on 04/06/2026.
//

import UIKit

public extension Array where Element: DevTableSection {

    /// Converts a `[DevTableSection]` array into an `NSDiffableDataSourceSnapshot`
    /// ready to be applied to a `UITableViewDiffableDataSource`.
    ///
    /// This is the bridge between the ViewModel's typed section model and UIKit's
    /// diffable data source. Call this in the view controller when the ViewModel publishes
    /// a new sections array.
    ///
    /// ```swift
    /// // ViewController
    /// viewModel.$sections
    ///     .map { $0.asSnapshot() }
    ///     .receive(on: DispatchQueue.main)
    ///     .sink { [weak self] snapshot in
    ///         self?.dataSource.apply(snapshot, animatingDifferences: true)
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    func asSnapshot() -> NSDiffableDataSourceSnapshot<Element.SectionID, Element.Cell> {
        var snapshot = NSDiffableDataSourceSnapshot<Element.SectionID, Element.Cell>()
        let sectionIDs = map { $0.id }
        snapshot.appendSections(sectionIDs)
        forEach { section in
            snapshot.appendItems(section.cells, toSection: section.id)
        }
        return snapshot
    }
}
