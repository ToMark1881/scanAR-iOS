//
//  BaseRouter.swift
//  
//
//  Created by macbook on 22.03.2021.
//

import Foundation

typealias EmptyCompletionBlock = (() -> Void)?

class BaseRouter {
    
    init() {        
        Logger.shared.log("🆕 \(self)", type: .lifecycle)
    }
    
    deinit {
        Logger.shared.log("🗑 \(self)", type: .lifecycle)
    }
    
}
