//
//  DocumentBrowserViewController.swift
//  Broadcaster
//
//  Created by Ernest Chechelski on 07/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

protocol DocumentBrowserRoutes: ViewControllerRoutes {
    var onFileSelected: ((Document) -> Void)? { get set }
    var onReceiveSelected: (() -> Void)? { get set }
}

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate, DocumentBrowserRoutes {

    var onFileSelected: ((Document) -> Void)?

    var onReceiveSelected: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        allowsPickingMultipleItems = false

        let newBtn = UIBarButtonItem(title: "Receive", style: .plain, target: self, action: #selector(receiveTapped))
        self.additionalLeadingNavigationBarButtonItems = [newBtn]
    }

    @objc func receiveTapped() {
        onReceiveSelected?()
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {}

    func presentDocument(at documentURL: URL) {
        onFileSelected?(Document(fileURL: documentURL))
    }
}

