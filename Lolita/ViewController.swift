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
import SVProgressHUD

let DribbleMoveSelectedCellBack = "DribbleMoveSelectedCellBack"

let LolitaToTimeLineNotification = "LolitaToTimeLineNotification"

let ShotCollectionViewTopInset: CGFloat = 50

let LolitaMenuFullHeight: CGFloat = 340

var MenuOpen = false

class ViewController: UIViewController {
    
    enum LolitaSelectChannel: Int {
        case Popular = 0
        case Animated
        case Debuts
        case Teams
        case Followed
        
        var HumanRead: String {
            switch self {
            case .Popular:
                return "popular"
            case .Teams:
                return "teams"
            case .Animated:
                return "animated"
            case .Debuts:
                return "debuts"
            case .Followed:
                return "followed"
            }
        }
    }
    
    @IBOutlet weak var menuButtomTop: NSLayoutConstraint!
    
    @IBOutlet weak var topBarViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var appLogoImage: UIImageView!
    
    @IBOutlet weak var blurViewContainer: UIView!
    
    @IBOutlet weak var logoImageCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var labelImage: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var footerMessageLabel: UILabel!
    
    var shotsCollectionView: UICollectionView?
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBAction func toggleMenu(sender: AnyObject) {
        
        if MenuOpen {
            MenuOpen = false
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                if self.shotsCollectionView!.contentOffset.y <= -40 {
                    if let blurView = self.blurView {
                        blurView.alpha = 0
                    }
                }

            }, completion: nil)
            
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 0.89,
                initialSpringVelocity: 15,
                options: UIViewAnimationOptions.AllowUserInteraction,
                animations: { () -> Void in
                    
                    if let menuLastHeight = self.menuLastHeight {
                        self.topBarViewHeight.constant = menuLastHeight
                    }
                    
                    self.view.layoutIfNeeded()
                    
                    if let blurView = self.blurView {
                        blurView.frame = self.blurViewContainer.bounds
                    }
                    
             
                }, completion: { finish in
                    self.handleTopViewBlurViewExisit(self.shotsCollectionView!)
            })
        } else {
            menuLastHeight = topBarView.frame.height
            MenuOpen = true
            self.addBlurViewOnTopView()
            
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 0.89,
                initialSpringVelocity: 15,
                options: UIViewAnimationOptions.AllowUserInteraction,
                animations: { () -> Void in
                
                    self.topBarViewHeight.constant = LolitaMenuFullHeight
                    self.view.layoutIfNeeded()
                    
                    if let blurView = self.blurView {
                        blurView.frame = self.blurViewContainer.bounds

                    }
                
            }, completion: nil)
        }
        

    }
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBAction func toggleProfile(sender: AnyObject) {
        
    }
    
    
    var shots = [DribbbleShot]()
    
    var blurEffectAdded = false
    
    let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)

    var blurView : UIVisualEffectView?
    
    var scrollUp = false
    
    var currentPage = 0
    
    var selectedCell: ShotCell?
    
    var loadingNewPage = false
    
    var menuChannel: LolitaSelectChannel = .Popular
    
    var menuLastHeight: CGFloat?
    
    enum HomeState: Int {
        case Welcome = 0
        case Timeline
        case Likes
    }
    
    var state: HomeState? {
        didSet {
            switch self.state! {
            case .Welcome:
                becomeWelcome()
            case .Timeline:
                becomeTimeline()
            case .Likes:
                break
            }
        }
    }
    
    @IBAction func signInWithDribbble(sender: AnyObject) {
        
        let URL = "\(DribbbleOauthURL)?client_id=\(DribbbleClientID)&redirect_uri=http://127.0.0.1:8180/dribbble&scope=public+comment+write"
        
        let safariViewController = SFSafariViewController(URL: NSURL(string:URL)!)
        
        let webServer = GCDWebServer()
        
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: {request in
            
            if let query = request.query, code = query["code"] as? String {
//                print(code)
                
                dribbbleTokenWithCode(code, complete: { (finish) -> Void in
                    print("Token Got")
                    webServer.stop()
                    NSNotificationCenter.defaultCenter().postNotificationName(LolitaToTimeLineNotification, object: nil)
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
        
        if let _ = Defaults[.dribbbleToken] {
//            print(token)
            self.state = .Timeline
        } else {
            self.state = .Welcome
        }
        
        blurView = UIVisualEffectView(effect: darkBlur)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moveSelectedCellBack:", name: DribbleMoveSelectedCellBack, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "lolitaBecomeTimeline", name: LolitaToTimeLineNotification, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func lolitaBecomeTimeline() {
        becomeTimeline()
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
    
    func animateOnLogo() {
        
        dispatch_async(dispatch_get_main_queue(),{
            SVProgressHUD.setBackgroundColor(UIColor.clearColor())
            SVProgressHUD.show()
        })
        
//        let animation = CABasicAnimation(keyPath: "transform")
//        
//        var tr = CATransform3DIdentity
//        tr = CATransform3DTranslate(tr, appLogoImage.bounds.size.width/2, appLogoImage.bounds.size.height/2, 0)
//        tr = CATransform3DScale(tr, 0.9, 0.9, 1)
//        tr = CATransform3DTranslate(tr, -appLogoImage.bounds.size.width/2, -appLogoImage.bounds.size.height/2, 0)
//        animation.toValue = NSValue(CATransform3D: tr)
//        
////        animation.fromValue = 1.0
//        animation.duration = 0.8
////        animation.toValue = 1.5
//        animation.repeatCount = 10
//        animation.autoreverses = true
////        animation.fillMode = kCAFillModeForwards
//        animation.removedOnCompletion = false
//        
//        appLogoImage.layer.addAnimation(animation, forKey: "transfrom.scale")
    }

}