import Combine
import CoreMIDI

@MainActor
class Board: ObservableObject {
    private var clientRef = MIDIClientRef()
    private var outputPortRef = MIDIPortRef()
    
    private var destinationRef: MIDIEndpointRef?
    
    @Published var isConnected = false
    
    init() {
        MIDIClientCreateWithBlock("Client" as CFString,
                                  &clientRef) { [weak self] _ in
            Task { @MainActor in
                self?.updateDestination()
            }
        }
        
        MIDIOutputPortCreate(clientRef,
                             "Output" as CFString,
                             &outputPortRef)
        
        updateDestination()
    }
    
    func updateDestination() {
        let numberOfDestinations = MIDIGetNumberOfDestinations()
        for i in 0 ..< numberOfDestinations {
            let ref = MIDIGetDestination(i)
            var value: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(ref, kMIDIPropertyManufacturer, &value)
            let manufacturer = value?.takeRetainedValue() as String?
            if manufacturer == "Raspberry Pi" {
                destinationRef = ref
                isConnected = true
                return
            }
        }
        destinationRef = nil
        isConnected = false
    }
    
    func sendPitchBend(channel: UInt, pitchBend: UInt) {
        guard channel <= 0x0f, pitchBend <= 0x3fff else { return }
        
        let message = MIDI1UPPitchBend(0,
                                       UInt8(channel),
                                       UInt8(pitchBend & 0x7f),
                                       UInt8(pitchBend >> 7))
        
        sendMIDI1Message(message)
    }
    
    func sendMIDI1Message(_ message: MIDIMessage_32) {
        guard let destinationRef else { return }
        
        var packet = MIDIEventPacket()
        packet.words.0 = message
        packet.wordCount = 1
        
        var eventList = MIDIEventList(protocol: ._1_0,
                                      numPackets: 1,
                                      packet: packet)
        
        MIDISendEventList(outputPortRef, destinationRef, &eventList)
    }
}
