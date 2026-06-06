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

/// A typed, diffable model for a single table view section — designed to live on the ViewModel side.
///
/// Conform to this protocol to describe a section's identity, optional title, and cells.
/// For managing collections of sections, prefer ``DevSectionStore`` over a raw array —
/// it provides O(1) lookup, explicit ordering control, atomic cell updates, and snapshot conversion.
///
/// ## SectionID
/// `SectionID` only needs to be `Hashable`. Unlike the previous design it does **not** require
/// `CaseIterable`, so dynamic section IDs with associated values are fully supported:
///
/// ```swift
/// enum FeedSectionID: Hashable {
///     case featured
///     case group(Int)      // dynamic, API-driven
///     case footer
/// }
/// ```
///
/// ## Defining a section
/// ```swift
/// struct FeedSection: DevTableSection {
///     enum SectionID: Hashable { case featured, recent }
///     enum Cell: DevTableSectionCell {
///         case post(PostViewModel)
///         case ad(AdViewModel)
///     }
///
///     var id: SectionID
///     var title: String? { "Feed" }
///     var cells: [Cell]
/// }
/// ```
///
/// ## ViewModel usage with DevSectionStore
/// ```swift
/// var store = DevSectionStore<FeedSection>()
/// store.set(FeedSection(id: .featured, cells: [...]))
/// store.updateCells(id: .recent) { cells in
///     cells = latestPosts.map { .post($0) }
/// }
/// ```
///
/// ## View controller
/// ```swift
/// viewModel.$store
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
    /// Must be `Hashable` so it can be used as a `NSDiffableDataSourceSnapshot` section identifier.
    associatedtype SectionID: Hashable

    var id: SectionID { get }
    /// Optional section header title. `nil` means no header.
    var title: String? { get }
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
