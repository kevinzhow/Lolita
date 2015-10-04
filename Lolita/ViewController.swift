//
//  ViewController.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/19.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import UIKit
import SafariServices
import SwiftyUserDefaults
import SVProgressHUD

let DribbleMoveSelectedCellBack = "DribbleMoveSelectedCellBack"

let LolitaToTimeLineNotification = "LolitaToTimeLineNotification"

let ShotCollectionViewTopInset: CGFloat = 50

let LolitaMenuFullHeight: CGFloat = 300

var MenuOpen = false

let LolitaColor = UIColor(red: 80.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 1.0)

var DribbbleShotDownloading = [Int: Bool]()

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

class ViewController: UIViewController {
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var animatedButton: UIButton!
    @IBOutlet weak var debutsButton: UIButton!
    
    @IBOutlet weak var followedButton: UIButton!
    @IBOutlet weak var teamsButton: UIButton!

    
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
    
    var safariViewController: SFSafariViewController?
    
    func matchMenuOpen(open: Bool) {
        if open {
            menuButton.tintColor = UIColor.whiteColor()
            profileButton.tintColor = UIColor.whiteColor()
        } else {
            menuButton.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            profileButton.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        }
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        
        if MenuOpen {
            MenuOpen = false
            
            matchMenuOpen(false)
            
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
            
            matchMenuOpen(true)
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
    
    var menuChannel: LolitaSelectChannel? {
        didSet {
            resetMenu()
            
            switch self.menuChannel! {
            case .Popular:
                self.popularButton.setTitleColor(LolitaColor, forState: UIControlState.Normal)
            case .Teams:
                self.teamsButton.setTitleColor(LolitaColor, forState: UIControlState.Normal)
            case .Animated:
                self.animatedButton.setTitleColor(LolitaColor, forState: UIControlState.Normal)
            case .Followed:
                self.followedButton.setTitleColor(LolitaColor, forState: UIControlState.Normal)
            case .Debuts:
                self.debutsButton.setTitleColor(LolitaColor, forState: UIControlState.Normal)
            }
        }
    }
    
    func resetMenu() {
        self.popularButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.teamsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.animatedButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.followedButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.debutsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
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
        
        let URL = "\(DribbbleOauthURL)?client_id=\(DribbbleClientID)&redirect_uri=\(callbackURL)&scope=public+comment+write"
        
        safariViewController = SFSafariViewController(URL: NSURL(string:URL)!)
        
        self.presentViewController(safariViewController!, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = Defaults[.dribbbleToken] {
//            print(token)
            menuChannel = .Popular
            self.state = .Timeline
        } else {
            self.state = .Welcome
        }
        
        blurView = UIVisualEffectView(effect: darkBlur)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moveSelectedCellBack:", name: DribbleMoveSelectedCellBack, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "lolitaBecomeTimeline", name: LolitaToTimeLineNotification, object: nil)
        
        
        matchMenuOpen(false)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func lolitaBecomeTimeline() {
        
        if let safariViewController = safariViewController {
            safariViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        menuChannel = .Popular
        self.state = .Timeline
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
    
    
    @IBAction func popular(sender: AnyObject) {
        handleNewChannel(.Popular)
    }
    
    @IBAction func animated(sender: AnyObject) {
        handleNewChannel(.Animated)

    }
    
    @IBAction func debuts(sender: AnyObject) {
        handleNewChannel(.Debuts)
    }
    
    @IBAction func teams(sender: AnyObject) {
        handleNewChannel(.Teams)
    }
    
    @IBAction func followed(sender: AnyObject) {
        handleNewChannel(.Followed)
    }
    
    
    func handleNewChannel(channel: LolitaSelectChannel) {
        toggleMenu(self)
        
        if menuChannel != channel {
            shots = [DribbbleShot]()
            
            self.shotsCollectionView?.reloadData()
            
            menuChannel = channel
            currentPage = 0
            loadPage(currentPage)
        }
    }
    
    func animateOnLogo() {
        
        dispatch_async(dispatch_get_main_queue(),{
            SVProgressHUD.setBackgroundColor(UIColor.clearColor())
            SVProgressHUD.show()
        })
        
    }

}