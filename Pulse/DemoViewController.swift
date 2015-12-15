//
//  DemoViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2015-12-10.
//  Copyright © 2015 No Org. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DemoViewController: UIViewController {

    weak var connectionManager: ConnectionManager?
    @IBOutlet weak var connectionsLabel: UILabel!
    let defaultMovieName = "bb_minnie_the_moocher_512kb"
    var syncData : NSString = ""
    var syncArray : [NSString] = []
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        readInSyncData()
        
        connectionManager = ConnectionManager.sharedManager
        if let peers = connectionManager?.session.connectedPeers {
            connectionsLabel.text = "connections \(peers.count)"
        } else {
            connectionsLabel.text = "connections 0"
        }
    }
    
    private func readInSyncData() {
        let path = NSBundle.mainBundle().pathForResource(defaultMovieName, ofType:"txt")
        
        // read in the text file
        do {
            syncData = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            syncArray = syncData.componentsSeparatedByString("\n")
        }
        catch {/* error handling here */}
    }
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource(defaultMovieName, ofType:"mp4") else {
            throw AppError.InvalidResource(defaultMovieName, "mp4")
        }
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        // Create time sychronized events
        createSyncEvents()
        
        self.presentViewController(playerController, animated: true) {
            player.play()
        }
    }
    
    private func createSyncEvents() {
        for time in syncArray {
            print ("time \(time)")
        }
    }
    
    
    @IBAction func showBrowser(sender: UIButton)  {
        do {
            try playVideo()
        } catch AppError.InvalidResource(let name, let type) {
            debugPrint("Could not find resource \(name).\(type)")
        } catch {
            debugPrint("Generic error")
        }
    }
}



enum AppError : ErrorType {
    case InvalidResource(String, String)
}
