//
//  CombineGuide.swift
//
//  A practical reference for Combine operators, organised by what you are
//  trying to accomplish — not by operator name.
//
//  Each section shows a realistic ViewModel / Repository pattern.
//  Nothing here is compiled; it is a living cheat sheet.
//

// ============================================================
// MARK: - 1. Transform a value
// ============================================================
//
//  Operator: map
//  Use when: you have a value and need to convert it to another type.
//  Think of it as: Swift's regular .map on arrays, but for a stream.
//
//  // API returns a raw DTO — convert it to a ViewModel
//  apiClient.fetchUser(id: 42)                        // AnyPublisher<UserDTO, Error>
//      .map { UserViewModel(dto: $0) }                // AnyPublisher<UserViewModel, Error>
//      .sink(receiveValue: { self.user = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: compactMap / filterNil
//  Use when: the upstream emits Optional<T> and you only care about non-nil values.
//
//  $selectedUserID                  // AnyPublisher<Int?, Never>
//      .filterNil()                 // AnyPublisher<Int, Never>  — nils are dropped
//      .flatMapLatest { id in
//          apiClient.fetchUser(id: id)
//      }
//      .sink(receiveValue: { self.user = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)


// ============================================================
// MARK: - 2. Fetch data based on another value (chaining)
// ============================================================
//
//  Operator: flatMap
//  Use when: each upstream value triggers a NEW async operation,
//            and you want ALL results (not just the latest one).
//  Think of it as: for each value, start a sub-pipeline and merge all outputs.
//
//  ⚠️  If upstream emits quickly (e.g. user typing), every emission starts a
//      new request and results may arrive out of order. Prefer flatMapLatest
//      in those cases.
//
//  // Load every order for each incoming user ID
//  $userID                                            // AnyPublisher<Int, Never>
//      .flatMap { id in
//          apiClient.fetchOrders(for: id)             // starts a request per ID
//      }
//      .sink(receiveValue: { self.orders = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
//  // Sequential chaining: fetch a user, then fetch their posts
//  apiClient.fetchUser(id: 42)
//      .flatMap { user in
//          apiClient.fetchPosts(authorID: user.id)
//      }
//      .sink(receiveValue: { self.posts = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: flatMapLatest  (DevToolsCore extension)
//  Use when: each upstream value triggers a NEW async operation
//            and only the LATEST result matters. Previous in-flight
//            work is automatically cancelled.
//  Think of it as: flatMap + "cancel whatever was running before".
//
//  // Search: only the response for the most recent query is delivered.
//  // If the user types "sw", then "swi", then "swif", only the "swif"
//  // response arrives — the "sw" and "swi" requests are cancelled.
//  $searchText                                        // AnyPublisher<String, Never>
//      .debounce(for: .milliseconds(300),
//                scheduler: DispatchQueue.main)
//      .flatMapLatest { query in
//          apiClient.search(query)
//      }
//      .sink(receiveValue: { self.results = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)


// ============================================================
// MARK: - 3. Combine two independent streams
// ============================================================
//
//  Operator: combineLatest
//  Use when: you need the LATEST value from each of N streams together.
//            Re-emits whenever ANY of the streams emits.
//  Think of it as: "give me the current state of both, any time either changes".
//
//  // Filter a list: re-apply the filter whenever items OR the filter changes.
//  Publishers.CombineLatest($items, $activeFilter)    // fires when either changes
//      .map { items, filter in
//          items.filter { filter.matches($0) }
//      }
//      .assign(to: &$filteredItems)
//
//  // Form validation: enable submit only when both fields are valid.
//  Publishers.CombineLatest($emailIsValid, $passwordIsValid)
//      .map { $0 && $1 }
//      .weakAssign(to: \.isEnabled, on: submitButton)
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: zip
//  Use when: you want to PAIR the Nth emission of stream A with the
//            Nth emission of stream B. Waits for both sides.
//  Think of it as: a zipper — one tooth from each side, in lockstep.
//
//  ⚠️  Unlike combineLatest, zip will not re-emit until BOTH publishers
//      have produced a new value. If one is slow, the other waits.
//
//  // Run two API calls in parallel, combine when BOTH have responded.
//  let profilePublisher = apiClient.fetchProfile(id: userID)
//  let settingsPublisher = apiClient.fetchSettings(id: userID)
//
//  Publishers.Zip(profilePublisher, settingsPublisher)
//      .map { profile, settings in DashboardViewModel(profile, settings) }
//      .sink(receiveValue: { self.dashboard = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: merge
//  Use when: you have multiple publishers of the SAME type and want
//            a single stream with all their values interleaved.
//  Think of it as: multiple rivers flowing into one.
//
//  // React to either a pull-to-refresh OR a push notification trigger.
//  let refreshTrigger: AnyPublisher<Void, Never>
//  let pushTrigger: AnyPublisher<Void, Never>
//
//  Publishers.Merge(refreshTrigger, pushTrigger)
//      .flatMapLatest { _ in apiClient.fetchFeed() }
//      .sink(receiveValue: { self.feed = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)


