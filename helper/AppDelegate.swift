import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

class AppDelegate: NSObject, NSApplicationDelegate {
    var pendingURL: String?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let url = pendingURL {
            handleURL(url)
        }
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        handleURL(url.absoluteString)
    }
    
    func handleURL(_ urlString: String) {
        let url = urlString.replacingOccurrences(of: "ytmp3://", with: "")
        
        guard url.contains("youtube.com") || url.contains("youtu.be") else {
            showAlert(title: "Invalid URL", message: "Please enter a valid YouTube link")
            return
        }
        
        downloadMP3(url)
    }
    
    func downloadMP3(_ videoURL: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/Library/Frameworks/Python.framework/Versions/3.11/bin/yt-dlp")
            process.arguments = [
                "-x", "--audio-format", "mp3",
                "--audio-quality", "0",
                "-o", NSHomeDirectory() + "/Downloads/%(title)s.%(ext)s",
                videoURL
            ]
            
            do {
                try process.run()
                process.waitUntilExit()
                
                DispatchQueue.main.async {
                    self.showAlert(title: "Download Complete", message: "MP3 saved to Downloads folder")
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
        NSApp.terminate(nil)
    }
}