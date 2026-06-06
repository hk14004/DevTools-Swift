//
//  DevSectionStore.swift
//
//
//  Created by Hardijs on 04/06/2026.
//

import UIKit

/// A typed, ordered container for ``DevTableSection`` values — the recommended way to manage
/// multi-section table data on the ViewModel side.
///
/// `DevSectionStore` separates *ordering* (an explicit index array) from *lookup* (a dictionary),
/// giving you O(1) section access, explicit position control, and atomic cell updates — all things
/// a plain `[Section]` array cannot provide cleanly.
///
/// ## Quick start
///
/// ```swift
/// // 1. Define your section
/// struct ProfileSection: DevTableSection {
///     enum SectionID: Hashable { case header, stats, posts }
///     enum Cell: DevTableSectionCell { case avatar(AvatarVM); case stat(StatVM); case post(PostVM) }
///     var id: SectionID
///     var title: String? { nil }
///     var cells: [Cell]
/// }
///
/// // 2. In your ViewModel
/// class ProfileViewModel {
///     @Published private(set) var store = DevSectionStore<ProfileSection>()
///
///     func load() {
///         store.set(ProfileSection(id: .header, cells: [.avatar(avatarVM)]))
///         store.set(ProfileSection(id: .stats,  cells: stats.map { .stat($0) }))
///         store.set(ProfileSection(id: .posts,  cells: []))
///     }
///
///     func postsLoaded(_ posts: [PostVM]) {
///         // Atomic update — only touches .posts cells, no full section replacement
///         store.updateCells(id: .posts) { cells in
///             cells = posts.map { .post($0) }
///         }
///     }
/// }
///
/// // 3. In your ViewController
/// viewModel.$store
///     .map { $0.asSnapshot() }
///     .receive(on: DispatchQueue.main)
///     .sink { [weak self] in self?.dataSource.apply($0, animatingDifferences: true) }
///     .store(in: &cancellables)
/// ```
///
/// ## Comparison with the old Array approach
///
/// | Capability | `[Section]` + extensions | `DevSectionStore` |
/// |---|---|---|
/// | Section lookup | O(n) linear scan | O(1) dictionary |
/// | Dynamic SectionID (associated values) | ❌ required CaseIterable | ✅ only Hashable needed |
/// | Insert at specific position | ❌ always appends | ✅ `set(_:at:)` |
/// | Reorder without rebuild | ❌ | ✅ `move(id:to:)` |
/// | Atomic cell update | ❌ full section replace | ✅ `updateCells(id:transform:)` |
/// | Snapshot conversion | `array.asSnapshot()` | `store.asSnapshot()` |
///
public struct DevSectionStore<S: DevTableSection> {

    // MARK: - Private storage

    /// Preserves the display order of section IDs.
    private var order: [S.SectionID] = []

    /// O(1) lookup by section ID.
    private var storage: [S.SectionID: S] = [:]

    // MARK: - Init

    public init() {}

    // MARK: - Read

    /// All sections in their current display order.
    public var sections: [S] {
        order.compactMap { storage[$0] }
    }

    /// Returns the section for `id`, or `nil` if it is not present.
    public subscript(id: S.SectionID) -> S? {
        storage[id]
    }

    /// Returns `true` if the store contains a section with the given `id`.
    public func contains(id: S.SectionID) -> Bool {
        storage[id] != nil
    }

    /// The number of sections currently in the store.
    public var count: Int { order.count }

    /// `true` when the store contains no sections.
    public var isEmpty: Bool { order.isEmpty }

    // MARK: - Write

    /// Inserts or replaces a section, placing it at `index` in the display order.
    ///
    /// - If the section already exists it is updated in-place and **moved** to `index`.
    /// - If `index` is `nil` the section is appended (or stays at its current position
    ///   when updating an existing section without an explicit position).
    ///
    /// ```swift
    /// store.set(promoSection, at: 1)   // insert Promotions as the second section
    /// store.set(updatedHeader)          // update Header without moving it
    /// ```
    public mutating func set(_ section: S, at index: Int? = nil) {
        let existingIndex = order.firstIndex(of: section.id)

        if let existingIndex {
            order.remove(at: existingIndex)
        }

        storage[section.id] = section

        let target: Int
        if let index {
            target = min(max(index, 0), order.count)
        } else if let existingIndex {
            // No explicit index: keep it where it was (adjusted for the removal above)
            target = min(existingIndex, order.count)
        } else {
            target = order.count
        }

        order.insert(section.id, at: target)
    }

    /// Removes the section with the given `id`. A no-op if the section is not present.
    public mutating func remove(id: S.SectionID) {
        guard storage[id] != nil else { return }
        storage.removeValue(forKey: id)
        order.removeAll { $0 == id }
    }

    /// Moves an existing section to a new display index without touching its cells.
    ///
    /// A no-op if the section is not present.
    ///
    /// ```swift
    /// // Push footer to the very end after a new section is inserted
    /// store.move(id: .footer, to: store.count - 1)
    /// ```
    public mutating func move(id: S.SectionID, to index: Int) {
        guard storage[id] != nil else { return }
        order.removeAll { $0 == id }
        let target = min(max(index, 0), order.count)
        order.insert(id, at: target)
    }

    /// Applies `transform` to the cells of the section identified by `id`.
    ///
    /// This is an **atomic** update — only the cells array is touched, and no full section
    /// replacement is needed. A no-op if the section is not present.
    ///
    /// ```swift
    /// store.updateCells(id: .posts) { cells in
    ///     cells = posts.map { .post($0) }
    /// }
    ///
    /// store.updateCells(id: .stats) { cells in
    ///     cells.append(.stat(newStat))
    /// }
    /// ```
    public mutating func updateCells(id: S.SectionID, transform: (inout [S.Cell]) -> Void) {
        guard var section = storage[id] else { return }
        transform(&section.cells)
        storage[id] = section
    }

    /// Removes all sections from the store.
    public mutating func removeAll() {
        order.removeAll()
        storage.removeAll()
    }

    // MARK: - Snapshot

    /// Converts the store into an `NSDiffableDataSourceSnapshot` ready to apply to a
    /// `UITableViewDiffableDataSource`.
    ///
    /// Sections appear in the snapshot in the same order they were inserted/moved.
    ///
    /// ```swift
    /// viewModel.$store
    ///     .map { $0.asSnapshot() }
    ///     .receive(on: DispatchQueue.main)
    ///     .sink { [weak self] snapshot in
    ///         self?.dataSource.apply(snapshot, animatingDifferences: true)
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    public func asSnapshot() -> NSDiffableDataSourceSnapshot<S.SectionID, S.Cell> {
        var snapshot = NSDiffableDataSourceSnapshot<S.SectionID, S.Cell>()
        snapshot.appendSections(order)
        order.forEach { id in
            if let section = storage[id] {
                snapshot.appendItems(section.cells, toSection: id)
            }
        }
        return snapshot
    }
}
