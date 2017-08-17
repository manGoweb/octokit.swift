import Foundation
import RequestKit

// MARK: model

@objc open class Branch: NSObject {
    open var name: String?
    open let commit: Commit?
    open var isProtected: Bool
    open var protectionUrl: String?
    
    public init(_ json: [String: AnyObject]) {
        commit = Commit(json["commit"] as? [String: AnyObject] ?? [:])
        name = json["name"] as? String
        isProtected = json["protected"] as? Bool ?? false
        protectionUrl = json["protection_url"] as? String
    }
}

// MARK: request

public extension Octokit {
    
    public func branches(_ session: RequestKitURLSession = URLSession.shared, owner: String, repo: String, page: String = "1", perPage: String = "100", completion: @escaping (_ response: Response<[Branch]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = BranchRouter.readBranches(configuration, owner, repo, page, perPage)
        return router.loadJSON(session, expectedResultType: [[String: AnyObject]].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            }
            
            if let json = json {
                let repos = json.map { Branch($0) }
                completion(Response.success(repos))
            }
        }
    }
    
    public func branch(_ session: RequestKitURLSession = URLSession.shared, owner: String, repo: String, branch: String, page: String = "1", perPage: String = "100", completion: @escaping (_ response: Response<[Branch]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = BranchRouter.readBranch(configuration, owner, repo, branch, page, perPage)
        return router.loadJSON(session, expectedResultType: [[String: AnyObject]].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            }
            
            if let json = json {
                let repos = json.map { Branch($0) }
                completion(Response.success(repos))
            }
        }
    }
    
}

// MARK: Router

enum BranchRouter: Router {
    case readBranches(Configuration, String, String, String, String)
    case readBranch(Configuration, String, String, String, String, String)
    
    var configuration: Configuration {
        switch self {
        case .readBranches(let config, _, _, _, _): return config
        case .readBranch(let config, _, _, _, _, _): return config
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var encoding: HTTPEncoding {
        return .url
    }
    
    var params: [String: Any] {
        switch self {
        case .readBranches(_, _, _, let page, let perPage):
            return ["per_page": perPage, "page": page]
        case .readBranch(_, _, _, _, let page, let perPage):
            return ["per_page": perPage, "page": page]
        }
    }
    
    var path: String {
        switch self {
        case .readBranches(_, let owner, let repo, _, _):
            return "repos/\(owner)/\(repo)/branches"
        case .readBranch(_, let owner, let repo, let branch, _, _):
            return "repos/\(owner)/\(repo)/branches/\(branch)"
        }
    }
}
