//
//  MainTableViewController.swift
//  Transmitter
//
//  Created by Ernest Chechelski on 03/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit
import RxSwift

protocol MainViewControllerRoutes: ViewControllerRoutes {
    var session: SessionFinder! { get set }
    var onShowLogsSelected: (() -> Void)? { get set }
    var onShowResourcesSelected: (() -> Void)? { get set }
    var onShowPeersSelected: (() -> Void)? { get set }
}

final class MainTableViewController: UITableViewController, MainViewControllerRoutes {

    var onShowLogsSelected: (() -> Void)?

    var onShowResourcesSelected: (() -> Void)?

    var onShowPeersSelected: (() -> Void)?

    var session: SessionFinder!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        session.status
            .subscribe(onNext: { [weak self] status in
                switch status {
                case .started:
                    self?.setStatus(text: "Started")
                case .stopped:
                    self?.setStatus(text: "Stopped")
                }
            })
            .disposed(by: disposeBag)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0): // Status
            tableView.cellForRow(at: indexPath)?.isSelected = false
            break
        case (0,1): // START
            session.start()
        case (0,2): // STOP
            session.stop()
        case (0,3): // Received resources
            onShowResourcesSelected?()
        case (0,4): // Logs
            onShowLogsSelected?()
        case (0,5): // Chat
            session.broadcast("Hello 👋")
        case (0,6): // Peers
            onShowPeersSelected?()
        case (0,7): // Broadcast test image
            let image = UIImage(named: "test")!
            session.broadcast(image)
        case (0,8): //Say hello
            session.broadcast("Hello 👋")
        default: break
        }
    }

    private func setStatus(text: String) {
        tableView.cellForRow(at: .init(item: 0, section: 0))?.textLabel?.text = "🕸 Status: \(text)"
    }
}
