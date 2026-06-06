//
//  UIControl.swift
//
//
//  Created by Hardijs Ķirsis on 09/09/2023.
//

import Combine
import UIKit

public extension UIControl {
    func eventPublisher(for event: UIControl.Event) -> UIControl.EventPublisher {
        EventPublisher(control: self, event: event)
    }
}

public extension UIControl {
    struct EventPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: UIControl
        private let event: UIControl.Event

        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Void {
            let subscription = EventSubscription(subscriber: subscriber, control: control, event: event)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension UIControl {
    final class EventSubscription<S: Subscriber>: Subscription where S.Input == Void {
        private var subscriber: S?
        private weak var control: UIControl?
        private let event: UIControl.Event

        init(subscriber: S, control: UIControl, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            control.addTarget(self, action: #selector(handleEvent), for: event)
        }

        @objc func handleEvent(_ sender: UIControl) {
            _ = subscriber?.receive(())
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
            control?.removeTarget(self, action: #selector(handleEvent), for: event)
        }
    }
}
