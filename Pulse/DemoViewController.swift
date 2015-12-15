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
    var player : AVPlayer = AVPlayer()
    var syncData : NSString = ""
    var syncArray : [NSString] = []
    var times : [NSValue] = []
    var urlString : NSString = ""
    var videoPath : String = ""
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let temp = defaults.stringForKey(PulseConstants.Preferences.mediaKeyPref) {
            urlString = temp
            videoPath = urlString as String
            print(urlString)
        } else {
            let path = NSBundle.mainBundle().pathForResource(PulseConstants.Media.defaultVideoName, ofType:"mp4")
            videoPath = path! as String
        }
        
        readInSyncData()
        
        connectionManager = ConnectionManager.sharedManager
        if let peers = connectionManager?.session.connectedPeers {
            connectionsLabel.text = "connections \(peers.count)"
        } else {
            connectionsLabel.text = "connections 0"
        }
    }
    
    private func readInSyncData() {
        
        let path : String = videoPath.stringByReplacingOccurrencesOfString(".mp4", withString:".txt")
        
        //let path = NSBundle.mainBundle().pathForResource(PulseConstants.Media.defaultVideoName, ofType:"txt")
        
        // read in the text file
        do {
            syncData = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            syncArray = syncData.componentsSeparatedByString("\n")
            
            let tempArray = NSMutableArray()
            
            // convert the strings to time and then encode the times as an NSValue to then add to an array of time values
            for timeString in syncArray {
                let cmTime = CMTimeMake(timeString.longLongValue, 1000)
                let cmValue = NSValue(CMTime: cmTime)
                tempArray.addObject(cmValue)
            }
            
            self.times = tempArray as NSArray as! [NSValue]
            
        }
        catch {
            print("could not open text file")
        }
    }
    
    private func playVideo(path: String) {
        
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        // Create time sychronized events
        if (self.times.count > 0) {
            createSyncEvents(player)
        }
        
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
        playVideo(videoPath)
    }
}



enum AppError : ErrorType {
    case InvalidResource(String, String)
}
