//
//  PeersList.swift
//  Broadcaster
//
//  Created by Ernest Chechelski on 08/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit
import RxSwift
import MultipeerConnectivity

protocol PeersTableViewControllerRoutes: ViewControllerRoutes {
    var session: SessionFinder! { get set }
}

final class PeersTableViewController: UITableViewController, PeersTableViewControllerRoutes {

    var session: SessionFinder!

    var disposeBag: DisposeBag! = DisposeBag()

    var peers = [MCPeerID]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = .init()
    }

    override func viewWillAppear(_ animated: Bool) {
        session.connectedPeers
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.peers = $0
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
        return peers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let peer = peers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = peer.displayName
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
