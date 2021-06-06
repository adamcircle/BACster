import UIKit

var str = "Hello, playground"

var now = Date()
//Date().addTimeInterval(TimeInterval(-5.0 * 60.0))

let time = NSDate().timeIntervalSince1970
let ti = Int(Date().timeIntervalSince1970)
print(time)
print(ti)

var timeLastUpdated = Date(timeIntervalSince1970:  0).timeIntervalSince1970
print(timeLastUpdated)
