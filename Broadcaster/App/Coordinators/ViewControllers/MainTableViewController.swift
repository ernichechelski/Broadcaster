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
}

final class MainTableViewController: UITableViewController, MainViewControllerRoutes {

    var onShowLogsSelected: (() -> Void)?

    var onShowResourcesSelected: (() -> Void)?

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
            break
        case (0,1): // START
            session.start()
        case (0,2): // STOP
            session.stop()
        case (0,3): // Show logs
            onShowLogsSelected?()
        case (0,4): // Test transfer
            let image = UIImage(named: "test")!
            session.broadcast(image)
        case (0,5): // Say hello
            session.broadcast("Hello 👋")
        case (0,6): // Show resources
            onShowResourcesSelected?()
        default: break
        }
    }

    private func setStatus(text: String) {
        tableView.cellForRow(at: .init(item: 0, section: 0))?.textLabel?.text = "🕸 Status: \(text)"
    }
}
