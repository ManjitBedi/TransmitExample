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

class MultiPeerViewController: UIViewController, ConnectionManagerDelegate {
        
    
    @IBOutlet weak var sendNudgeButton: UIButton!
    weak var connectionManager = ConnectionManager.sharedManager
    
    @IBOutlet weak var peersTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectionManager!.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showBrowser(sender: UIButton) {
        // Show the browser view controller
        self.connectionManager?.showBrowser(self)
    }
        
    @IBAction func sendNudge() {
        self.connectionManager!.broadcastEvent()
    }
    
    // MARK: delegate methods
    func connected(connectionManager: ConnectionManager) {
        if let session = self.connectionManager?.session {
            self.sendNudgeButton?.enabled = true
            self.peersTextView.text = session.connectedPeers.description
        } else {
            self.sendNudgeButton?.enabled = false
            self.peersTextView.text = ""
        }
    }
}
