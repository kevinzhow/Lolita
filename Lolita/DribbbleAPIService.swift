//
//  DribbbleAPIService.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/20.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD
import SwiftyUserDefaults

enum DribbbleAPI: String {
    case Shots = "/shots"
    case ShotsByFollowed = "/user/following/shots"
}

enum DribbbleTimeframe: String {
    case Week = "week"
    case Month = "month"
    case Year = "year"
    case Ever = "ever"
}



func shotsByListType(type: LolitaSelectChannel, page: Int, complete: (shots: [DribbbleShot]?) -> Void) {
    
    let request = authRequestPath(DribbbleAPI.Shots.rawValue + "?page=\(page)&per_page=50&list=\(type.HumanRead)", useMethod: .GET)
    
    Alamofire.request(request).responseJSON { (response) in
        
        if response.result.isSuccess {
            
            if let JSON = response.result.value as? [JSONDictionary] {
                print("Profile Got")
                let shots = JSON.map({ shotFromInfo($0) }).filter({ $0 != nil }).map({ $0! })
                complete(shots: shots)
            } else {
                complete(shots: nil)
            }
            
        } else {
            complete(shots: nil)
        }

//        
//        handleError(response, JSON: JSON.value, complete: { (statusCode, errorMesage) in
//            complete(nil)
//        })
        
    }
}

func followedShots(page: Int, complete: (shots: [DribbbleShot]?) -> Void) {
    
    let request = authRequestPath(DribbbleAPI.ShotsByFollowed.rawValue + "?page=\(page)&per_page=50", useMethod: .GET)
    
    Alamofire.request(request).responseJSON { (response) in
        
        if response.result.isSuccess {
            
            if let JSON = response.result.value as? [JSONDictionary] {
                print("Profile Got")
                let shots = JSON.map({ shotFromInfo($0) }).filter({ $0 != nil }).map({ $0! })
                complete(shots: shots)
            } else {
                complete(shots: nil)
            }
            
        } else {
            complete(shots: nil)
        }
        
        //
        //        handleError(response, JSON: JSON.value, complete: { (statusCode, errorMesage) in
        //            complete(nil)
        //        })
        
    }
}

func commentsByShotID(shotID: Int, complete: (comments: [DribbbleComment]?) -> Void) {
    
    let request = authRequestPath("\(DribbbleAPI.Shots.rawValue)/\(shotID)/comments", useMethod: .GET)
    
    Alamofire.request(request).responseJSON { (response) in
        
        if response.result.isSuccess {
            
            if let JSON = response.result.value as? [JSONDictionary] {
                print("Comments Got")
                let comments = JSON.map({ commentFromInfo($0) }).filter({ $0 != nil }).map({ $0! })
                complete(comments: comments)
            } else {
                complete(comments: nil)
            }
            
        } else {
            complete(comments: nil)
        }
        
        //
        //        handleError(response, JSON: JSON.value, complete: { (statusCode, errorMesage) in
        //            complete(nil)
        //        })
        
    }
}

func likeByShotID(shotID: Int, complete: (likeID: Int?) -> Void) {
    
    let request = authRequestPath("\(DribbbleAPI.Shots.rawValue)/\(shotID)/like", useMethod: .POST)
    
    Alamofire.request(request).responseJSON { (response) in
        
        if response.result.isSuccess {
            
            if let JSON = response.result.value as? JSONDictionary, likeID = JSON["id"] as? Int {
                print("Like Got")
                
                var dribbbleLike = Defaults[.dribbbleLike]
                
                dribbbleLike["\(shotID)"] = true
                
                Defaults[.dribbbleLike] = dribbbleLike
                
                complete(likeID: likeID)
            } else {
                complete(likeID: nil)
            }
            
        } else {
            complete(likeID: nil)
        }
        
        //
        //        handleError(response, JSON: JSON.value, complete: { (statusCode, errorMesage) in
        //            complete(nil)
        //        })
        
    }
}

func unLikeByShotID(shotID: Int, complete: (finished: Bool?) -> Void) {
    
    let request = authRequestPath("\(DribbbleAPI.Shots.rawValue)/\(shotID)/like", useMethod: .DELETE)
    
    Alamofire.request(request).responseJSON { (response) in
        
        if response.result.isSuccess {
            
            var dribbbleLike = Defaults[.dribbbleLike]
            
            dribbbleLike["\(shotID)"] = false
            
            Defaults[.dribbbleLike] = dribbbleLike
            
            complete(finished: true)
            
        } else {
            complete(finished: nil)
        }
        
        //
        //        handleError(response, JSON: JSON.value, complete: { (statusCode, errorMesage) in
        //            complete(nil)
        //        })
        
    }
}