import SwiftUI

struct DoorListView: View {
    let doors: [LocationWithDistance]
    let onDoorTap: (LocationWithDistance) -> Void
    let onSetAlias: (LocationWithDistance) -> Void

    var body: some View {
        List(doors) { door in
            Button {
                onDoorTap(door)
            } label: {
                LabeledContent {
                    Text(formattedDistance(door.distance))
                        .foregroundStyle(.secondary)
                } label: {
                    Label(door.location.name, systemImage: door.inRadius ? "door.left.hand.open" : "door.left.hand.closed")
                        .foregroundStyle(door.inRadius ? .primary : .secondary)
                }
            }
            .accessibilityLabel("\(door.location.name), \(formattedDistance(door.distance))")
            .accessibilityHint(door.inRadius ? "Opens this door" : "Out of range")
            .swipeActions(edge: .trailing) {
                Button {
                    onSetAlias(door)
                } label: {
                    Label("Siri Name", systemImage: "mic")
                }
                .tint(.purple)
            }
        }
    }

    private func formattedDistance(_ distance: Int?) -> String {
        guard let distance else { return "—" }
        if distance > 1000 {
            return "\(distance / 1000) km"
        }
        return "\(distance) m"
    }
}
