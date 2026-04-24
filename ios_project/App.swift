import SwiftUI
import ReplayKit

@main
struct ShareScreenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 50) {
            Text("share screen for saiwan")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.blue)
            
            BroadcastPickerView()
                .frame(width: 120, height: 120)
            
            Text("TAP START TO SHARE")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

struct BroadcastPickerView: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        picker.preferredExtension = "com.saiwan.sharescreen.Extension"
        
        // This makes it look like a single START button
        for subview in picker.subviews {
            if let button = subview as? UIButton {
                button.setTitle("START", for: .normal)
                button.setImage(nil, for: .normal)
                button.backgroundColor = .systemBlue
                button.layer.cornerRadius = 60
            }
        }
        return picker
    }
    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}
