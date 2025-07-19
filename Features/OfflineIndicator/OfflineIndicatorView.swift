import SwiftUI

struct OfflineIndicatorView: View {
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text("Offline Mode")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red)
                
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: isVisible)
        }
    }
}

#Preview {
    OfflineIndicatorView(isVisible: true)
} 