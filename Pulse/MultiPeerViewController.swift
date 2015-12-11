//
//  MultiPeerViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2015-12-10.
//  Copyright © 2015 No Org. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AudioToolbox

class MultiPeerViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
        
        let serviceType = "Pulse-Demo"
        
        var browser : MCBrowserViewController!
        var assistant : MCAdvertiserAssistant!
        var session : MCSession!
        var peerID: MCPeerID!
        
        @IBOutlet weak var sendNudgetButton: UIButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
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
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        
        @IBAction func showBrowser(sender: UIButton) {
            // Show the browser view controller
            self.presentViewController(self.browser, animated: true, completion: nil)
        }
        
        @IBAction func sendNudge() {
            
            guard let peers: [MCPeerID]? = self.session?.connectedPeers else { return }
            
            let command = "nudge"
            let data : NSData = command.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            
            
            do {
                try session?.sendData(data, toPeers: peers!, withMode: .Reliable)
            } catch _ {
            }
        }
        
        
        func browserViewControllerDidFinish( browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            // Check the number of connections
            if (self.session.connectedPeers.count > 0) {
                self.sendNudgetButton.enabled = true;
            } else {
                self.sendNudgetButton.enabled = false;
            }
            
        }
        
        func browserViewControllerWasCancelled( browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
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
