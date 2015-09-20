//
//  DribbbleModel.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/20.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import Foundation

let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

struct DribbbleComment {
    let id: Int
    let body: String
    let likes_count: Int
    let likes_url: String
    let created_at: NSDate
    let updated_at: NSDate
    let user: DribbbleUser
}

struct DribbbleShot {
    let id: Int
    let title: String
    let description: String?
    let width: Int
    let height: Int
    let images: JSONDictionary
    let views_count: Int
    let likes_count: Int
    let comments_count: Int
    let attachments_count: Int
    let rebounds_count: Int
    let buckets_count: Int
    let created_at: NSDate
    let updated_at: NSDate
    let html_url: String
    let attachments_url: String
    let buckets_url: String
    let comments_url: String
    let likes_url: String
    let projects_url: String
    let rebounds_url: String
    let animated: Bool
    let tags: [String]
    let user: DribbbleUser
}

struct DribbbleUser {
    let id: Int
    let name: String
    let username: String
    let html_url: String
    let avatar_url: String
    let bio: String
    let location: String?
    let links: JSONDictionary
    let buckets_count: Int
    let comments_received_count: Int
    let followers_count: Int
    let followings_count: Int
    let likes_count: Int
    let likes_received_count: Int
    let projects_count: Int
    let rebounds_received_count: Int
    let shots_count: Int
    let teams_count: Int?
    let can_upload_shot: Bool
    let type: String
    let pro: Bool
    let buckets_url: String
    let followers_url: String
    let following_url: String
    let likes_url: String
    let projects_url: String
    let shots_url: String
    let teams_url: String?
    let created_at: NSDate
    let updated_at: NSDate
}

func dateFromString(dateString: AnyObject?) -> NSDate? {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    if let dateString = dateString as? String, date = dateFormatter.dateFromString(dateString) {
        return date
    } else {
        print("Parse Date error \(dateString)", terminator: "")
        return nil
    }
}


func commentFromInfo(info: JSONDictionary) -> DribbbleComment? {
    
    if let id = info["id"] as? Int,
        body = info["body"] as? String,
        likes_count = info["likes_count"] as? Int,
        likes_url = info["likes_url"] as? String,
        created_at = dateFromString(info["created_at"]),
        updated_at = dateFromString(info["updated_at"]),
        userInfo = info["user"] as? JSONDictionary,
        user = userFromInfo(userInfo)
    {
        
        return DribbbleComment(id: id, body: body, likes_count: likes_count, likes_url: likes_url, created_at: created_at, updated_at: updated_at, user: user)
        
    } else {
        print("Comment Not Fit")
        //        print(info)
    }
    
    return nil
}


func shotFromInfo(info: JSONDictionary) -> DribbbleShot? {
    
    if let id = info["id"] as? Int,
        title = info["title"] as? String,
        width = info["width"] as? Int,
        height = info["height"] as? Int,
        images = info["images"] as? JSONDictionary,
        views_count = info["views_count"] as? Int,
        likes_count = info["likes_count"] as? Int,
        comments_count = info["comments_count"] as? Int,
        attachments_count = info["attachments_count"] as? Int,
        rebounds_count = info["rebounds_count"] as? Int,
        buckets_count = info["buckets_count"] as? Int,
        html_url = info["html_url"] as? String,
        animated = info["animated"] as? Bool,
        attachments_url = info["attachments_url"] as? String,
        buckets_url = info["buckets_url"] as? String,
        comments_url = info["comments_url"] as? String,
        likes_url = info["likes_url"] as? String,
        projects_url = info["projects_url"] as? String,
        rebounds_url = info["rebounds_url"] as? String,
        tags = info["tags"] as? [String],
        created_at = dateFromString(info["created_at"]),
        updated_at = dateFromString(info["updated_at"]),
        userInfo = info["user"] as? JSONDictionary,
        user = userFromInfo(userInfo)
    {
        let description = info["description"] as? String
        
        return DribbbleShot(id: id, title: title, description: description, width: width, height: height, images: images, views_count: views_count, likes_count: likes_count, comments_count: comments_count, attachments_count: attachments_count, rebounds_count: rebounds_count, buckets_count: buckets_count, created_at: created_at, updated_at: updated_at, html_url: html_url, attachments_url: attachments_url, buckets_url: buckets_url, comments_url: comments_url, likes_url: likes_url, projects_url: projects_url, rebounds_url: rebounds_url, animated: animated, tags: tags, user: user)
        
    } else {
        print("Shot Not Fit")
//        print(info)
    }
    
    return nil
}

func userFromInfo(info: JSONDictionary) -> DribbbleUser? {
    
    if let id = info["id"] as? Int,
        name = info["name"] as? String,
        username = info["username"] as? String,
        html_url = info["html_url"] as? String,
        avatar_url = info["avatar_url"] as? String,
        bio = info["bio"] as? String,
        links = info["links"] as? JSONDictionary,
        buckets_count = info["buckets_count"] as? Int,
        comments_received_count = info["comments_received_count"] as? Int,
        followers_count = info["followers_count"] as? Int,
        followings_count = info["followings_count"] as? Int,
        likes_count = info["likes_count"] as? Int,
        likes_received_count = info["likes_received_count"] as? Int,
        projects_count = info["projects_count"] as? Int,
        rebounds_received_count = info["rebounds_received_count"] as? Int,
        shots_count = info["shots_count"] as? Int,
        can_upload_shot = info["can_upload_shot"] as? Bool,
        type = info["type"] as? String,
        pro = info["pro"] as? Bool,
        buckets_url = info["buckets_url"] as? String,
        followers_url = info["followers_url"] as? String,
        following_url = info["following_url"] as? String,
        likes_url = info["likes_url"] as? String,
        projects_url = info["projects_url"] as? String,
        shots_url = info["shots_url"] as? String,
        created_at = dateFromString(info["created_at"]),
        updated_at = dateFromString(info["updated_at"])
    {
        let location = info["location"] as? String
        let teams_count = info["teams_count"] as? Int
        let teams_url = info["teams_url"] as? String
    
        return DribbbleUser(id: id, name: name, username: username, html_url: html_url, avatar_url: avatar_url, bio: bio, location: location, links: links, buckets_count: buckets_count, comments_received_count: comments_received_count, followers_count: followers_count, followings_count: followings_count, likes_count: likes_count, likes_received_count: likes_received_count, projects_count: projects_count, rebounds_received_count: rebounds_received_count, shots_count: shots_count, teams_count: teams_count, can_upload_shot: can_upload_shot, type: type, pro: pro, buckets_url: buckets_url, followers_url: followers_url, following_url: following_url, likes_url: likes_url, projects_url: projects_url, shots_url: shots_url, teams_url: teams_url, created_at: created_at, updated_at: updated_at)
    } else {
        print("User Not Fit")
//        print(info)
    }
    
    return nil
}
