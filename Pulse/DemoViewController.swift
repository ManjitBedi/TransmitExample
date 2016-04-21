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
import CoreMIDI
import AudioToolbox


class DemoViewController: UIViewController {

    weak var connectionManager: ConnectionManager?
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var videoFileNameLabel: UILabel!
    @IBOutlet weak var usingDataLabel: UILabel!
    @IBOutlet weak var thumbnailmageView: UIImageView!
    
    var player : AVPlayer = AVPlayer()
    var syncData : NSString = ""
    var syncArray : [NSString] = []
    var times : [NSValue] = []
    var videoPath : String?
    var vibrations: Bool = true
    var nf: NSNumberFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsChanged",
            name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let temp = defaults.stringForKey(PulseConstants.Preferences.mediaKeyPref) {
            videoPath = temp
        } else {
            let path = NSBundle.mainBundle().pathForResource(PulseConstants.Media.defaultVideoName, ofType:"mov")
            videoPath = path! as String
        }
        
        self.vibrations = defaults.boolForKey(PulseConstants.Preferences.vibrationsOnKeyPref) ?? true
        
        print("Load video with name \"\(videoPath)\"")
        let url = NSURL(fileURLWithPath: videoPath!)
        videoFileNameLabel.text = url.lastPathComponent
        
        let useMIDI = defaults.boolForKey(PulseConstants.Preferences.useMIDIKeyPref)
        if (useMIDI) {
            usingDataLabel.text = "Using MIDI data"
            readInSyncDataMIDI()
        } else {
            usingDataLabel.text = "Using txt data"
            readInSyncDataText()
        }
        
        
            
        connectionManager = ConnectionManager.sharedManager
        if let peers = connectionManager?.session.connectedPeers {
            connectionsLabel.text = "connections \(peers.count)"
        } else {
            connectionsLabel.text = "connections 0"
        }

        // Create a poster image from the video
        let fileURL = NSURL(fileURLWithPath: videoPath!)
        let asset = AVAsset(URL: fileURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(1, asset.duration.timescale)
        if let cgImage = try? assetImgGenerate.copyCGImageAtTime(time, actualTime: nil) {
            thumbnailmageView.image = UIImage(CGImage: cgImage)
        }
    }
    
    private func nameForDataFile(videoFileName:String, fileExtension:String) -> String {
        var path : String = ""
        let url = NSURL(fileURLWithPath: videoFileName)

        let ext = url.pathExtension
        
        // It is entirely possible the video file does not have an extension.
        
        if ((ext) != nil) {
            // split the path into components to get at the file name
            var components = url.pathComponents
            
            // the file name is the last time in array
            let position = (components?.count)! - 1
            let temp = components![position]
            
            // split the file name at the period character
            var fileNameSplit = temp.characters.split{$0 == "."}.map(String.init)
            fileNameSplit[1] = fileExtension
            
            // create a new file name
            components![position] = fileNameSplit[0]+fileNameSplit[1]

            // joins the path components back together
            let joinedString = components!.joinWithSeparator("/")
            // Ok but we need to trim the extra forward slash
            path = String(joinedString.characters.dropFirst())
            
        } else {
            path = videoFileName + fileExtension
        }
        
        return path
    }
    
