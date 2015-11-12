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
let callbackURL = "lolita://oauth"
let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

extension NSURL {
    func queryDictionary() -> [String:String] {
        let components = self.query?.componentsSeparatedByString("&")
        var dictionary = [String:String]()
        
        for pairs in components ?? [] {
            let pair = pairs.componentsSeparatedByString("=")
            if pair.count == 2 {
                dictionary[pair[0]] = pair[1]
            }
        }
        
        return dictionary
    }
}

func saveImageDataWithURL(data: NSData, URL: String, shotID: Int) {
    
    let imagePath = (paths as NSString).stringByAppendingPathComponent("\(shotID).gif")
    
    if !data.writeToFile(imagePath, atomically: false)
    {
        print("not saved")
    } else {
        print("saved")
    }
}

func findImageDataWithURL(URL: String, shotID: Int) -> NSData? {
    
    let imagePath = (paths as NSString).stringByAppendingPathComponent("\(shotID).gif")
    
    let fileURL = NSURL(fileURLWithPath: imagePath)
    
    if let data = NSData(contentsOfFile: fileURL.path!) {
        print("Found")
        return data
    } else {
        return nil
    }
    
    
}

func randomStringWithLength (len : Int) -> NSString {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString
}

typealias CancelableTask = (cancel: Bool) -> Void


func delay(time: NSTimeInterval, work: dispatch_block_t) -> CancelableTask? {
    
    var finalTask: CancelableTask?
    
    let cancelableTask: CancelableTask = { cancel in
        if cancel {
            finalTask = nil // key
            
        } else {
            dispatch_async(dispatch_get_main_queue(), work)
        }
    }
    
    finalTask = cancelableTask
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        if let task = finalTask {
            task(cancel: false)
        }
    }
    
    return finalTask
}

func cancel(cancelableTask: CancelableTask?) {
    cancelableTask?(cancel: true)
}


extension DefaultsKeys {
    static let dribbbleToken = DefaultsKey<String?>("dribbbleToken")
    static let dribbbleLike = DefaultsKey<[String: AnyObject]>("dribbleLike")
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
        .responseJSON { response in
            
            print("Success: \(response.result.isSuccess)")
//            print("Response String: \(result.value)")
            
            if let json = response.result.value as? [String: AnyObject], access_token = json["access_token"] as? String {
                
                print("User OAuth Finished")
                
                Defaults[.dribbbleToken] = access_token
                
                dispatch_async(dispatch_get_main_queue(),{
                    SVProgressHUD.dismiss()
                })
                
                complete(finish: true)
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    SVProgressHUD.showErrorWithStatus("Please Try Again")
                })
                
                complete(finish: false)
            }
    }
}