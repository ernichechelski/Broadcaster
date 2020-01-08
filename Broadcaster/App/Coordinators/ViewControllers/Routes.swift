//
//  Routes.swift
//  Transmitter
//
//  Created by Ernest Chechelski on 03/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

enum Storyboards {
    static let main = UIStoryboard(name: "Main", bundle: nil)
}

enum Routes {
    static let main = Storyboards.main.instantiateViewController(identifier: "Main") as! MainViewControllerRoutes
    static let info = Storyboards.main.instantiateViewController(identifier: "Info") as! InfoViewControllerRoutes
    static let documentView = Storyboards.main.instantiateViewController(identifier: "DocumentViewController") as! DocumentViewRoutes
    static let documentBrowser = Storyboards.main.instantiateViewController(identifier: "Browser") as! DocumentBrowserRoutes
    static let resourcesList = Storyboards.main.instantiateViewController(identifier: "resources") as! ResourcesTableViewControllerRoutes
    static let peersList = Storyboards.main.instantiateViewController(identifier: "peers") as! PeersTableViewControllerRoutes
}
