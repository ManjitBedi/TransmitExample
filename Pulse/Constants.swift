struct PulseConstants {
    struct Media {
        static let defaultVideoName = "video"
        static let validFileExtensions = ["mov", "m4v", "mpg", "mp4"]
    }
    
    struct Preferences {
        static let mediaKeyPref = "com.noorg.pulse.mediaPath"
        static let useDocumentsKeyPref = "com.noorg.pulse.useDocuments"
        static let useMIDIKeyPref = "com.noorg.pulse.useMIDI"
    }
}