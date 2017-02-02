//
//  ConnectionManager.swift
//  Pulse
//
//  Created by Manjit Bedi on 2015-12-14.
//  Copyright © 2015 No Org. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AudioToolbox

protocol ConnectionManagerDelegate {
    func connected(_ connectionManager: ConnectionManager)
}

class ConnectionManager: NSObject, MCBrowserViewControllerDelegate, MCSessionDelegate {
    static let sharedManager = ConnectionManager()
    
    let serviceType = "Pulse-Demo"
    var delegate : ConnectionManagerDelegate?
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    override init() {
        super.init()
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType:serviceType,
            session:self.session)
        
        self.browser.delegate = self;
        
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType,
            discoveryInfo:nil, session:self.session)
        
        // tell the assistant to start advertising our fabulous chat
        self.assistant.start()
    }
    
    func showBrowser(_ viewController: UIViewController) {
        // Show the browser view controller
        viewController.present(self.browser, animated: true, completion: nil)
    }
    
    func broadcastEvent () {
        guard let peers: [MCPeerID]? = session?.connectedPeers else { return }
        
        let command = "nudge"
        let data : Data = command.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        do {
            try session?.send(data, toPeers: peers!, with: .reliable)
        } catch _ {
            print("session error")
        }
    }
    
    // MARK: - delegate methods
    func browserViewControllerDidFinish( _ browserViewController: MCBrowserViewController)  {
        browserViewController.dismiss(animated: true, completion: nil)
        
        // Check the number of connections
        if (self.session.connectedPeers.count > 0) {
            delegate?.connected(self)
        } else {
            print("no peers connected?")
        }
    }
    
    func browserViewControllerWasCancelled( _ browserViewController: MCBrowserViewController)  {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)  {
            // This needs to run on the main queue
            DispatchQueue.main.async {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
    }
    
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
    }
}
