import SwiftUI

struct ContentView: View {
    @StateObject var board = Board()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(board.isConnected ? "接続完了" : "未接続")
            Button("発射") {
                Task {
                    board.sendPitchBend(channel: 0, pitchBend: 0)
                    try? await Task.sleep(for: .seconds(1))
                    board.sendPitchBend(channel: 0, pitchBend: 90)
                }
            }
            .disabled(!board.isConnected)
        }
        .font(.system(size: 60, weight: .heavy))
        .task(id: board.isConnected) {
            board.sendPitchBend(channel: 0, pitchBend: 90)  // 0: トリガー制御
            board.sendPitchBend(channel: 1, pitchBend: 120) // 1: 発射角度制御
        }
    }
}
