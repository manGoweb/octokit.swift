import Foundation
import RequestKit

// MARK: model

@objc open class Commit: NSObject {
    open let id: Int
    open var sha: String?
    open var url: String?
    
    public init(_ json: [String: AnyObject]) {
        if let id = json["id"] as? Int {
            self.id = id
            sha = json["sha"] as? String
            url = json["url"] as? String
        } else {
            id = -1
        }
    }
}
