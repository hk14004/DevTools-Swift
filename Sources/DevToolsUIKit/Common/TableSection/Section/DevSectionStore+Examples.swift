//
//  DevSectionStore+Examples.swift
//
//  Documented usage patterns for DevSectionStore.
//
//  Open this file in Xcode — the Preview canvas (Editor ▸ Canvas, or ⌥⌘↩)
//  shows four live examples without needing a host project.
//

// MARK: - Example 1: Static multi-section screen
//
// A profile screen with a known, fixed set of sections.
// All section IDs are defined upfront; cells are populated asynchronously.
//
// ┌─────────────────────────────────────────────────────────────┐
// │  Header      [Avatar]  John Doe · @johndoe                 │
// │──────────────────────────────────────────────────────────── │
// │  Stats       Posts 120 · Followers 4.2k · Following 310    │
// │──────────────────────────────────────────────────────────── │
// │  Posts       Post 1                                        │
// │              Post 2                                        │
// └─────────────────────────────────────────────────────────────┘
//
//  struct ProfileSection: DevTableSection {
//      enum SectionID: Hashable { case header, stats, posts }
//      enum Cell: DevTableSectionCell {
//          case avatar(AvatarViewModel)
//          case stat(StatViewModel)
//          case post(PostViewModel)
//      }
//      var id: SectionID
//      var title: String? { nil }
//      var cells: [Cell]
//  }
//
//  final class ProfileViewModel {
//      @Published private(set) var store = DevSectionStore<ProfileSection>()
//
//      init() {
//          // Establish order immediately; cells arrive later.
//          store.set(ProfileSection(id: .header, cells: []))
//          store.set(ProfileSection(id: .stats,  cells: []))
//          store.set(ProfileSection(id: .posts,  cells: []))
//      }
//
//      func userLoaded(_ user: User) {
//          store.updateCells(id: .header) { $0 = [.avatar(AvatarViewModel(user))] }
//          store.updateCells(id: .stats)  { $0 = user.stats.map { .stat(StatViewModel($0)) } }
//      }
//
//      func postsLoaded(_ posts: [Post]) {
//          store.updateCells(id: .posts) { $0 = posts.map { .post(PostViewModel($0)) } }
//      }
//  }
//
//  // ViewController — single binding drives all sections
//  viewModel.$store
//      .map { $0.asSnapshot() }
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] in self?.dataSource.apply($0, animatingDifferences: true) }
//      .store(in: &cancellables)


// MARK: - Example 2: Dynamic sections with associated values
//
// Sections come from an API and carry a server-side ID.
// CaseIterable was impossible here; Hashable-only works fine.
//
//  struct FeedSection: DevTableSection {
//      enum SectionID: Hashable {
//          case featured
//          case category(Int)   // ✅ associated value — impossible with old CaseIterable constraint
//          case footer
//      }
//      enum Cell: DevTableSectionCell { case post(PostViewModel); case footerAction }
//      var id: SectionID
//      var title: String?
//      var cells: [Cell]
//  }
//
//  func loaded(featured: [Post], categories: [(id: Int, name: String, posts: [Post])]) {
//      store.set(FeedSection(id: .featured, title: "Featured",
//                            cells: featured.map { .post(PostViewModel($0)) }), at: 0)
//      store.set(FeedSection(id: .footer, title: nil, cells: [.footerAction]))
//      for (offset, cat) in categories.enumerated() {
//          store.set(FeedSection(id: .category(cat.id), title: cat.name,
//                               cells: cat.posts.map { .post(PostViewModel($0)) }),
//                    at: 1 + offset)
//      }
//      store.move(id: .footer, to: store.count - 1)
//  }


// MARK: - Example 3: Conditional section visibility
//
// "Promotions" only appears when promos exist — no sentinel empty sections needed.
//
//  func applyState(_ state: CheckoutState) {
//      store.set(CheckoutSection(id: .cart,     cells: state.items.map   { .cartItem($0) }))
//      store.set(CheckoutSection(id: .delivery, cells: state.options.map { .delivery($0) }))
//      store.set(CheckoutSection(id: .summary,  cells: [.total(state.total)]))
//
//      if state.promos.isEmpty {
//          store.remove(id: .promotions)
//      } else {
//          store.set(CheckoutSection(id: .promotions,
//                                   cells: state.promos.map { .promo($0) }), at: 1)
//      }
//  }


