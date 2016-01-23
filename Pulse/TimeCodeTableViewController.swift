//
//  TimeCodeTableViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2015-12-15.
//  Copyright © 2015 No Org. All rights reserved.
//

import UIKit

class TimeCodeTableViewController: UITableViewController {

    var syncData : NSString = ""
    var syncArray : [NSString] = []
    var videoPath : String = "'"

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let temp = defaults.stringForKey(PulseConstants.Preferences.mediaKeyPref) {
            videoPath = temp as String
        } else {
            let path = NSBundle.mainBundle().pathForResource(PulseConstants.Media.defaultVideoName, ofType:"mp4")
            videoPath = path! as String
        }

        var path : String = ""
        if (videoPath.rangeOfString(".mp4") != nil) {
            path = videoPath.stringByReplacingOccurrencesOfString(".mp4", withString:".txt")
        } else if ( videoPath.rangeOfString(".m4v") != nil) {
            path = videoPath.stringByReplacingOccurrencesOfString(".m4v", withString:".txt")
        }
        
        // read in the text file
        do {
            syncData = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            syncArray = syncData.componentsSeparatedByString("\n")
            self.tableView.reloadData()
        }
        catch {/* error handling here */}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return syncArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeCodeCell", forIndexPath: indexPath)

        cell.textLabel!.text = syncArray[indexPath.row] as String

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
