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
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createAVMIDIPlayerFromMIDIFIleDLS()
    }
    
    @IBAction func playSomeMIDI(sender: AnyObject) {
        self.midiPlayer.play { () -> Void in
            print("MIDI finished")
        }
    }

    func createAVMIDIPlayerFromMIDIFIleDLS() {
        
        guard let midiFileURL = NSBundle.mainBundle().URLForResource("teddybear", withExtension: "mid") else {
            fatalError("\"teddybear\" file not found.")
        }
        
        guard let bankURL = NSBundle.mainBundle().URLForResource("gs_instruments", withExtension: "dls") else {
            fatalError("\"gs_instruments.dls\" file not found.")
        }
        
        do {
            try self.midiPlayer = AVMIDIPlayer(contentsOfURL: midiFileURL, soundBankURL: bankURL)
            print("created midi player with sound bank url \(bankURL)")
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        self.textView.text = self.midiPlayer.description
        
        self.midiPlayer.prepareToPlay()
        
        self.LoadMusicSequence()
    }
    
    func LoadMusicSequence () {
        
        //let musicSequence:MusicSequence = MusicSequence()
        
        var musicSequence:MusicSequence = MusicSequence()
        let status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            print("\(__LINE__) bad status \(status) creating sequence")
        }
        
        let midiFileURL = NSBundle.mainBundle().URLForResource("teddybear", withExtension: "mid")

        // Load a MIDI file
        MusicSequenceFileLoad(musicSequence, midiFileURL!, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
        
        var numberOfTracks: UInt32
        let iPointer: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer.alloc(1)

        MusicSequenceGetTrackCount(musicSequence, iPointer)
        numberOfTracks = iPointer.memory
        iPointer.dealloc(1)
        self.textView.text = "number of tracks " + String(numberOfTracks)

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
