//
//  ViewControllerRoutes.swift
//  Transmitter
//
//  Created by Ernest Chechelski on 03/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

protocol ViewControllerRoutes {
    var viewController: UIViewController { get }
}

extension ViewControllerRoutes where Self: UIViewController {
    var viewController: UIViewController { self }
}


