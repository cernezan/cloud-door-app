import Foundation

struct AlertItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var message: String
}
