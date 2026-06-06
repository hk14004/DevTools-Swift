//
//  DevTableSection.swift
//
//
//  Created by Hardijs on 04/02/2023.
//

import Foundation
import DevToolsCore

/// Marks a type as a valid cell in a `DevTableSection`.
public protocol DevTableSectionCell: DevContentComparable, Hashable {}

/// Marks a type as a valid cell view model in a `DevTableSection`.
public protocol DevTableSectionCellModel: DevContentComparable, Hashable {}

/// A typed, diffable model for a single table view section — designed to live on the ViewModel side.
///
///Use case                        Rating    Recommendation
///─────────────────────────────────────────────────────────
///Flat single-section list        6/10      Skip the protocol
///Fixed multi-section             8/10      Sweet spot — use it
///Dynamic API-driven sections     4/10      Use snapshot directly
///
///
/// Conform to this protocol to describe a section's identity, optional title, and cells.
/// The ViewModel holds `[YourSection]` and manipulates it using the `Array+DevTableSection`
/// helpers. The view controller converts it to an `NSDiffableDataSourceSnapshot` via
/// `Array.asSnapshot()` and applies it to its data source.
///
/// # Defining a section
/// ```swift
/// struct FeedSection: DevTableSection {
///     enum SectionID: Hashable, CaseIterable { case featured, recent }
///     enum Cell: DevTableSectionCell { case post(PostViewModel); case ad(AdViewModel) }
///
///     var id: SectionID
///     var title: String?
///     var cells: [Cell]
/// }
/// ```
///
/// # ViewModel usage
/// ```swift
/// var sections: [FeedSection] = []
/// sections.addOrUpdate(FeedSection(id: .featured, title: "Featured", cells: [...]))
/// ```
///
/// # View controller usage
/// ```swift
/// viewModel.$sections
///     .map { $0.asSnapshot() }
///     .receive(on: DispatchQueue.main)
///     .sink { [weak self] snapshot in
///         self?.dataSource.apply(snapshot, animatingDifferences: true)
///     }
///     .store(in: &cancellables)
/// ```
public protocol DevTableSection: Hashable, DevContentComparable {
    associatedtype Cell: DevTableSectionCell
    /// The type used to uniquely identify this section.
    /// Must be `CaseIterable` so all possible sections are enumerable,
    /// and `Hashable` so it can be used as a `NSDiffableDataSourceSnapshot` section identifier.
    associatedtype SectionID: CaseIterable, Hashable

    var id: SectionID { get }
    /// Optional section header title. `nil` means no header.
    var title: String? { get set }
    var cells: [Cell] { get set }
}

public extension DevTableSection {
    var contentHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(cells.contentHash)
        return hasher.finalize()
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension DevHashChangeSet {

    /// Calculates a cell-level changeset by flattening all sections into a single sequence.
    ///
    /// - Note: This is most reliable for **single-section** tables. For multi-section tables
    ///   the resulting index paths may not reflect actual per-section positions — use
    ///   `Array.asSnapshot()` and `NSDiffableDataSourceSnapshot` instead, which handles
    ///   multi-section diffing correctly.
    static func calculateCellChangeSet<Element: DevTableSection>(
        old: [Element],
        new: [Element]
    ) -> DevHashChangeSet {
        let oldCells = old.flatMap { $0.cells }
        let newCells = new.flatMap { $0.cells }
        return DevHashChangeSet.calculateChangeSet(old: oldCells, new: newCells)
    }
}
