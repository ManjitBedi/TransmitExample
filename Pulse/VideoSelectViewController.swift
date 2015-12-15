//
//  VideoSelectViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2015-12-10.
//  Copyright © 2015 No Org. All rights reserved.
//

import UIKit

class VideoSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var connectionManager = ConnectionManager.sharedManager
    var mediaInBundle : [NSString] = []
    var mediaInDocumentsFolder : [NSString] = []
    var bundleURLs : [NSURL] = []
    var documentURLS : [NSURL] = []

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMediaFilenames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMediaFilenames() {
        
        // in the app bundle
        let docsURL = NSBundle.mainBundle().resourceURL!
        let fileManager = NSFileManager.defaultManager()
        
        do {
            let directoryUrls = try  fileManager.contentsOfDirectoryAtURL(docsURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            mediaInBundle = directoryUrls.filter(){ $0.pathExtension! == "mp4" }.map{ $0.lastPathComponent! }

        } catch {
            print(error)
        }
    
        // in the documents folder
        let documentsUrl =  fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        do {
            let directoryUrls = try  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            mediaInDocumentsFolder = directoryUrls.filter(){ $0.pathExtension! == "mp4" || $0.pathExtension! == "mov"  }.map{ $0.lastPathComponent! }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    

    // MARK: - Table view data source
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return ["Bundled", "Documents"]
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Bundled"
        } else {
            return "Documents"
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return mediaInBundle.count
        } else {
            return mediaInDocumentsFolder.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FilenameCell", forIndexPath: indexPath)
    
        if(indexPath.section == 0 ) {
            cell.textLabel?.text = mediaInBundle[indexPath.row] as String
            cell.detailTextLabel?.text = ""
        } else {
            cell.textLabel?.text = mediaInDocumentsFolder[indexPath.row] as String
            cell.detailTextLabel?.text = ""
        }
    
        return cell
    }
}
