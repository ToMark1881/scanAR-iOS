//
//  BaseViewController.swift
//  
//
//  Created by macbook on 09.10.2020.
//

import Foundation
import UIKit

protocol BaseViewControllerProtocol where Self: UIViewController {
    
    var navigationController: UINavigationController? { get }
    
}