// ============================================================
// MARK: - 4. Handle errors
// ============================================================
//
//  Operator: catch
//  Use when: you want to recover from a failure with a fallback publisher.
//            The original stream ENDS and the fallback takes over.
//
//  apiClient.fetchFeed()
//      .catch { _ in
//          localCache.loadFeed()          // fall back to cached data on error
//      }
//      .sink(receiveValue: { self.feed = $0 })
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: mapCatch  (DevToolsCore extension)
//  Use when: you want to recover with a publisher of the SAME failure type.
//            Useful when the fallback itself can fail.
//
//  apiClient.fetchFeed()
//      .mapCatch { error in
//          backupClient.fetchFeed()       // also returns AnyPublisher<Feed, APIError>
//      }
//      .sink(receiveValue: { self.feed = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: retry(times:delay:)  (DevToolsCore extension)
//  Use when: transient failures are expected (network hiccups, rate limits).
//            Waits `delay` between each attempt.
//
//  apiClient.fetchFeed()
//      .retry(times: 3, delay: .seconds(2), scheduler: DispatchQueue.main)
//      .sink(receiveValue: { self.feed = $0 },
//            completionError: { self.showPermanentError($0) })
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: asResult  (DevToolsCore extension)
//  Use when: you want errors as VALUES rather than stream termination.
//            After an error the subscription stays alive for future values.
//
//  apiClient.fetchFeed()
//      .asResult()                        // AnyPublisher<Result<Feed, Error>, Never>
//      .sink { [weak self] result in
//          switch result {
//          case .success(let feed):  self?.feed = feed
//          case .failure(let error): self?.errorBanner = error.localizedDescription
//          }
//      }
//      .store(in: &cancellables)


// ============================================================
// MARK: - 5. Control which thread work runs on
// ============================================================
//
//  Key rule: subscribe(on:) controls where the SUBSCRIPTION starts
//            (i.e. where the work is done).
//            receive(on:) controls where DOWNSTREAM operators and sinks run.
//
//  Most common pattern: do heavy work on a background queue,
//  deliver results on the main queue for UI updates.
//
//  apiClient.fetchFeed()
//      .subscribe(on: DispatchQueue.global())   // network + decoding off main
//      .receive(on: DispatchQueue.main)          // UI update on main
//      .sink(receiveValue: { self.feed = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
//  ⚠️  .receive(on:) affects everything BELOW it in the chain.
//      Place it as late as possible — right before the sink.
//
//  ⚠️  For URLSession publishers, the work already runs off-main,
//      so subscribe(on:) is often not needed — receive(on:) is enough.


// ============================================================
// MARK: - 6. Control emission rate (debounce vs throttle)
// ============================================================
//
//  Operator: debounce
//  Use when: you want to wait for a PAUSE before acting.
//            Resets the timer every time a new value arrives.
//  Typical use: search-as-you-type, form validation, autosave.
//
//  $searchText
//      .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
//      .flatMapLatest { apiClient.search($0) }
//      .sink(receiveValue: { self.results = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────────
//
//  Operator: throttle
//  Use when: you want at most one emission per time window,
//            regardless of how many arrive. Does NOT reset on new values.
//  Typical use: button taps, scroll position updates, sensor data.
//
//  buttonTapPublisher
//      .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
//      .flatMap { apiClient.submitForm() }
//      .sink(receiveValue: { self.handleSuccess($0) },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
//  debounce vs throttle at a glance:
//  ┌─────────────────────────────────────────────────────────┐
//  │  Input:     -- A - B - C -------- D - E --------       │
//  │  debounce:  ------------ C ------------ E ------       │
//  │  throttle:  -- A ---------- D ---- D --------          │
//  └─────────────────────────────────────────────────────────┘
//  debounce fires AFTER the stream goes quiet.
//  throttle fires at a steady pace regardless of silence.


