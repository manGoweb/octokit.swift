import Foundation
import RequestKit

// MARK: model

@objc open class CommitUser: NSObject {
    open var name: String?
    open var email: String?
    open var date: Date?
    
    public init(_ json: [String: AnyObject]) {
        name = json["name"] as? String
        email = json["email"] as? String
        date = Time.rfc3339Date(json["date"] as? String)
    }
}

@objc open class Commit: NSObject {
    open let author: User?
    open let authored: CommitUser?
    open let committer: User?
    open let committed: CommitUser?
    open var sha: String?
    open var commitMessage: String?
    open var url: String?
    open var htmlUrl: String?
    open var commentsUrl: String?
    
    public init(_ json: [String: AnyObject]) {
        author = User(json["author"] as? [String: AnyObject] ?? [:])
        authored = CommitUser(json["commit"]?["author"] as? [String: AnyObject] ?? [:])
        
        committer = User(json["committer"] as? [String: AnyObject] ?? [:])
        committed = CommitUser(json["com    mit"]?["author"] as? [String: AnyObject] ?? [:])
        
        sha = json["sha"] as? String
        commitMessage = json["commit"]?["message"] as? String
        url = json["url"] as? String
        htmlUrl = json["html_url"] as? String
        commentsUrl = json["comments_url"] as? String
    }
}

// MARK: request

public extension Octokit {
    
    public func commits(_ session: RequestKitURLSession = URLSession.shared, owner: String, repo: String, branch: String? = nil, page: String = "1", perPage: String = "100", completion: @escaping (_ response: Response<[Commit]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommitRouter.readCommits(configuration, owner, repo, branch, page, perPage)
        return router.loadJSON(session, expectedResultType: [[String: AnyObject]].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            }
            
            if let json = json {
                let repos = json.map { Commit($0) }
                completion(Response.success(repos))
            }
        }
    }
    
    public func commit(_ session: RequestKitURLSession = URLSession.shared, owner: String, repo: String, commitSha: String, page: String = "1", perPage: String = "100", completion: @escaping (_ response: Response<[Commit]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommitRouter.readCommit(configuration, owner, repo, commitSha, page, perPage)
        return router.loadJSON(session, expectedResultType: [[String: AnyObject]].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            }
            
            if let json = json {
                let repos = json.map { Commit($0) }
                completion(Response.success(repos))
            }
        }
    }
    
}

// MARK: Router

enum CommitRouter: Router {
    case readCommits(Configuration, String, String, String?, String, String)
    case readCommit(Configuration, String, String, String, String, String)
    
    var configuration: Configuration {
        switch self {
        case .readCommits(let config, _, _, _, _, _): return config
        case .readCommit(let config, _, _, _, _, _): return config
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
        case .readCommits(_, _, _, let branch, let page, let perPage):
            var p = ["per_page": perPage, "page": page]
            if let b = branch {
                p["sha"] = branch
            }
            return p
        case .readCommit(_, _, _, let sha, let page, let perPage):
            return ["per_page": perPage, "page": page, "sha": sha]
        }
    }
    
    var path: String {
        switch self {
        case .readCommits(_, let owner, let repo, _, _, _):
            return "repos/\(owner)/\(repo)/commits"
        case .readCommit(_, let owner, let repo, _, _, _):
            return "repos/\(owner)/\(repo)/commits"
        }
    }
}
