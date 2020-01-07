//
//  ResourcesTableViewController.swift
//  Broadcaster
//
//  Created by Ernest Chechelski on 07/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

import UIKit
import RxSwift

protocol ResourcesTableViewControllerRoutes: ViewControllerRoutes {
    var session: SessionFinder! { get set }
}

final class ResourcesTableViewController: UITableViewController, ResourcesTableViewControllerRoutes {

    var session: SessionFinder!

    var disposeBag: DisposeBag! = DisposeBag()

    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = .init()
    }

    override func viewWillAppear(_ animated: Bool) {
        session.messages
            .map({ $0.filter { $0.type == .resourceUrl }})
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.messages = $0
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = nil
        disposeBag = DisposeBag()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = message.resourceUrl?.absoluteString ?? "N/A"
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let url = message.resourceUrl else { return }
        present(UIActivityViewController(activityItems: [url] , applicationActivities: nil), animated: true)
    }
}
