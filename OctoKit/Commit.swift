import Foundation
import RequestKit

// MARK: model

@objc open class Commit: NSObject {
    open var sha: String?
    open var url: String?
    
    public init(_ json: [String: AnyObject]) {
        sha = json["sha"] as? String
        url = json["url"] as? String
    }
}
