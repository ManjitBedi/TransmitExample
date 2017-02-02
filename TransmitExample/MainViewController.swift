//
//  ViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2015-12-10.
//  Copyright © 2015 No Org. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func handleTakeMeButtonPressed(_ sender: AnyObject) {
        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(settingsUrl!)
    }
    

    @IBAction func startDemo(_ sender: AnyObject) {
    }

    @IBAction func selectVideo(_ sender: AnyObject) {
    }
    
    @IBAction func connectivity(_ sender: AnyObject) {
    }
}

