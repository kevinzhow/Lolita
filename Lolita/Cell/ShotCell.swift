//
//  ShotCell.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/20.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import UIKit
import OLImageView

class ShotCell: UICollectionViewCell {
    
    enum ShotCellState: Int {
        case Card = 0
        case Detail
    }
    
    var state: ShotCellState! {
        didSet {
            switch self.state! {
            case .Card:
                configCard()
            case .Detail:
                configDetail()
            }
        }
    }
    
    @IBOutlet weak var shotDetailsWebView: UIWebView!
    
    
    @IBOutlet weak var shotDetailFooter: UIView!
    
    let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var bottomBarBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomBarContainerView: UIView!
    @IBOutlet weak var shotContainerTop: NSLayoutConstraint!
    @IBOutlet weak var shotContainerTrailing: NSLayoutConstraint!
    @IBOutlet weak var shotContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var shotContainerLeading: NSLayoutConstraint!
    
    @IBOutlet weak var shotContainerView: UIView!
    
    @IBOutlet weak var shotImageView: OLImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var shotDescriptionLabel: UILabel!
    
    @IBOutlet weak var shotTimeLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var originFrame: CGRect?
    
    var windowFrame: CGRect?
    
    var shot: DribbbleShot?
    
    var blurView : UIVisualEffectView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bottomBar.hidden = true
        shotImageView.runLoopMode = NSRunLoopCommonModes
        shotContainerView.layer.cornerRadius = 8
        shotContainerView.layer.masksToBounds = true
        shotImageView.clipsToBounds = true
        
        shotDetailsWebView.scrollView.contentInset = UIEdgeInsets(top: 320, left: 0, bottom: 50, right: 0)
        shotDetailsWebView.userInteractionEnabled = false
        blurView = UIVisualEffectView(effect: darkBlur)
        // Initialization code
    }
    
    func prepareShotWebView() {
        if let shot = shot {
            
            let mainHTML = NSBundle.mainBundle().URLForResource("Shot", withExtension:"html")
            
            do {
                var contents = try NSString(contentsOfFile: mainHTML!.path!, encoding: NSUTF8StringEncoding)
                
                if let description = shot.description {
                    contents = contents.stringByReplacingOccurrencesOfString("#ShotDescription", withString: description)
                } else {
                    contents = contents.stringByReplacingOccurrencesOfString("#ShotDescription", withString: "")
                }
                
                shotDetailsWebView.loadHTMLString(contents as String, baseURL: nil)
                
                commentsByShotID(shot.id, complete: { (comments) -> Void in
                    
                    if let comments = comments {
                        
                        let commnetHTML = NSBundle.mainBundle().URLForResource("ShotComment", withExtension:"html")
                        
                        do {
                            let commentContent = try NSString(contentsOfFile: commnetHTML!.path!, encoding: NSUTF8StringEncoding)
                            
                            var commentsContent = ""
                            
                            for comment in comments {
                                
                                var newContent = commentContent.stringByReplacingOccurrencesOfString("#ShotUserAvatar", withString: comment.user.avatar_url)
                                
                                newContent = newContent.stringByReplacingOccurrencesOfString("#ShotUserName", withString: comment.user.name)
                                
                                newContent = newContent.stringByReplacingOccurrencesOfString("#ShotCommentContent", withString: comment.body)
                                
                                newContent = newContent.stringByReplacingOccurrencesOfString("#ShotCommentCreatedAt", withString: comment.created_at.timeAgoSinceNow())
                                
                                print(newContent)
                                
                                commentsContent += newContent as String
                            }
                            
                            contents = contents.stringByReplacingOccurrencesOfString("#ShotComments", withString: commentsContent)
                            
                            self.shotDetailsWebView.loadHTMLString(contents as String, baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
                            
                        } catch let error as NSError {
                            print(error.description)
                        }
                    }
                })
                
                
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    func configCard() {
        shotContainerTop.constant = 15
        shotContainerTrailing.constant = 15
        shotContainerBottom.constant = 15
        shotContainerLeading.constant = 15
        shotContainerView.layer.cornerRadius = 8
        shotDetailsWebView.userInteractionEnabled = false
        
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = 0
        animation.duration = 0.5
        animation.toValue = 8
        animation.repeatCount = 0
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false

        shotContainerView.layer.addAnimation(animation, forKey: "cornerRadius")
        
        bottomBar.removeFromSuperview()
    }
    
    func configDetail() {
        shotContainerTop.constant = 0
        shotContainerTrailing.constant = 0
        shotContainerBottom.constant = 0
        shotContainerLeading.constant = 0
        shotDetailsWebView.userInteractionEnabled = true
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = 8
        animation.duration = 0.5
        animation.toValue = 0
        animation.repeatCount = 0
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        shotContainerView.layer.addAnimation(animation, forKey: "cornerRadius")
        
        if windowFrame?.origin.y > 300 {
            handleCardChangeAnimation(-15)
        } else {
            handleCardChangeAnimation(5)
        }
        blurView!.frame = bottomBar.bounds
        bottomBar.insertSubview(blurView!, aboveSubview: bottomBarContainerView)
        bottomBar.hidden = false
        prepareShotWebView()
        
        delay(0.8) { () -> Void in
            UIView.animateWithDuration(0.5) { () -> Void in
                self.bottomBarBottom.constant = 0
                self.blurView!.frame = self.bottomBar.bounds
                self.layoutIfNeeded()
            }
        }
        
    }
    
    func handleCardChangeAnimation(from: Double) {
        let layer = shotContainerView.layer
        
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -500
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(from * M_PI / 180.0), 1.0, 0.0, 0.0)
        
        var rotationAndPerspectiveTransform2 = CATransform3DIdentity
        rotationAndPerspectiveTransform2.m34 = 1.0 / -500
        rotationAndPerspectiveTransform2 = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(0.0 * M_PI / 180.0), 1.0, 0.0, 0.0)
        let transformAnim = CAKeyframeAnimation(
            keyPath:"transform")
        
        transformAnim.values  = [
            NSValue(CATransform3D: CATransform3DIdentity) ,
            NSValue(CATransform3D: rotationAndPerspectiveTransform) ,
            NSValue(CATransform3D: rotationAndPerspectiveTransform2) ,
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.33, 0.5, 1]
        transformAnim.duration = 0.8
        transformAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transformAnim.removedOnCompletion = false
        transformAnim.fillMode = kCAFillModeForwards
        
        layer.addAnimation(transformAnim,
            forKey: "transform")
        
    }

}