// ============================================================
// MARK: - 7. Track what changed (withPrevious)
// ============================================================
//
//  Operator: withPrevious  (DevToolsCore extension)
//  Use when: you need BOTH the old and new value to react to a change.
//
//  // Animate list changes by comparing old and new items.
//  $items
//      .withPrevious()
//      .sink { previous, current in
//          let added   = current.filter { !(previous ?? []).contains($0) }
//          let removed = (previous ?? []).filter { !current.contains($0) }
//          tableView.performBatchUpdates { ... }
//      }
//      .store(in: &cancellables)
//
//  // Detect direction of a value change.
//  $scrollOffset
//      .withPrevious()
//      .map { previous, current -> ScrollDirection in
//          guard let previous else { return .none }
//          return current > previous ? .down : .up
//      }
//      .sink { self.updateNavBar(for: $0) }
//      .store(in: &cancellables)


// ============================================================
// MARK: - 8. Run N requests in parallel
// ============================================================
//
//  Problem: Publishers.Zip only supports up to 4 publishers.
//           For N requests you need zipAll() (DevToolsCore extension).
//
//  Operator: zipAll()  (DevToolsCore extension)
//  Use when: you have an array of publishers (same type) and want ONE result
//            array back, after ALL have completed, in INPUT order.
//
//  // ❌ Does not compile beyond 4 publishers
//  Publishers.Zip(p0, p1, p2, p3, p4 ...)
//
//  // ✅ Works for any N
//  let publishers = postIDs.map { id in api.fetchPost(id: id) }
//
//  publishers
//      .zipAll()                          // AnyPublisher<[Post], Error>
//      .receive(on: DispatchQueue.main)
//      .sink(receiveValue: { self.posts = $0 },
//            completionError: { self.error = $0 })
//      .store(in: &cancellables)
//
//  Key properties:
//  - All requests start simultaneously (parallel, not sequential)
//  - Results are in INPUT order, not completion order
//  - If ONE fails, the whole chain fails immediately
//
// ─────────────────────────────────────────────────────────────
//
//  Alternative: async/await with withThrowingTaskGroup
//  For one-shot parallel fetching on iOS 17+, this is often simpler.
//  Use it when you are in an async context already.
//
//  func fetchPosts(ids: [Int]) async throws -> [Post] {
//      try await withThrowingTaskGroup(of: (Int, Post).self) { group in
//          for (index, id) in ids.enumerated() {
//              group.addTask { (index, try await api.fetchPost(id: id)) }
//          }
//          var results = [(Int, Post)]()
//          for try await pair in group { results.append(pair) }
//          return results.sorted { $0.0 < $1.0 }.map { $0.1 }
//      }
//  }
//
//  Combine zipAll vs async/await taskGroup:
//  ┌────────────────────┬───────────────┬──────────────────┐
//  │                    │   zipAll()    │  withTaskGroup   │
//  ├────────────────────┼───────────────┼──────────────────┤
//  │ Reactive pipeline  │      ✅       │       ❌         │
//  │ Combine chain      │      ✅       │       ❌         │
//  │ One-shot fetch     │      ✅       │       ✅         │
//  │ Very large N (100+)│      ⚠️       │       ✅         │
//  │ Backpressure       │      ✅       │       ❌         │
//  └────────────────────┴───────────────┴──────────────────┘


// ============================================================
// MARK: - 9. Bind to UI (weakAssign vs assign)
// ============================================================
//
//  Operator: weakAssign  (DevToolsCore extension)
//  Use when: you want to assign values to a UI property.
//            Always prefer this over assign(to:on:) to avoid retain cycles.
//
//  // ❌ Creates a retain cycle: ViewController → cancellable → viewModel → ViewController
//  viewModel.$title
//      .assign(to: \.titleLabel.text, on: self)
//      .store(in: &cancellables)
//
//  // ✅ Safe: ViewController is held weakly
//  viewModel.$title
//      .weakAssign(to: \.titleLabel.text, on: self)
//      .store(in: &cancellables)
