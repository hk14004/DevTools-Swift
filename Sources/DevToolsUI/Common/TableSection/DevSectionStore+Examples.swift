//
//  DevSectionStore+Examples.swift
//
//  Usage examples for DevSectionStore — not compiled into production code.
//  Read this file to understand common patterns.
//

// MARK: - Example 1: Static multi-section profile screen
//
// A profile screen with a fixed set of sections whose existence is known
// at compile time. The simplest case.
//
// ┌─────────────────────────────────────────────────────────────┐
// │  [Avatar]  John Doe  · @johndoe            ← header        │
// │──────────────────────────────────────────────────────────── │
// │  Posts: 120   Followers: 4.2k   Following: 310  ← stats    │
// │──────────────────────────────────────────────────────────── │
// │  Post 1                                    ← posts         │
// │  Post 2                                                     │
// └─────────────────────────────────────────────────────────────┘

/*

import UIKit
import Combine

// MARK: Models

struct ProfileSection: DevTableSection {

    enum SectionID: Hashable {
        case header
        case stats
        case posts
    }

    enum Cell: DevTableSectionCell {
        case avatar(AvatarViewModel)
        case stat(StatViewModel)
        case post(PostViewModel)
    }

    var id: SectionID
    var title: String? { nil }      // computed — no mutability required
    var cells: [Cell]
}

// MARK: ViewModel

final class ProfileViewModel {

    @Published private(set) var store = DevSectionStore<ProfileSection>()

    init() {
        // Pre-populate with empty sections so the order is established upfront.
        store.set(ProfileSection(id: .header, cells: []))
        store.set(ProfileSection(id: .stats,  cells: []))
        store.set(ProfileSection(id: .posts,  cells: []))
    }

    func userLoaded(_ user: User) {
        // Atomic update — only cells are touched, section identity and order unchanged.
        store.updateCells(id: .header) { cells in
            cells = [.avatar(AvatarViewModel(user: user))]
        }
        store.updateCells(id: .stats) { cells in
            cells = user.stats.map { .stat(StatViewModel($0)) }
        }
    }

    func postsLoaded(_ posts: [Post]) {
        store.updateCells(id: .posts) { cells in
            cells = posts.map { .post(PostViewModel($0)) }
        }
    }
}

// MARK: ViewController

final class ProfileViewController: UIViewController {

    private var dataSource: UITableViewDiffableDataSource<ProfileSection.SectionID, ProfileSection.Cell>!
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: ProfileViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        bindStore()
    }

    private func bindStore() {
        viewModel.$store
            .map { $0.asSnapshot() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
}

*/


// MARK: - Example 2: Dynamic sections with associated values
//
// A feed screen where sections come from an API and may carry a server-side
// category ID. CaseIterable was impossible for this; Hashable-only works fine.
//
// ┌─────────────────────────────────────────────────────────────┐
// │  Featured                                  ← static        │
// │──────────────────────────────────────────────────────────── │
// │  Category: "Swift"       (id: 42)          ← dynamic       │
// │  Category: "SwiftUI"     (id: 17)          ← dynamic       │
// │──────────────────────────────────────────────────────────── │
// │  Footer                                    ← static        │
// └─────────────────────────────────────────────────────────────┘

/*

struct FeedSection: DevTableSection {

    // ✅ Associated value — impossible with the old CaseIterable constraint.
    enum SectionID: Hashable {
        case featured
        case category(Int)   // server-provided category ID
        case footer
    }

    enum Cell: DevTableSectionCell {
        case post(PostViewModel)
        case categoryHeader(CategoryViewModel)
        case footerAction
    }

    var id: SectionID
    var title: String? { nil }
    var cells: [Cell]
}

final class FeedViewModel {

    @Published private(set) var store = DevSectionStore<FeedSection>()

    func load(featuredPosts: [Post], categories: [Category]) {
        // 1. Set static bookend sections at known positions.
        store.set(FeedSection(id: .featured, cells: featuredPosts.map { .post(PostViewModel($0)) }), at: 0)
        store.set(FeedSection(id: .footer,   cells: [.footerAction]))

        // 2. Insert dynamic category sections between them.
        let insertionStart = 1
        for (offset, category) in categories.enumerated() {
            let section = FeedSection(
                id: .category(category.id),
                cells: [.categoryHeader(CategoryViewModel(category))]
            )
            store.set(section, at: insertionStart + offset)
        }

        // Footer was appended last — move it back to the end.
        store.move(id: .footer, to: store.count - 1)
    }

    // Remove a category section when the user hides it.
    func hideCategory(id: Int) {
        store.remove(id: .category(id))
    }
}

*/


// MARK: - Example 3: Conditional section visibility
//
// A checkout screen where sections appear or disappear based on state.
// "Promotions" only shows if there are active promos; "Summary" is always last.

/*

struct CheckoutSection: DevTableSection {

    enum SectionID: Hashable {
        case cart
        case promotions
        case delivery
        case summary
    }

    enum Cell: DevTableSectionCell {
        case cartItem(CartItemViewModel)
        case promo(PromoViewModel)
        case deliveryOption(DeliveryViewModel)
        case orderTotal(TotalViewModel)
    }

    var id: SectionID
    var title: String? {
        switch id {
        case .cart:        return "Your Cart"
        case .promotions:  return "Promotions"
        case .delivery:    return "Delivery"
        case .summary:     return nil
        }
    }
    var cells: [Cell]
}

final class CheckoutViewModel {

    @Published private(set) var store = DevSectionStore<CheckoutSection>()

    func applyState(_ state: CheckoutState) {
        // Always-present sections
        store.set(CheckoutSection(id: .cart,     cells: state.items.map    { .cartItem($0) }))
        store.set(CheckoutSection(id: .delivery, cells: state.options.map  { .deliveryOption($0) }))
        store.set(CheckoutSection(id: .summary,  cells: [.orderTotal(TotalViewModel(state.total))]))

        // Conditional section — add or remove based on data.
        if state.promos.isEmpty {
            store.remove(id: .promotions)
        } else {
            // Insert between cart and delivery (index 1).
            store.set(
                CheckoutSection(id: .promotions, cells: state.promos.map { .promo($0) }),
                at: 1
            )
        }
    }
}

*/
