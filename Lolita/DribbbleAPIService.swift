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
}

enum DribbbleListType: String {
    case Default = ""
}

enum DribbbleTimeframe: String {
    case Week = "week"
    case Month = "month"
    case Year = "year"
    case Ever = "ever"
}


func shotsByListType(type: DribbbleListType, complete: (shots: [DribbbleShot]?) -> Void) {
    
    let request = authRequestPath(DribbbleAPI.Shots.rawValue + "?per_page=50", useMethod: .GET)
    
    Alamofire.request(request).responseJSON { (request, response, JSON) in
        
        if JSON.isSuccess {
            
            if let JSON = JSON.value as? [JSONDictionary] {
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