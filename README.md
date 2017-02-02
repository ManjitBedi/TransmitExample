# TransmitExample

This code was a proof of concept for an app project that did not materialze.  I put quite a bit of effort into this project & I decided to make it open source.

When the project started, it was one of my first real projects coded in Swift; the coding started in December 2016.  It could use a good code review & I just updated the project to be Swift 3 compliant.

What does this app do?  It lets you play video and sent haptic events to sync'ed iOS devies; the idea being that something happens in the video & you can receive a haptic event on the connected device. One device would be the designated video player.

The app uses frameworks for:
 * peer to peer networking
 * AV foundation to play video

The sync events can be done from a text file or using a MIDI file.

The proof concept did have a rather nice video made by a professional film maker but I cannot release the video with this app.  So I made a simple video with a time code overlay for 1 minute to include in the project.

It does need more work on the:

* error handling
* UI

