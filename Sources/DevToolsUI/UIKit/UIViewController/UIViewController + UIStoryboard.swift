//
//  UIViewController + UIStoryboard.swift
//  
//
//  Created by Hardijs Ķirsis on 11/06/2023.
//

import UIKit

public extension UIViewController {
    static func instantiateViewController<T: UIViewController>(creator: ((NSCoder) -> T)?) -> T! {
        return UIStoryboard.instantiateViewController(type: T.self, creator: creator)!
    }
    
    static func instantiateViewController() -> Self! {
        return UIStoryboard.instantiateViewController(type: Self.self)!
    }
}

fileprivate class ExampleVC: UIViewController {
    
    let injeted: Int
    
    required init?(coder: NSCoder) {
        injeted = 0
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder, injected: Int) {
        self.injeted = injected
        super.init(coder: coder)
    }
}

fileprivate func example() {
    let vc = ExampleVC.instantiateViewController { coder in
        ExampleVC(coder: coder, injected: 999)!
    }!
    print(vc)
}