// MARK: - Example 4: Atomic cell update (updateCells)
//
// Update only one section's cells without replacing the whole section.
// Typical pattern: a row with a button that triggers a live data refresh.
//
//  func refreshTimestamp() {
//      store.updateCells(id: .liveData) { cells in
//          cells = cells.map { cell in
//              if case .timestamp(let id, let label, _) = cell {
//                  return .timestamp(id: id, label: label, time: Date())
//              }
//              return cell
//          }
//      }
//  }


// MARK: - Xcode Previews
//
// All types are private and self-contained — no host project needed.
// Open the canvas: Editor ▸ Canvas (⌥⌘↩)

#if DEBUG
import SwiftUI

// MARK: Preview cell enum
//
// Using an enum mirrors real-world usage where each case maps to a distinct cell type.
// The ViewController's cellProvider switches on these cases to dequeue the right cell.

private enum _Cell: DevTableSectionCell {
    
    case text(id: String, title: String, detail: String?)
    case timestamp(id: String, label: String, time: Date?)
    case actionButton(id: String, label: String)
    
    // Identity: section positions, not content
    fileprivate var _id: String {
        switch self {
        case .text(let id, _, _):         return "text_\(id)"
        case .timestamp(let id, _, _):    return "ts_\(id)"
        case .actionButton(let id, _):    return "btn_\(id)"
        }
    }
    
    // Content hash: all fields — drives diffable data source reload decisions
    var contentHash: Int {
        var h = Hasher()
        switch self {
        case .text(let id, let title, let detail):
            h.combine(id); h.combine(title); h.combine(detail)
        case .timestamp(let id, let label, let time):
            h.combine(id); h.combine(label); h.combine(time)
        case .actionButton(let id, let label):
            h.combine(id); h.combine(label)
        }
        return h.finalize()
    }
    
    static func == (l: Self, r: Self) -> Bool { l._id == r._id }
    func hash(into h: inout Hasher) { h.combine(_id) }
}

// MARK: Preview section

private enum _SectionID: Hashable {
    case header
    case category(Int)   // demonstrates associated-value SectionID
    case liveData
    case footer
}

private struct _Section: DevTableSection {
    var id: _SectionID
    var title: String?
    var cells: [_Cell]
}

// MARK: Per-cell view types
//
// Each cell case gets its own View struct — all rendering logic lives here,
// not inline in a switch. This is the key pattern for keeping cellProvider /
// cellView manageable as the number of cell types grows.
//
// UIKit equivalent: each case dequeues a dedicated UITableViewCell subclass
// and calls configure(with:) on it. The switch stays one line per case:
//
//   switch cell {
//   case .text(let vm):        return tableView.dequeue(TextCell.self, for: indexPath, with: vm)
//   case .timestamp(let vm):   return tableView.dequeue(TimestampCell.self, for: indexPath, with: vm)
//   case .actionButton(let vm): return tableView.dequeue(ActionCell.self, for: indexPath, with: vm)
//   }

private struct _TextCellView: View {
    let title: String
    let detail: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            if let detail {
                Text(detail).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct _TimestampCellView: View {
    let label: String
    let time: Date?
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(time.map(formatted) ?? "—")
                .font(.caption.monospacedDigit())
                .foregroundColor(time == nil ? .secondary : .primary)
                .contentTransition(.numericText())
        }
    }
    
    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }
}

private struct _ActionButtonCellView: View {
    let label: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(label, action: action)
            .foregroundColor(.accentColor)
    }
}

// MARK: Shared SwiftUI renderer
//
// The switch is now a thin router — one line per case.
// Adding a 20th cell type means adding one line here and one new view struct.

private struct StorePreview: View {
    let store: DevSectionStore<_Section>
    
