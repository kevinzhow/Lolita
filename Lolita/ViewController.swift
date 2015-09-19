//
//  ViewController.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/19.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import UIKit
import SafariServices
import GCDWebServer

class ViewController: UIViewController {
    
    @IBAction func signInWithDribbble(sender: AnyObject) {
        
        let URL = "\(DribbbleOauthURL)?client_id=\(DribbbleClientID)&redirect_uri=http://127.0.0.1:8180/dribbble&scope=public+comment"
        
        let safariViewController = SFSafariViewController(URL: NSURL(string:URL)!)
        
        let webServer = GCDWebServer()
        
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: {request in
            
            if let dribbblePath = request.path, query = request.query, code = query["code"] as? String {
                print(code)
                
                dribbbleTokenWithCode(code, complete: { (finish) -> Void in
                    print("Token Got")
                })
            }
            
            safariViewController.dismissViewControllerAnimated(true, completion: nil)
            
            return GCDWebServerDataResponse(HTML:"<html><body><p>Wellcome to Lolita</p></body></html>")
            
        })
        
        webServer.startWithPort(8180, bonjourName: "GCD Web Server")
        
        print("Visit \(webServer.serverURL) in your web browser")
        
        self.presentViewController(safariViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {

}