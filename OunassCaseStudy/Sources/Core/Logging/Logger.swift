import Foundation
import os.log

struct Logger {
    private let log: OSLog

    init(category: String) {
        log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "ounass", category: category)
    }

    func log(_ message: String)     { os_log("%{public}@", log: log, type: .default, message) }
    func debug(_ message: String)   { os_log("%{public}@", log: log, type: .debug, message) }
    func warning(_ message: String) { os_log("%{public}@", log: log, type: .error, message) }
    func error(_ message: String)   { os_log("%{public}@", log: log, type: .fault, message) }
}
