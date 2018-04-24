////
///  Comment.swift
//

import SwiftyJSON


let CommentVersion = 1

@objc(ElloComment)
final class ElloComment: Model, Authorable, Groupable {

    let id: String
    var groupId: String { return "Post-\(postId)" }
    let createdAt: Date
    let authorId: String
    let postId: String
    var content: [Regionable]
    var body: [Regionable]?
    var summary: [Regionable]?
    var assets: [Asset] { return getLinkArray("assets") }
    var author: User? { return getLinkObject("author") }
    var parentPost: Post? { return getLinkObject("parent_post") }
    var loadedFromPost: Post? { return getLinkObject("loaded_from_post") ?? parentPost }
    // to show hide in the stream, and for comment replies
    var loadedFromPostId: String {
        didSet { addLinkObject("loaded_from_post", key: loadedFromPostId, type: .postsType) }
    }

    init(id: String,
        createdAt: Date,
        authorId: String,
        postId: String,
        content: [Regionable])
    {
        self.id = id
        self.createdAt = createdAt
        self.authorId = authorId
        self.postId = postId
        self.loadedFromPostId = postId
        self.content = content
        super.init(version: CommentVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        self.authorId = decoder.decodeKey("authorId")
        self.postId = decoder.decodeKey("postId")
        self.content = decoder.decodeKey("content")
        self.loadedFromPostId = decoder.decodeKey("loadedFromPostId")
        self.body = decoder.decodeOptionalKey("body")
        self.summary = decoder.decodeOptionalKey("summary")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        coder.encodeObject(authorId, forKey: "authorId")
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(content, forKey: "content")
        coder.encodeObject(loadedFromPostId, forKey: "loadedFromPostId")
        coder.encodeObject(body, forKey: "body")
        coder.encodeObject(summary, forKey: "summary")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> ElloComment {
        let json = JSON(data)
        var createdAt: Date
        if let date = json["created_at"].stringValue.toDate() {
            createdAt = date
        }
        else {
            createdAt = Globals.now
        }

        let comment = ElloComment(
            id: json["id"].stringValue,
            createdAt: createdAt,
            authorId: json["author_id"].stringValue,
            postId: json["post_id"].stringValue,
            content: RegionParser.jsonRegions(json: json["content"])
        )
        comment.body = RegionParser.jsonRegions(json: json["body"])
        comment.summary = RegionParser.jsonRegions(json: json["summary"])

        comment.mergeLinks(data["links"] as? [String: Any])
        comment.addLinkObject("author", key: comment.authorId, type: .usersType)
        comment.addLinkObject("parent_post", key: comment.postId, type: .postsType)

        return comment
    }

    class func newCommentForPost(_ post: Post, currentUser: User) -> ElloComment {
        let comment = ElloComment(
            id: UUID().uuidString,
            createdAt: Globals.now,
            authorId: currentUser.id,
            postId: post.id,
            content: [Regionable]()
        )
        return comment
    }
}

extension ElloComment: JSONSaveable {
    var uniqueId: String? { return "ElloComment-\(id)" }
    var tableId: String? { return id }

}
