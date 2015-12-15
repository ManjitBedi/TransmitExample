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
import CoreMedia

class DemoViewController: UIViewController {

    weak var connectionManager: ConnectionManager?
    @IBOutlet weak var connectionsLabel: UILabel!
    let defaultMovieName = "bb_minnie_the_moocher_512kb"
    var player : AVPlayer = AVPlayer()
    var syncData : NSString = ""
    var syncArray : [NSString] = []
    var times : [NSValue] = []
    
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
            
            let tempArray = NSMutableArray()
            
            // convert the strings to time and then encode the times as an NSValue to then add
            // to an array of time values
            for timeString in syncArray {
                let time = timeString.longLongValue
                let cmTime  = CMTimeMake(time, 1)
                let cmValue = NSValue(CMTime: cmTime)
                tempArray.addObject(cmValue)
            }
            
            self.times = tempArray as NSArray as! [NSValue]
            
        }
        catch {/* error handling here */}
    }
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource(defaultMovieName, ofType:"mp4") else {
            throw AppError.InvalidResource(defaultMovieName, "mp4")
        }
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        // Create time sychronized events
        createSyncEvents(player)
        
        self.presentViewController(playerController, animated: true) {
            self.player.play()
        }
    }
    
    private func createSyncEvents(player: AVPlayer) {
        player.addBoundaryTimeObserverForTimes(self.times, queue: dispatch_get_main_queue(), usingBlock: {
                print("sync event");
                self.connectionManager!.broadcastEvent()
            })
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
