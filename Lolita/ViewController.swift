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
import SwiftyUserDefaults

let ShotCollectionViewTopInset: CGFloat = 50

class ViewController: UIViewController {
    
    @IBOutlet weak var topBarViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var blurViewContainer: UIView!
    
    @IBOutlet weak var logoImageCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var labelImage: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var footerMessageLabel: UILabel!
    
    var shotsCollectionView: UICollectionView?
    
    @IBOutlet weak var topBarView: UIView!
    
    var shots = [DribbbleShot]()
    
    var blurEffectAdded = false
    
    let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)

    var blurView : UIVisualEffectView?
    
    var scrollUp = false
    
    var currentPage = 1
    
    enum HomeState: Int {
        case Welcome = 0
        case Timeline
        case Likes
    }
    
    var state: HomeState? {
        didSet {
            switch self.state! {
            case .Welcome:
                break
            case .Timeline:
                becomeTimeline()
            case .Likes:
                break
            }
        }
    }
    
    @IBAction func signInWithDribbble(sender: AnyObject) {
        
        let URL = "\(DribbbleOauthURL)?client_id=\(DribbbleClientID)&redirect_uri=http://127.0.0.1:8180/dribbble&scope=public+comment"
        
        let safariViewController = SFSafariViewController(URL: NSURL(string:URL)!)
        
        let webServer = GCDWebServer()
        
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: {request in
            
            if let query = request.query, code = query["code"] as? String {
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
        
        if let token = Defaults[.dribbbleToken] {
            print(token)
            self.state = .Timeline
        } else {
            self.state = .Welcome
        }
        
        blurView = UIVisualEffectView(effect: darkBlur)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}