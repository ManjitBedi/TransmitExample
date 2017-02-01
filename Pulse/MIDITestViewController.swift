//
//  MIDiTestViewController.swift
//  Pulse
//
//  Created by Manjit Bedi on 2016-01-21.
//  Copyright © 2016 No Org. All rights reserved.
//
//
// This code is for trying to load a MIDI file and printing out on the debug console
// some of the details of the MIDI track.
//
//  This code originates from a larger project which is a proof of concept
//
//  This code is based on the blog of Gene De Lisa
//  http://www.rockhoppertech.com/blog/swift-2-avfoundation-to-play-audio-or-midi/
//  http://www.rockhoppertech.com/blog/swift-2-and-coremidi/

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
        
        // There is a video file and correpsonding MIDI file in the app bundle
        fileName = "video"
        
        let status = self.LoadMusicSequence()
        if (!status) {
            let alert = UIAlertController(title: "Alert", message: "There was a problem with MIDI file.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func playSomeMIDI(_ sender: AnyObject) {
        
        // Playing a MIDI file is quite simple!
        self.midiPlayer.play { () -> Void in
            print("MIDI finished")
        }
    }

    // To play a MIDI file, we need to have loaded a sound font
    func createAVMIDIPlayerFromMIDIFIleDLS() {
        guard let midiFileURL = Bundle.main.url(forResource: fileName, withExtension: "mid") else {
            fatalError("'\(fileName)' file not found.")
        }
        
        guard let bankURL = Bundle.main.url(forResource: "gs_instruments", withExtension: "dls") else {
            fatalError("\"gs_instruments.dls\" file not found.")
        }
        
        do {
            try self.midiPlayer = AVMIDIPlayer(contentsOf: midiFileURL, soundBankURL: bankURL)
            print("created midi player with sound bank url \(bankURL)")
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        self.textView.text = self.midiPlayer.description
        self.midiPlayer.prepareToPlay()
    }
    
    // Load a MIDI sequence and get the lengths of the tracks
    // This requires calling C methods and using bridging
    func LoadMusicSequence () -> Bool {
        var musicSequence:MusicSequence? = nil
        var status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            print("\(#line) bad status \(status) creating sequence")
        }
        
        let midiFileURL = Bundle.main.url(forResource: fileName, withExtension: "mid")

        // Load a MIDI file
        status = MusicSequenceFileLoad(musicSequence!, midiFileURL! as CFURL, MusicSequenceFileTypeID.midiType, MusicSequenceLoadFlags())
        
        if status != OSStatus(noErr) {
            print("\(#line) Error with opening the MIDI sequence \(status)")
            return false
        }
        
        var numberOfTracks: UInt32
        let iPointer: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.allocate(capacity: 1)

        status = MusicSequenceGetTrackCount(musicSequence!, iPointer)
        if status != OSStatus(noErr) {
            print("\(#line) Error getting number of tracks \(status)")
            return false
        }
        
        numberOfTracks = iPointer.pointee
        iPointer.deallocate(capacity: 1)
        
        // Get the details for the first track.
        if numberOfTracks == 0 {
            self.textView.text = "the MIDI file has problems"
        } else {
            let header = "number of tracks \(numberOfTracks)\n"
            let trackInfo = self.getTrackInfo(musicSequence!, trackNumber: 0)
            
            // We only want there to be one track in the sequence!
            if (numberOfTracks > 1) {
                for i:UInt32 in 1 ..< numberOfTracks {
                    self.getTrackInfo(musicSequence!, trackNumber: i)
                }
            }
                
            self.textView.text = header + trackInfo
        }
        
        return true
    }
    
    
    // Given a MIDI track get the length of the track
    // and report on the events in the track
    func getTrackInfo(_ musicSequence:MusicSequence, trackNumber:UInt32) -> String {
        var track : MusicTrack? = nil
        let trackPointer: UnsafeMutablePointer<MusicTrack> = UnsafeMutablePointer.allocate(capacity: 1)
        MusicSequenceGetIndTrack(musicSequence, trackNumber, trackPointer)
        track = trackPointer.pointee
        trackPointer.deallocate(capacity: 1)
        
        var trackLength = MusicTimeStamp(0)
        var tracklengthSize = UInt32(0)
        var status = MusicTrackGetProperty(track!,
            UInt32(kSequenceTrackProperty_TrackLength),
            &trackLength,
            &tracklengthSize)
        if status != OSStatus(noErr) {
            print("\(#line) Error getting track length \(status)")
            return ""
        }
        
        print("track length is \(trackLength)")
        
        
        // Create an iterator that will loop through the events in the track
        var iterator : MusicEventIterator? = nil
        status = NewMusicEventIterator(track!, &iterator);
        
        if status != OSStatus(noErr) {
            print("\(#line) Error creating iterator \(status)")
            return ""
        }
        
        var hasNext: DarwinBoolean = true
        var timestamp : MusicTimeStamp = MusicTimeStamp(0)
        var eventType : MusicEventType = MusicEventType(0)
        var eventDataSize: UInt32 = 0
        let eventData: UnsafeMutablePointer<UnsafeRawPointer>? = nil
        
        // Iterate through the events in the MIDI track
        MusicEventIteratorHasCurrentEvent(iterator!, &hasNext);
        while (hasNext).boolValue {
            status = MusicEventIteratorGetEventInfo(iterator!,
                &timestamp,
                &eventType,
                eventData,
                &eventDataSize);
            
            if status != OSStatus(noErr) {
                print("\(#line) Error getting event from track \(status)")
            } else {
                print("Event found! type: \(eventType) at time \(timestamp)\n");
            }
            MusicEventIteratorNextEvent(iterator!);
            MusicEventIteratorHasCurrentEvent(iterator!, &hasNext);
        }
        
        return "track length \(trackLength)"
    }
}
