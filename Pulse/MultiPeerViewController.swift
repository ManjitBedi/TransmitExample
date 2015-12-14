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

class MultiPeerViewController: UIViewController {
        
    
    @IBOutlet weak var sendNudgetButton: UIButton!
    weak var connecitonManager = ConnectionManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showBrowser(sender: UIButton) {
        // Show the browser view controller
        self.connecitonManager?.showBrowser(self)
    }
        
    @IBAction func sendNudge() {
        let session = self.connecitonManager?.session
        
        guard let peers: [MCPeerID]? = session?.connectedPeers else { return }
            
        let command = "nudge"
        let data : NSData = command.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            
        do {
            try session?.sendData(data, toPeers: peers!, withMode: .Reliable)
        } catch _ {
            print("session error")
        }
    }
}
