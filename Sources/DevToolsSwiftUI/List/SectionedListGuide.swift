//
//  SectionedListGuide.swift
//
//  SwiftUI equivalent of UIKit's DevSectionStore + UITableViewDiffableDataSource pattern.
//
//  ─────────────────────────────────────────────────────────────────────────────
//  WHY THERE IS NO DevSectionStore EQUIVALENT FOR SwiftUI
//  ─────────────────────────────────────────────────────────────────────────────
//
//  UIKit required an explicit pipeline to drive animations:
//
//    ViewModel                    ViewController
//    ─────────────────────        ──────────────────────────────────────────────
//    DevSectionStore  ──────────▶  store.asSnapshot()
//    (O(1) lookup,                  ▼
//     explicit ordering)          NSDiffableDataSourceSnapshot
//     updateCells(id:)              ▼
//                                 dataSource.apply(snapshot, animatingDifferences: true)
//
//  SwiftUI collapses this entire pipeline:
//
//    ViewModel                    View
//    ─────────────────────        ──────────────────────────────────────────────
//    @Observable                  List {
//    var sections: [Section]  ──▶   ForEach(sections) { section in
//                                     Section(section.title) {
//    // mutate the array                 ForEach(section.cells) { CellView($0) }
//    sections[idx].cells = …          }
//                                   }
//                                 }
//
//  SwiftUI diffs by Identifiable identity automatically — no snapshot, no data
//  source, no store needed. You mutate the array; SwiftUI handles the rest.
//
//  ─────────────────────────────────────────────────────────────────────────────
//  LIGHTWEIGHT CONVENTION (optional, for cross-screen consistency)
//  ─────────────────────────────────────────────────────────────────────────────
//
//  If you want consistent ViewModel structure across screens, a 3-line protocol
//  is all that is needed — nothing like the full DevTableSection machinery:
//
//  protocol SectionModel: Identifiable {
//      associatedtype Cell: Identifiable
//      var title: String? { get }
//      var cells: [Cell] { get set }
//  }
//
//  ─────────────────────────────────────────────────────────────────────────────
//  EXAMPLES  (live previews below — open canvas: Editor ▸ Canvas  ⌥⌘↩)
//  ─────────────────────────────────────────────────────────────────────────────


// MARK: - Example 1: Static multi-section screen
//
// UIKit equivalent: DevSectionStore with fixed SectionIDs, cells loaded async.
// SwiftUI: @Observable class + plain [Section] array.
//
//  enum ProfileSectionID: Hashable { case header, stats, posts }
//
//  struct ProfileSection: Identifiable {
//      let id: ProfileSectionID
//      var title: String?
//      var cells: [ProfileCell]
//  }
//
//  @Observable
//  final class ProfileViewModel {
//      var sections: [ProfileSection] = [
//          ProfileSection(id: .header, title: nil,      cells: []),
//          ProfileSection(id: .stats,  title: "Stats",  cells: []),
//          ProfileSection(id: .posts,  title: "Posts",  cells: []),
//      ]
//
//      func userLoaded(_ user: User) {
//          update(.header) { $0.cells = [.avatar(AvatarVM(user))] }
//          update(.stats)  { $0.cells = user.stats.map { .stat(StatVM($0)) } }
//      }
//
//      func postsLoaded(_ posts: [Post]) {
//          update(.posts) { $0.cells = posts.map { .post(PostVM($0)) } }
//      }
//
//      // Convenience — same idea as DevSectionStore.updateCells, without the machinery.
//      private func update(_ id: ProfileSectionID, transform: (inout ProfileSection) -> Void) {
//          guard let idx = sections.firstIndex(where: { $0.id == id }) else { return }
//          transform(&sections[idx])
//      }
//  }
//
//  struct ProfileView: View {
//      @State var model = ProfileViewModel()
//
//      var body: some View {
//          List {
//              ForEach(model.sections) { section in
//                  Section(section.title ?? "") {
//                      ForEach(section.cells) { CellView($0) }
//                  }
//              }
//          }
//          .task { await model.load() }
//      }
//  }
//
// No snapshot. No data source. SwiftUI diffs by ProfileSectionID identity.


