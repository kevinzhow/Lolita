//
//  LolitaService.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/19.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD
import SwiftyUserDefaults

typealias JSONDictionary = [String: AnyObject]

let DribbbleOauthURL = "https://dribbble.com/oauth/authorize"
let DribbbleOAuthToken = "https://dribbble.com/oauth/token"
let DribbbleClientID = "77e570ab17808f0699b6e01b8fdd565e17cd8147599a6f317b478aff4b6560c7"
let DribbbleClientSecret = "2975d86f61ac0cf7e10f929203cc44567182a9322eb2a07dee7a2d56f6ae093f"
let dribbbleBaseURL = "https://api.dribbble.com/v1"
let callbackURL = "http://127.0.0.1:8180/dribbble"

extension DefaultsKeys {
    static let dribbbleToken = DefaultsKey<String?>("dribbbleToken")
}

func authRequestPath(path: String, useMethod method: Alamofire.Method) -> NSMutableURLRequest {
    
    let URL = NSURL(string: dribbbleBaseURL + path)!
    
    let mutableURLRequest = NSMutableURLRequest(URL: URL)
    mutableURLRequest.HTTPMethod = method.rawValue
    if let token = Defaults[.dribbbleToken] {
       mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    
    return mutableURLRequest
}

func dribbbleTokenWithCode(code: String , complete: (finish: Bool) -> Void) {
    
    dispatch_async(dispatch_get_main_queue(),{

        SVProgressHUD.showWithStatus("Connecting")
    })
    
    let parameters = [
        "client_id": DribbbleClientID,
        "client_secret": DribbbleClientSecret,
        "code": code,
        "redirect_uri": callbackURL
    ]
    
    Alamofire.request(.POST, DribbbleOAuthToken, parameters: parameters)
        .responseJSON { _, _, result in
            
            print("Success: \(result.isSuccess)")
//            print("Response String: \(result.value)")
            
            if let json = result.value as? [String: AnyObject], access_token = json["access_token"] as? String {
                
                print("User OAuth Finished")
                
                Defaults[.dribbbleToken] = access_token
                
                dispatch_async(dispatch_get_main_queue(),{
                    SVProgressHUD.dismiss()
                })
                
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    
                    SVProgressHUD.showErrorWithStatus("Please Try Again")
                })
            }
    }
}