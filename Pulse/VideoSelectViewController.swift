//
//  VideoSelectViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2015-12-10.
//  Copyright © 2015 No Org. All rights reserved.
//
//
//  Given the videos in the app bundle and the videos in the documents folder
//  Display them in a table view.
//  
//  Allow the user to choice a viedo and remember the choice
//

import UIKit
import AVFoundation

class VideoSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var selectedMediaLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    weak var connectionManager = ConnectionManager.sharedManager
    var mediaInBundle: [NSString] = []
    var mediaInDocumentsFolder: [NSString] = []
    var bundleURLs: [URL] = []
    var documentURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let temp : String = defaults.string(forKey: PulseConstants.Preferences.mediaKeyPref) {
            let url : URL =  URL(fileURLWithPath: temp)
            selectedMediaLabel.text = url.lastPathComponent
        } else {
            // the user has not selected a video previously, use the default video
            selectedMediaLabel.text = PulseConstants.Media.defaultVideoName + ".mov"
        }
        
        getMediaFilenames()
    }
    
    func getMediaFilenames() {
        
        // in the app bundle
        let docsURL = Bundle.main.resourceURL!
        let fileManager = FileManager.default
        
        do {
            let directoryUrls = try  fileManager.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
            
            // Apply a filter to the list of files
            bundleURLs = directoryUrls.filter(){ $0.pathExtension == "mp4" || $0.pathExtension == "mov" }

            // And remove the paths from the URLs for display purposes
            mediaInBundle = bundleURLs.map{ $0.lastPathComponent }
        } catch let error as NSError  {
            print(error.localizedDescription)
        }
    
        // in the documents folder
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryUrls = try  FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
            
            documentURLs = directoryUrls.filter(){ $0.pathExtension == "mp4" || $0.pathExtension == "mov" }
            mediaInDocumentsFolder = documentURLs.map{ $0.lastPathComponent }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Bundled"
        } else {
            return "Documents"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return mediaInBundle.count
        } else {
            return mediaInDocumentsFolder.count
        }
    }
    
    
    func getMovieMetaData(_ url: URL)-> String {
        let asset = AVURLAsset(url: url)
        //let commonMetaData = asset.commonMetadata
        let durationInSeconds = Int(CMTimeGetSeconds(asset.duration))
        let data:String = ("\(durationInSeconds/60) minutes \(durationInSeconds%60) seconds")
        
        return data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilenameCell", for: indexPath)
    
        if (indexPath.section == 0 ) {
            cell.textLabel?.text = mediaInBundle[indexPath.row] as String
            cell.detailTextLabel?.text = getMovieMetaData(bundleURLs[indexPath.row])
        } else {
            cell.textLabel?.text = mediaInDocumentsFolder[indexPath.row] as String
            cell.detailTextLabel?.text = getMovieMetaData(documentURLs[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the URL for the selected video & save it.
        var mediaURL : URL
        if (indexPath.section == 0) {
            mediaURL  = bundleURLs[indexPath.row] as URL
            selectedMediaLabel.text = mediaInBundle[indexPath.row] as String
        } else {
            mediaURL  = documentURLs[indexPath.row] as URL
            selectedMediaLabel.text = mediaInDocumentsFolder[indexPath.row] as String
        }
        
        //print("url \(mediaURL)")
        
        let defaults = UserDefaults.standard
        defaults.set(mediaURL.path, forKey: PulseConstants.Preferences.mediaKeyPref)
    }
}