// MARK: - Example 2: Dynamic sections with associated values
//
// UIKit equivalent: DevSectionStore with enum SectionID { case category(Int) }.
// SwiftUI: identical model — Identifiable does not require CaseIterable either.
//
//  enum FeedSectionID: Hashable {
//      case featured
//      case category(Int)   // ✅ associated values work exactly the same
//      case footer
//  }
//
//  struct FeedSection: Identifiable {
//      let id: FeedSectionID
//      var title: String?
//      var cells: [FeedCell]
//  }
//
//  func loaded(featured: [Post], categories: [(id: Int, name: String, posts: [Post])]) {
//      var next: [FeedSection] = []
//      next.append(FeedSection(id: .featured, title: "Featured",
//                              cells: featured.map { .post(PostVM($0)) }))
//      for cat in categories {
//          next.append(FeedSection(id: .category(cat.id), title: cat.name,
//                                  cells: cat.posts.map { .post(PostVM($0)) }))
//      }
//      next.append(FeedSection(id: .footer, title: nil, cells: [.loadMore]))
//      sections = next   // single assignment — SwiftUI diffs the whole thing
//  }
//
// Ordering is just array order. No store.move(), no store.set(_:at:) needed —
// you build the desired order and assign.


// MARK: - Example 3: Conditional section visibility
//
// UIKit equivalent: store.remove(id:) / store.set(section, at:)
// SwiftUI: filter the array — SwiftUI animates insertions and removals automatically.
//
//  func applyState(_ state: CheckoutState) {
//      var next: [CheckoutSection] = [
//          CheckoutSection(id: .cart,     cells: state.items.map   { .cartItem($0) }),
//          CheckoutSection(id: .delivery, cells: state.options.map { .delivery($0) }),
//          CheckoutSection(id: .summary,  cells: [.total(state.total)]),
//      ]
//      if !state.promos.isEmpty {
//          let promos = CheckoutSection(id: .promotions,
//                                      cells: state.promos.map { .promo($0) })
//          next.insert(promos, at: 1)   // explicit position, same as store.set(_:at:1)
//      }
//      withAnimation { sections = next }
//  }
//
// Adding .animation(.default) on the List or wrapping the mutation in withAnimation
// gives the same animated insert/remove as UITableView diffable data source.


// MARK: - Example 4: Targeted cell update  (updateCells equivalent)
//
// UIKit equivalent: store.updateCells(id: .liveData) { cells in … }
// SwiftUI: direct index mutation — @Observable triggers re-render automatically.
//
//  func refreshTimestamp() {
//      guard let sIdx = sections.firstIndex(where: { $0.id == .liveData }) else { return }
//      sections[sIdx].cells = sections[sIdx].cells.map { cell in
//          if case .timestamp(let id, let label, _) = cell {
//              return .timestamp(id: id, label: label, time: Date())
//          }
//          return cell
//      }
//  }
//
// SwiftUI only re-renders the rows whose Identifiable identity matched a changed cell.
// There is no need for an "atomic" wrapper — value-type mutation on @Observable is
// already atomic from the view's perspective.


// MARK: - Live Previews

#if DEBUG
import SwiftUI

// ── Shared model types ────────────────────────────────────────────────────────

private enum _SectionID: Hashable {
    case header
    case category(Int)   // demonstrates associated-value IDs
    case liveData
    case footer
}

private enum _Cell: Identifiable {
    case text(id: String, title: String, detail: String?)
    case timestamp(id: String, label: String, time: Date?)
    case actionButton(id: String, label: String)

    var id: String {
        switch self {
        case .text(let id, _, _):         return "text_\(id)"
        case .timestamp(let id, _, _):    return "ts_\(id)"
        case .actionButton(let id, _):    return "btn_\(id)"
        }
    }
}

private struct _Section: Identifiable {
    let id: _SectionID
    var title: String?
    var cells: [_Cell]
}

// ── Shared cell renderer ──────────────────────────────────────────────────────
//
// Each cell case maps to its own View — the switch stays one line per case.
// This is the SwiftUI equivalent of dequeuing a typed UITableViewCell subclass.

private struct _CellView: View {
    let cell: _Cell

    var body: some View {
        switch cell {
        case .text(_, let title, let detail):
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                if let detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 2)

        case .timestamp(_, let label, let time):
            HStack {
                Text(label)
                Spacer()
                Text(time.map(formatted) ?? "—")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(time == nil ? .secondary : .primary)
                    .contentTransition(.numericText())
            }

        case .actionButton(_, let label):
            Button(label) {}
                .foregroundStyle(.tint)
        }
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }
}

// ── Preview 1: Static multi-section list ─────────────────────────────────────

