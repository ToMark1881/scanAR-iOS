//
//  BasePresenter.swift
//
//
//  Created by macbook on 30.09.2020.
//

import Foundation
import UIKit

class BasePresenter {
    
    init() {
        Logger.shared.log("🆕 \(self)", type: .lifecycle)
    }
    
    deinit {
        Logger.shared.log("🗑 \(self)", type: .lifecycle)
    }
    
}
