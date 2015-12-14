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

class ConnectionManager: NSObject, MCBrowserViewControllerDelegate, MCSessionDelegate {
    static let sharedManager = ConnectionManager()
    
    let serviceType = "Pulse-Demo"
    
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    override init() {
        super.init()
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
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
    
    func showBrowser(viewController: UIViewController) {
        // Show the browser view controller
        viewController.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    
    // MARK: - delegate methods
    func browserViewControllerDidFinish( browserViewController: MCBrowserViewController)  {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
        
        // Check the number of connections
        if (self.session.connectedPeers.count > 0) {
            
        } else {
            
        }
    }
    
    func browserViewControllerWasCancelled( browserViewController: MCBrowserViewController)  {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, withProgress progress: NSProgress)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession, didReceiveData data: NSData,
        fromPeer peerID: MCPeerID)  {
            // This needs to run on the main queue
            dispatch_async(dispatch_get_main_queue()) {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
    }
    
    
    func session(session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession, peer peerID: MCPeerID,
        didChangeState state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }
}
