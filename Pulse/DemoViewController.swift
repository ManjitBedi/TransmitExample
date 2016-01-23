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
        
        let useMIDI = defaults.boolForKey(PulseConstants.Preferences.useMIDIKeyPref)
        if(useMIDI) {
            readInSyncDataMIDI()
        } else {
            readInSyncDataText()
        }
            
        connectionManager = ConnectionManager.sharedManager
        if let peers = connectionManager?.session.connectedPeers {
            connectionsLabel.text = "connections \(peers.count)"
        } else {
            connectionsLabel.text = "connections 0"
        }
    }
    
    private func readInSyncDataText() {
        
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
            let alertController = UIAlertController(title: "Error", message:
                "Could not open a text file for the video file.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    private func readInSyncDataMIDI() {
        var musicSequence:MusicSequence = MusicSequence()
        let status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            print("\(__LINE__) bad status \(status) creating sequence")
        }
        
        var path : String = ""
        
        if (videoPath.rangeOfString(".mp4") != nil) {
            path = videoPath.stringByReplacingOccurrencesOfString(".mp4", withString:".mid")
        } else if ( videoPath.rangeOfString(".m4v") != nil) {
            path = videoPath.stringByReplacingOccurrencesOfString(".m4v", withString:".mid")
        }
        
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
            var trackLength:MusicTimeStamp = self.getTrackInfo(musicSequence, trackNumber: 0)
            
            // We only want there to be one track in the sequence!
            if (trackLength == 0.0 && numberOfTracks > 1) {
                for var i:UInt32 = 1; i < numberOfTracks; i++ {
                    trackLength = self.getTrackInfo(musicSequence, trackNumber: i)
                    
                    if(trackLength > 0.0) {
                        break;
                    }
                }
            }
        }
    }
    
    
    // TODO refactor
    func getTrackInfo(musicSequence:MusicSequence, trackNumber:UInt32) -> MusicTimeStamp {
        var track : MusicTrack = MusicTrack()
        let trackPointer: UnsafeMutablePointer<MusicTrack> = UnsafeMutablePointer.alloc(1)
        MusicSequenceGetIndTrack(musicSequence, trackNumber, trackPointer)
        track = trackPointer.memory
        trackPointer.dealloc(1)
        
        var trackLength = MusicTimeStamp(0)
        var tracklengthSize = UInt32(0)
        let status = MusicTrackGetProperty(track,
            UInt32(kSequenceTrackProperty_TrackLength),
            &trackLength,
            &tracklengthSize)
        if status != OSStatus(noErr) {
            print("Error getting track length \(status)")
            return 0.0
        }
        
        print("track length is \(trackLength) seconds for track \(trackNumber)")
        
        
        // Create an iterator that will loop through the events in the track
        var iterator : MusicEventIterator = MusicEventIterator()
        NewMusicEventIterator(track, &iterator);
        
        var hasNext: DarwinBoolean = true
        var timestamp : MusicTimeStamp = 0
        var eventType : MusicEventType = 0
        var eventDataSize: UInt32 = 0
        let eventData: UnsafeMutablePointer<UnsafePointer<Void>> = UnsafeMutablePointer.alloc(1)
        
        let tempArray = NSMutableArray()

        MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
        while (hasNext) {
            MusicEventIteratorGetEventInfo(iterator,
                &timestamp,
                &eventType,
                eventData,
                &eventDataSize);
            
            let cmTime = CMTimeMakeWithSeconds( Float64(timestamp), 10)
            let cmValue = NSValue(CMTime: cmTime)
            tempArray.addObject(cmValue)
            MusicEventIteratorNextEvent(iterator);
            MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
        }
        self.times = tempArray as NSArray as! [NSValue]
        
        return trackLength
    }

    
    // MARK
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
                let timeInSeconds : Float64  =  CMTimeGetSeconds(player.currentTime())
                print("sync event at time \(timeInSeconds)");
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