    private func readInSyncDataText() {
        
        let path = self.nameForDataFile(videoPath!, fileExtension: ".txt")
        // read in the text file
        do {
            syncData = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            syncArray = syncData.componentsSeparatedByString("\n")
            
            let tempArray = NSMutableArray()
            
            // convert the strings to time and then encode the times as an NSValue to then add to an array of time values
            for timeString in syncArray {
                let cmTime = CMTimeMake(timeString.longLongValue, 10000)
                let cmValue = NSValue(CMTime: cmTime)
                tempArray.addObject(cmValue)
            }
            
            self.times = tempArray as NSArray as! [NSValue]
        }
        catch {
            print("could not open data file")
            let alertController = UIAlertController(title: "Error", message:
                "Could not open the data file.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    private func readInSyncDataMIDI() {
        var musicSequence:MusicSequence = nil
        let status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            print("\(__LINE__) bad status \(status) creating sequence")
        }
        
        let path = self.nameForDataFile(videoPath!, fileExtension: ".mid")
        let midiFileURL = NSURL(fileURLWithPath: path)
        
        // Load a MIDI file
        MusicSequenceFileLoad(musicSequence, midiFileURL, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
        
        var numberOfTracks: UInt32
        let iPointer: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.alloc(1)
        
        MusicSequenceGetTrackCount(musicSequence, iPointer)
        numberOfTracks = iPointer.memory
        iPointer.dealloc(1)
        
        // Not sure about this, there seems to be at least 2 tracks.
        // The first track is just a MIDI header.
        if numberOfTracks == 0 {
            print("WTF, the MIDI file is shit; there aren't any tracks")
        } else {
            let (trackLength, events) = self.getTrackInfo(musicSequence, trackNumber: 0)
            
            // We only want there to be one track in the sequence!
            if (trackLength == 0.0 && numberOfTracks > 1) {
                for i:UInt32 in 1 ..< numberOfTracks {
                    let (trackLength, events) = self.getTrackInfo(musicSequence, trackNumber: i)
                    
                    if (trackLength > 0.0) {
                        self.times = events
                        break;
                    }
                }
            } else if trackLength != 0.0 {
                self.times = events
            }
            
            if self.times.count == 0 {
                let alertController = UIAlertController(title: "Error", message:
                    "There are no timing events.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func getTrackInfo(musicSequence:MusicSequence, trackNumber:UInt32) -> (length: MusicTimeStamp, events:[NSValue]) {
        var track: MusicTrack = nil
        let trackPointer: UnsafeMutablePointer<MusicTrack> = UnsafeMutablePointer.alloc(1)
        var status = MusicSequenceGetIndTrack(musicSequence, trackNumber, trackPointer)
        var times:[NSValue] = []
        
        if status != OSStatus(noErr) {
            print("Error with opening the MIDI sequence \(status)")
            return (0.0, times)
        }
        
        track = trackPointer.memory
        trackPointer.dealloc(1)
        
        var trackLength = MusicTimeStamp(0)
        var tracklengthSize = UInt32(0)
        status = MusicTrackGetProperty(track,
            UInt32(kSequenceTrackProperty_TrackLength),
            &trackLength,
            &tracklengthSize)
        if status != OSStatus(noErr) {
            print("Error getting track length \(status)")
            return (0.0, times)
        }
        
        
        // No point in processing events if the track length is 0
        if (trackLength == 0) {
            return (0.0, times)
        }
        
        print("track length is \(trackLength) seconds for track \(trackNumber)")
        
        // Create an iterator that will loop through the events in the track
        var iterator : MusicEventIterator = nil
        NewMusicEventIterator(track, &iterator);
        
        if status != OSStatus(noErr) {
            print("Error creating track iterator \(status)")
            return (0.0, times)
        }

        
        var hasNext: DarwinBoolean = true
        var timestamp : MusicTimeStamp = 0
        var eventType : MusicEventType = 0
        var eventDataSize: UInt32 = 0
        let eventData: UnsafeMutablePointer<UnsafePointer<Void>> = UnsafeMutablePointer.alloc(1)
        
        status = MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
        
        // This would be strange if it happened.
        // It would mean the track has a duration but nothng in it...
        if status != OSStatus(noErr) {
            print("Error no event in the MIDI track\(status)")
            return (trackLength, times)
        }

        while (hasNext) {
            MusicEventIteratorGetEventInfo(iterator,
                &timestamp,
                &eventType,
                eventData,
                &eventDataSize);
            
            // TODO: check the event type is a marker
            let cmTime = CMTimeMakeWithSeconds( Float64(timestamp), 1000)
            let cmValue = NSValue(CMTime: cmTime)
            times.append(cmValue)
            
            MusicEventIteratorNextEvent(iterator);
            MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
        }
        
        return (trackLength, times)
    }

    
    // MARK: -
    private func playVideo(path: String) {
        
        guard let player:AVPlayer = AVPlayer(URL: NSURL(fileURLWithPath: path)) else  {
            let filePath:NSString = path as NSString
            let alertController = UIAlertController(title: "Error", message:
                "Could not open the video \"\(filePath.lastPathComponent)\".", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        
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
        nf = NSNumberFormatter()
        nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        
        player.addBoundaryTimeObserverForTimes(self.times, queue: dispatch_get_main_queue(), usingBlock: { [weak nf] in
                let timeInSeconds : Float64  =  CMTimeGetSeconds(player.currentTime())
            
                // as the number formatter is an optional; need to wrap the code like this to avoid
                // the debug saying "sync event at time Optional(7)" etc...
                if let timeString = nf!.stringFromNumber(timeInSeconds) {
                    print("sync event at time \(timeString)");
                }
            
                if self.vibrations {
                    dispatch_async(dispatch_get_main_queue()) {
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    }
                }
            
                self.connectionManager!.broadcastEvent()
            })
    }
    
    
    @IBAction func playTheVideo(sender: UIButton)  {
        playVideo(videoPath!)
    }
    
    // MARK: - 
    func defaultsChanged() {
        
        if (self.player.rate != 0) {
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let useMIDI = defaults.boolForKey(PulseConstants.Preferences.useMIDIKeyPref)
        if (useMIDI) {
            usingDataLabel.text = "Using MIDI data"
            readInSyncDataMIDI()
        } else {
            usingDataLabel.text = "Using txt data"
            readInSyncDataText()
        }
        
        self.vibrations = defaults.boolForKey(PulseConstants.Preferences.vibrationsOnKeyPref) ?? true
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let timeCodeVC = segue.destinationViewController as! TimeCodeTableViewController
        
        let timeStrings:[String] = times.map {
            let time =  $0.CMTimeValue
            return String(format: "%.02f", CMTimeGetSeconds(time))
        }

        timeCodeVC.syncArray = timeStrings
     }
}


enum AppError : ErrorType {
    case InvalidResource(String, String)
}