#Preview("Static sections") {
    let sections: [_Section] = [
        _Section(id: .header, title: "Featured", cells: [
            .text(id: "p1", title: "Mastering Swift Concurrency",    detail: "by @johndoe"),
            .text(id: "p2", title: "Building Great APIs",             detail: "by @janedoe"),
        ]),
        _Section(id: .category(42), title: "Swift", cells: [
            .text(id: "p3", title: "Swift 6 Migration Guide",         detail: nil),
            .text(id: "p4", title: "Typed throws in practice",        detail: nil),
        ]),
        _Section(id: .category(17), title: "SwiftUI", cells: [
            .text(id: "p5", title: "Observation framework deep-dive", detail: nil),
        ]),
        _Section(id: .footer, title: nil, cells: [
            .text(id: "load", title: "Load more…",                    detail: nil),
        ]),
    ]

    List {
        ForEach(sections) { section in
            Section(section.title ?? "") {
                ForEach(section.cells) { _CellView(cell: $0) }
            }
        }
    }
    .listStyle(.insetGrouped)
}

// ── Preview 2: Conditional visibility + withAnimation ────────────────────────
//
// Tap "Toggle Promotions" to insert/remove a section with animation.
// This is the SwiftUI equivalent of store.remove(id:) / store.set(_:at:).

@Observable
private final class _ConditionalModel {
    var sections: [_Section] = []
    private var showPromos = false

    init() { rebuild() }

    func togglePromos() {
        showPromos.toggle()
        withAnimation { rebuild() }
    }

    private func rebuild() {
        var next: [_Section] = [
            _Section(id: .header, title: "Cart", cells: [
                .text(id: "i1", title: "Item A", detail: "$12.00"),
                .text(id: "i2", title: "Item B", detail: "$8.50"),
            ]),
            _Section(id: .footer, title: "Summary", cells: [
                .text(id: "total", title: "Total", detail: "$20.50"),
                .actionButton(id: "checkout", label: "Checkout"),
            ]),
        ]
        if showPromos {
            next.insert(_Section(id: .category(0), title: "Promotions 🎉", cells: [
                .text(id: "pr1", title: "10% off your order", detail: "Code: SWIFT10"),
            ]), at: 1)
        }
        sections = next
    }
}

#Preview("Conditional section visibility") {
    @Previewable @State var model = _ConditionalModel()

    List {
        ForEach(model.sections) { section in
            Section(section.title ?? "") {
                ForEach(section.cells) { _CellView(cell: $0) }
            }
        }
    }
    .listStyle(.insetGrouped)
    .safeAreaInset(edge: .bottom) {
        Button("Toggle Promotions") { model.togglePromos() }
            .buttonStyle(.borderedProminent)
            .padding()
    }
}

// ── Preview 3: Targeted cell update ──────────────────────────────────────────
//
// Tap the button to update only the timestamp cell inside one section.
// SwiftUI re-renders only the affected row — equivalent to store.updateCells(id:).
// No snapshot needed. Direct index mutation on @Observable is sufficient.

@Observable
private final class _AtomicUpdateModel {
    var sections: [_Section]

    init() {
        sections = [
            _Section(id: .header, title: "Other sections", cells: [
                .text(id: "note", title: "These cells are unaffected",
                      detail: "Tap the button — only the timestamp row changes"),
            ]),
            _Section(id: .liveData, title: "Live data section", cells: [
                .text(id: "desc", title: "Timestamp cell", detail: "Only this value changes"),
                .timestamp(id: "ts", label: "Last updated", time: nil),
            ]),
            _Section(id: .footer, title: "Actions", cells: [
                .actionButton(id: "stamp_btn", label: "Stamp current time ↑"),
            ]),
        ]
    }

    func stampCurrentTime() {
        guard let sIdx = sections.firstIndex(where: { $0.id == .liveData }) else { return }
        sections[sIdx].cells = sections[sIdx].cells.map { cell in
            if case .timestamp(let id, let label, _) = cell {
                return .timestamp(id: id, label: label, time: Date())
            }
            return cell
        }
    }
}

#Preview("Targeted cell update") {
    @Previewable @State var model = _AtomicUpdateModel()

    List {
        ForEach(model.sections) { section in
            Section(section.title ?? "") {
                ForEach(section.cells) { cell in
                    switch cell {
                    case .actionButton(_, let label):
                        Button(label) { withAnimation { model.stampCurrentTime() } }
                            .foregroundStyle(.tint)
                    default:
                        _CellView(cell: cell)
                    }
                }
            }
        }
    }
    .listStyle(.insetGrouped)
}

#endif
