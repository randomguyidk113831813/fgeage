import ReplayKit
import Foundation

class SampleHandler: RPBroadcastSampleHandler {
    
    // Replace with your computer's IP
    let serverURL = URL(string: "http://192.168.2.184:5000/screen_frame")!
    var lastSendTime: TimeInterval = 0

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has started the broadcast
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            // Send a frame every 1 second to save battery and data
            let now = Date().timeIntervalSince1970
            if now - lastSendTime > 1.0 {
                lastSendTime = now
                if let image = imageFromSampleBuffer(sampleBuffer) {
                    sendFrameToServer(image)
                }
            }
        default:
            break
        }
    }

    func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> Data? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.jpegData(compressionQuality: 0.3)
    }

    func sendFrameToServer(_ imageData: Data) {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let base64String = imageData.base64EncodedString()
        let json: [String: Any] = ["image": "data:image/jpeg;base64," + base64String]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
}
