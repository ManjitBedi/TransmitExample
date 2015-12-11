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

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource("bb_minnie_the_moocher_512kb", ofType:"mp4") else {
            throw AppError.InvalidResource("bb_minnie_the_moocher_512kb", "mp4")
        }
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            player.play()
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
