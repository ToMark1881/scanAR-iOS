//
//  BaseInteractor.swift
//  
//
//  Created by macbook on 02.06.2021.
//

import Foundation

class BaseInteractor {
    
    init() {
        Logger.shared.log("🆕 \(self)", type: .lifecycle)
    }
    
    deinit {
        Logger.shared.log("🗑 \(self)", type: .lifecycle)
    }
    
}
