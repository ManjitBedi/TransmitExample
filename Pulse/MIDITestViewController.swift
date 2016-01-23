//
//  MIDiTestViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2016-01-21.
//  Copyright © 2016 No Org. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMIDI
import AudioToolbox

class MIDITestViewController: UIViewController {

    var midiPlayer: AVMIDIPlayer!
    var fileName: String!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileName = "video"
        
        self.LoadMusicSequence()
    }
    
    @IBAction func playSomeMIDI(sender: AnyObject) {
//        self.midiPlayer.play { () -> Void in
//            print("MIDI finished")
//        }
    }

//    func createAVMIDIPlayerFromMIDIFIleDLS() {
//        guard let midiFileURL = NSBundle.mainBundle().URLForResource(fileName, withExtension: "mid") else {
//            fatalError("'\(fileName)' file not found.")
//        }
//        
//        guard let bankURL = NSBundle.mainBundle().URLForResource("gs_instruments", withExtension: "dls") else {
//            fatalError("\"gs_instruments.dls\" file not found.")
//        }
//        
//        do {
//            try self.midiPlayer = AVMIDIPlayer(contentsOfURL: midiFileURL, soundBankURL: bankURL)
//            print("created midi player with sound bank url \(bankURL)")
//        } catch let error as NSError {
//            print("Error \(error.localizedDescription)")
//        }
//        
//        self.textView.text = self.midiPlayer.description
//        self.midiPlayer.prepareToPlay()
//
//    }
    
    
    
    func LoadMusicSequence () {
        var musicSequence:MusicSequence = MusicSequence()
        let status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            print("\(__LINE__) bad status \(status) creating sequence")
        }
        
        let midiFileURL = NSBundle.mainBundle().URLForResource(fileName, withExtension: "mid")

        // Load a MIDI file
        MusicSequenceFileLoad(musicSequence, midiFileURL!, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
        
        var numberOfTracks: UInt32
        let iPointer: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.alloc(1)

        MusicSequenceGetTrackCount(musicSequence, iPointer)
        numberOfTracks = iPointer.memory
        iPointer.dealloc(1)
        
        // Get the details for the first track.
        if numberOfTracks == 0 {
            self.textView.text = "the MIDI file is shit"
        } else {
            let header = "number of tracks \(numberOfTracks)\n"
            let trackInfo = self.getTrackInfo(musicSequence, trackNumber: 0)
            
            // We only want there to be one track in the sequence!
            if(numberOfTracks > 1) {
                for var i:UInt32 = 1; i < numberOfTracks; i++ {
                    self.getTrackInfo(musicSequence, trackNumber: i)
                }
            }
                
            self.textView.text = header + trackInfo
        }
    }
    
    
    func getTrackInfo(musicSequence:MusicSequence, trackNumber:UInt32) -> String {
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
            return ""
        }
        
        print("track length is \(trackLength)")
        
        
        // Create an iterator that will loop through the events in the track
        var iterator : MusicEventIterator = MusicEventIterator()
        NewMusicEventIterator(track, &iterator);
        
        var hasNext: DarwinBoolean = true
        var timestamp : MusicTimeStamp = 0
        var eventType : MusicEventType = 0
        var eventDataSize: UInt32 = 0
        let eventData: UnsafeMutablePointer<UnsafePointer<Void>> = UnsafeMutablePointer.alloc(1)

        
        // Run the loop
        MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
        while (hasNext) {
            MusicEventIteratorGetEventInfo(iterator,
                &timestamp,
                &eventType,
                eventData,
                &eventDataSize);
            
            // Process each event here
            print("Event found! type: \(eventType) at time \(timestamp)\n");
            
            MusicEventIteratorNextEvent(iterator);
            MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
        }
        
        return "track length \(trackLength)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
