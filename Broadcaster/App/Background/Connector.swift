//
//  Connector.swift
//  Transmitter
//
//  Created by Ernest Chechelski on 30/12/2019.
//  Copyright © 2019 Ernest Chechelski. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import RxSwift
import RxRelay

struct Message: Codable {

    enum MessageType: String, Codable {
        case ownerStatus
        case log
        case message
        case location
        case data
        case resourceUrl
    }

    struct User: Codable {
        let name: String
        let ownedPeersIds: [String]
    }

    let timestamp: Date = Date()
    let text: String
    let user: User
    let type: MessageType
    let data: Data?
    let resourceUrl: URL?

    var cellText: String {
        "\(timestamp) \(user) \(type) \(text)"
    }
}

extension Message {

    static func system(text: String) -> Self {
        .init(text: text, user: User(name: "SYSTEM", ownedPeersIds: []), type: .log, data: nil, resourceUrl: nil)
    }

    static func message(_ text: String, user: User) -> Self {
        .init(text: text, user: user, type: .message, data: nil, resourceUrl: nil)
    }

    static func message(_ text: String, data: Data) -> Self {
        .init(text: text, user: User(name: "DATA", ownedPeersIds: []), type: .data, data: data, resourceUrl: nil)
    }

    static func resource(_ text: String, resouceUrl: URL) -> Self {
        .init(text: text, user: User(name: "DATA", ownedPeersIds: []), type: .resourceUrl, data: nil, resourceUrl: resouceUrl)
    }

    static func peersStatus(user: User) -> Self {
        .init(text: "PEERS", user: user, type: .ownerStatus, data: nil, resourceUrl: nil)
    }
}

protocol SessionFinder {
    func start()
    func stop()
    func broadcast(_ text: String)
    func broadcast(_ image: UIImage)
    func broadcast(_ resource: URL)
    var messages: BehaviorRelay<[Message]> { get }
    var resources: BehaviorRelay<Message> { get }
    var status: BehaviorRelay<SessionFinderStatus> { get }
    var connectedPeers: BehaviorRelay<[MCPeerID]> { get }
}

enum SessionFinderStatus {
    case started, stopped
}

final class DefaultSessionFinder: NSObject, SessionFinder{

    let isSessionConnected = BehaviorRelay(value: false)

    let messages = BehaviorRelay(value: [Message]())

    let resources = BehaviorRelay(value: Message.system(text: "Empty"))

    let status = BehaviorRelay(value: SessionFinderStatus.stopped)

    let connectedPeers = BehaviorRelay(value: [MCPeerID]())

    let discoveredPeers = BehaviorRelay(value: [MCPeerID]())

    let incomingMessageRouter = PublishSubject<Message?>()

    let outcomingMessageRouter = PublishSubject<Message?>()

    let discoveredPeerRouter = PublishSubject<MCPeerID>()

    let isCurrentPeerTheHost = BehaviorRelay(value: false)

    let serviceName = "OTRN"

    let currentPeer = MCPeerID(displayName: UIDevice.current.name)

    let dataCompressor = DataCompressor()

    lazy var session = MCSession(peer: currentPeer)

    lazy var browser = MCNearbyServiceBrowser(peer: currentPeer, serviceType: serviceName)

    lazy var advertiser = MCNearbyServiceAdvertiser(peer: currentPeer, discoveryInfo: [:], serviceType: serviceName)

    lazy var messageRouter = Observable.merge(incomingMessageRouter, outcomingMessageRouter)

    var currentUser: Message.User {
        Message.User(name: UIDevice.current.name, ownedPeersIds: session.connectedPeers.map { $0.displayName })
    }

    private let disposeBag = DisposeBag()

    override init() {
        print("\(#function)")
        super.init()
        browser.delegate = self
        session.delegate = self
        advertiser.delegate = self
        defineLogic()
        log("Ready")
    }

    func start() {
        print("\(#function)")
        browser.startBrowsingForPeers()
        advertiser.startAdvertisingPeer()
        status.accept(.started)
        log("Starting")
    }

    func stop() {
        print("\(#function)")
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
        session.disconnect()
        status.accept(.stopped)
        log("STOP")
    }

