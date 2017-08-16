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
    
    /**
     Fetches the Repositories for a user or organization
     - parameter session: RequestKitURLSession, defaults to NSURLSession.sharedSession()
     - parameter owner: The user or organization that owns the repositories. If `nil`, fetches repositories for the authenticated user.
     - parameter page: Current page for repository pagination. `1` by default.
     - parameter perPage: Number of repositories per page. `100` by default.
     - parameter completion: Callback for the outcome of the fetch.
     */
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
    
//    /**
//     Fetches a repository for a user or organization
//     - parameter session: RequestKitURLSession, defaults to NSURLSession.sharedSession()
//     - parameter owner: The user or organization that owns the repositories.
//     - parameter name: The name of the repository to fetch.
//     - parameter completion: Callback for the outcome of the fetch.
//     */
//    public func branch(_ session: RequestKitURLSession = URLSession.shared, owner: String, repo: String, completion: @escaping (_ response: Response<Repository>) -> Void) -> URLSessionDataTaskProtocol? {
//        let router = BranchRouter.readRepository(configuration, owner, name)
//        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
//            if let error = error {
//                completion(Response.failure(error))
//            } else {
//                if let json = json {
//                    let repo = Repository(json)
//                    completion(Response.success(repo))
//                }
//            }
//        }
//    }
}

// MARK: Router

enum BranchRouter: Router {
    case readBranches(Configuration, String, String, String, String)
    
    var configuration: Configuration {
        switch self {
        case .readBranches(let config, _, _, _, _): return config
        //case .readRepository(let config, _, _): return config
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
//        case .readAuthenticatedRepositories(_, let page, let perPage):
//            return ["per_page": perPage, "page": page]
//        case .readRepository:
//            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .readBranches(_, let owner, let repo, _, _):
            return "repos/\(owner)/\(repo)/branches"
//        case .readAuthenticatedRepositories:
//            return "user/repos"
//        case .readRepository(_, let owner, let name):
//            return "repos/\(owner)/\(name)"
        }
    }
}
