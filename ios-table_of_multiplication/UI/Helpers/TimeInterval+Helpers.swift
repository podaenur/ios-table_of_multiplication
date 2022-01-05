import Foundation

extension TimeInterval {
    
    var hoursMinutesSecondsSplit: (hours: Int, minutes: Int, seconds: Int) {
        let source = Int(self)
        return (source / 3600, (source % 3600) / 60, (source % 3600) % 60)
    }
}
