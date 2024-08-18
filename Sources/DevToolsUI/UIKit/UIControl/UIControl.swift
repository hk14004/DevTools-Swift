//
//  UIControl.swift
//  
//
//  Created by Hardijs Ķirsis on 09/09/2023.
//

import UIKit
import Combine
extension UIControl {
    public func eventPublisher(for event: UIControl.Event) -> UIControl.EventPublisher {
        EventPublisher(
            control: self,
            event: event
        )
    }
}
extension UIControl {
    public struct EventPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never
        
        private let control: UIControl
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        // swiftlint:disable indentation_width
        public func receive<S>(subscriber: S) where S: Subscriber,
                                                    S.Failure == Never,
                                                    S.Input == Void {
                                                        // swiftlint:enable indentation_width
                                                        let subscription = EventSubscription(
                                                            subscriber: subscriber,
                                                            control: control,
                                                            event: event
                                                        )
                                                        subscriber.receive(subscription: subscription)
                                                    }
    }
}
extension UIControl {
    final class EventSubscription<S: Subscriber>: Subscription where S.Input == Void {
        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event
        
        init(
            subscriber: S,
            control: UIControl,
            event: UIControl.Event
        ) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            self.control.addTarget(
                self,
                action: #selector(handleEvent),
                for: event
            )
        }
        
        @objc func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(())
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() { }
    }
}