    var body: some View {
        List {
            ForEach(store.sections, id: \.id) { section in
                Section(header: Text(section.title ?? "").textCase(nil)) {
                    ForEach(section.cells, id: \._id) { cell in
                        cellView(cell)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    private func cellView(_ cell: _Cell) -> some View {
        switch cell {
        case .text(_, let title, let detail):       _TextCellView(title: title, detail: detail)
        case .timestamp(_, let label, let time):    _TimestampCellView(label: label, time: time)
        case .actionButton(_, let label):           _ActionButtonCellView(label: label)
        }
    }
}

// MARK: Preview 1 — Static multi-section feed

#Preview("Static sections") {
    var store = DevSectionStore<_Section>()
    store.set(_Section(id: .header, title: "Featured", cells: [
        .text(id: "p1", title: "Mastering Swift Concurrency",     detail: "by @johndoe"),
        .text(id: "p2", title: "Building Great APIs",              detail: "by @janedoe"),
    ]))
    store.set(_Section(id: .category(42), title: "Swift", cells: [
        .text(id: "p3", title: "Swift 6 Migration Guide",          detail: nil),
        .text(id: "p4", title: "Typed throws in practice",         detail: nil),
    ]))
    store.set(_Section(id: .category(17), title: "SwiftUI", cells: [
        .text(id: "p5", title: "Observation framework deep-dive",  detail: nil),
    ]))
    store.set(_Section(id: .footer, title: nil, cells: [
        .text(id: "load", title: "Load more…",                     detail: nil),
    ]))
    return StorePreview(store: store)
}

// MARK: Preview 2 — Interactive: atomic cell update via button
//
// Demonstrates store.updateCells(id:transform:).
//
// Uses @StateObject + ObservableObject rather than plain @State because
// @State with a mutating struct inside nested ForEach closures is unreliable
// in Xcode previews — the mutation sometimes doesn't trigger a re-render.
// @Published on a class always fires objectWillChange, which the preview
// engine handles correctly on every tap.

@MainActor
private final class _PreviewModel: ObservableObject {
    @Published var store: DevSectionStore<_Section>
    
    init() {
        var s = DevSectionStore<_Section>()
        s.set(_Section(id: .header, title: "Other sections", cells: [
            .text(id: "note", title: "These cells are unaffected",
                  detail: "Tapping the button only updates the section beneath"),
            .text(id: "info", title: "Atomic update demo",
                  detail: "store.updateCells(id:transform:)"),
        ]))
        s.set(_Section(id: .liveData, title: "Live data section", cells: [
            .text(id: "desc", title: "Timestamp cell",
                  detail: "Only this cell's value changes"),
            .timestamp(id: "ts", label: "Last updated", time: nil),
        ]))
        s.set(_Section(id: .footer, title: "Actions", cells: [
            .actionButton(id: "stamp_btn", label: "Stamp current time ↑"),
        ]))
        store = s
    }
    
    func stampCurrentTime() {
        store.updateCells(id: .liveData) { cells in
            cells = cells.map { c in
                if case .timestamp(let id, let label, _) = c {
                    return .timestamp(id: id, label: label, time: Date())
                }
                return c
            }
        }
    }
}

private struct InteractivePreview: View {
    @StateObject private var model = _PreviewModel()
    
    var body: some View {
        List {
            ForEach(model.store.sections, id: \.id) { section in
                Section(header: Text(section.title ?? "").textCase(nil)) {
                    ForEach(section.cells, id: \._id) { cell in
                        cellView(cell)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    private func cellView(_ cell: _Cell) -> some View {
        switch cell {
        case .text(_, let title, let detail):    _TextCellView(title: title, detail: detail)
        case .timestamp(_, let label, let time): _TimestampCellView(label: label, time: time)
        case .actionButton(_, let label):        _ActionButtonCellView(label: label) {
            withAnimation { model.stampCurrentTime() }
        }
        }
    }
}

#Preview("Interactive — atomic cell update") {
    InteractivePreview()
}

#endif
