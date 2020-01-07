//
//  DocumentViewController.swift
//  Broadcaster
//
//  Created by Ernest Chechelski on 07/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

protocol DocumentViewRoutes: ViewControllerRoutes {
    var document: UIDocument? { get set }
    var session: SessionFinder! { get set }
}

class DocumentViewController: UIViewController, DocumentViewRoutes {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: UIDocument?

    var session: SessionFinder!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        document?.open(completionHandler: { (success) in
            if success {
                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
            }
        })
    }
    
    @IBAction func broadcastFileButtonTapped(_ sender: UIButton) {
        guard let url = document?.fileURL else { return }
        session.broadcast(url)
    }

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