    private func log(_ text: String) {
        print("\(#function)", text)
        incomingMessageRouter.onNext(.system(text: text))
    }

    private func defineLogic() {
        outcomingMessageRouter.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] incomingMessage in
            guard
                let self = self,
                let message = incomingMessage
            else {
                return
            }

            self.broadcast(message)
        }).disposed(by: disposeBag)

        messageRouter.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] incomingMessage in
            guard
                let self = self,
                let message = incomingMessage
            else {
                return
            }
            self.messages.append(message)
        }).disposed(by: disposeBag)

        discoveredPeerRouter.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] peer in
            self?.discoveredPeers.append(peer)
        }).disposed(by: disposeBag)

        discoveredPeers.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] peers in
            guard let self = self else { return }
            peers.filter {
                !self.session.connectedPeers.contains($0)
            }.forEach {
                self.invitePeer($0)
            }
        }).disposed(by: disposeBag)

        connectedPeers.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] peers in
            guard let self = self else { return }
            self.broadcast(.peersStatus(user: self.currentUser))
        }).disposed(by: disposeBag)
    }

    private func invitePeer(_ peerID: MCPeerID) {
        print("\(#function)", peerID)
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
}


extension DefaultSessionFinder {

    func broadcast(_ data: Data) {
        print("\(#function)")
        guard !session.connectedPeers.isEmpty else { return }
        let compressedData = dataCompressor.compressData(data, with: .lz4)
        try? session.send(compressedData, toPeers: session.connectedPeers, with: .reliable)
    }

    func broadcast(_ resource: URL) {

        print("\(#function)")
        session.connectedPeers.forEach { (peerID) in
            messages.append(.system(text: "Broadcasting to peer: \(peerID.displayName)"))
            session.sendResource(at: resource, withName:resource.lastPathComponent , toPeer: peerID, withCompletionHandler: nil)
        }
    }

    func broadcast(_ message: Message) {
        print("\(#function)")
        broadcast(try! JSONEncoder().encode(message))
    }

    func broadcast(_ text: String) {
        print("\(#function)", text)
        broadcast(.message(text, user: currentUser))
    }

    func broadcast(_ image: UIImage) {
        print("\(#function)")
        guard let data = image.pngData() else { return }
        outcomingMessageRouter.onNext(.message("image", data: data))
        broadcast(data)
    }

    func receive(_ data: Data) -> Message? {
        let uncompressedData = dataCompressor.decompressData(data, with: .lz4)
        return try? JSONDecoder().decode(Message.self, from: uncompressedData)
    }
}



extension DefaultSessionFinder: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("\(#function)", peerID)
        discoveredPeerRouter.onNext(peerID)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("\(#function)", peerID)
    }
}

extension DefaultSessionFinder: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(#function)", peerID, state)
        switch state {
        case .notConnected:
            connectedPeers.accept(connectedPeers.value.filter({
                !$0.displayName.elementsEqual(peerID.displayName)
            }))
            if connectedPeers.value.isEmpty {
                isSessionConnected.accept(false)
            }
        case .connecting: break
        case .connected:
            connectedPeers.append(peerID)
            isSessionConnected.accept(true)
        @unknown default: break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        incomingMessageRouter.onNext(receive(data))
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("\(#function)", streamName, peerID)
        // TODO: Implement me
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("\(#function)", resourceName, peerID)
        messages.append(.system(text: "Start receiving resource: \(resourceName) : \(progress.fractionCompleted)"))
         // TODO: Implement me
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("\(#function)", resourceName, peerID, error)
        messages.append(.system(text: "Completed receiving resource: \(resourceName) : \(localURL?.absoluteString)"))
        guard let url = localURL else { return }
        // Create a FileManager instance

        let destinationUrl = getDocumentsDirectory().appendingPathComponent(resourceName)

        do {
            try FileManager.default.copyItem(at: url, to: destinationUrl)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        messages.append(.resource("Resource received", resouceUrl: destinationUrl))
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension DefaultSessionFinder: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard !isCurrentPeerTheHost.value else { return }
        isSessionConnected.accept(true)
        invitationHandler(true, session)
    }
}

extension BehaviorRelay where Element: RangeReplaceableCollection {

    func append(_ element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }
}
