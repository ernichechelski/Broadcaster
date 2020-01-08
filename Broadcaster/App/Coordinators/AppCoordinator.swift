//
//  AppCoordinator.swift
//  Transmitter
//
//  Created by Ernest Chechelski on 30/12/2019.
//  Copyright © 2019 Ernest Chechelski. All rights reserved.
//

import Foundation
import UIKit

final class AppCoordinator {

    private lazy var rootRoutes: DocumentBrowserRoutes = {
        var routes = Routes.documentBrowser

        routes.onReceiveSelected = { [weak self] in
            guard let self = self else { return }
            self.navigationController.viewControllers = [self.main.viewController]
            routes.viewController.present(self.navigationController, animated: true)
        }

        routes.onFileSelected = { [weak self] document in
            guard let self = self else { return }
            self.documentView.document = document
            self.rootRoutes.viewController.present(self.documentView.viewController, animated: true)
        }

        return routes
    }()

    private lazy var main: MainViewControllerRoutes = {
        var routes = Routes.main
        routes.session = session

        routes.onShowLogsSelected = { [weak self] in
            self?.showLogsScene()
        }

        routes.onShowResourcesSelected = { [weak self] in
            self?.showResourcesScene()
        }

        routes.onShowPeersSelected = { [weak self] in
            self?.showPeersScene()
        }

        return routes
    }()

    private lazy var info: InfoViewControllerRoutes = {
        var routes = Routes.info
        routes.session = session
        return routes
    }()

    private lazy var documentView: DocumentViewRoutes = {
        var routes = Routes.documentView
        routes.session = session
        return routes
    }()

    private lazy var resourcesView: ResourcesTableViewControllerRoutes = {
        var routes = Routes.resourcesList
        routes.session = session
        return routes
    }()

    private lazy var peersList: PeersTableViewControllerRoutes = {
        var routes = Routes.peersList
        routes.session = session
        return routes
    }()

    private let session: SessionFinder = DefaultSessionFinder()

    private let navigationController = UINavigationController()

    private let window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        showDocumentsBrowser()
    }

    func showDocumentsBrowser() {
        window!.rootViewController = rootRoutes.viewController
        window!.makeKeyAndVisible()
    }

    func showMain() {
        navigationController.show(main.viewController, sender: nil)
    }

    func showLogsScene() {
        navigationController.show(info.viewController, sender: nil)
    }

    func showResourcesScene() {
        navigationController.show(resourcesView.viewController, sender: nil)
    }

    func showPeersScene() {
        navigationController.show(peersList.viewController, sender: nil)
    }
}
