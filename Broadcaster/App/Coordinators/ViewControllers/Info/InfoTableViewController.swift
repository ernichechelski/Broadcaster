//
//  InfoTableViewController.swift
//  Transmitter
//
//  Created by Ernest Chechelski on 03/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit
import RxSwift

protocol InfoViewControllerRoutes: ViewControllerRoutes {
    var session: SessionFinder! { get set }
}

final class InfoTableViewController: UITableViewController, InfoViewControllerRoutes {

    var session: SessionFinder!

    var disposeBag: DisposeBag! = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = .init()
    }

    override func viewWillAppear(_ animated: Bool) {
        session.messages
            .observeOn(MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        session.messages
            .observeOn(MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.beginUpdates()
                let indexPath = IndexPath.init(row: self.session.messages.value.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        return session.messages.value.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = session.messages.value[indexPath.row]
        switch message.type {
        case .resourceUrl:
            guard let url = message.resourceUrl else { return }
            present(UIActivityViewController(activityItems: [url] , applicationActivities: nil), animated: true)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = session.messages.value[indexPath.row]
        switch message.type {
        case .resourceUrl:
             let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
             let message = session.messages.value[indexPath.row]
             cell.textLabel?.text = message.resourceUrl?.absoluteString
             return cell
        default:
            break
        }

        if let data = message.data, let image = UIImage(data: data) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! InfoImageTableViewCell
            cell.titleTextLabel?.text = message.cellText
            cell.messageImageView?.image = image
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
            let message = session.messages.value[indexPath.row]
            cell.textLabel?.text = message.cellText
            return cell
        }
    }
}
