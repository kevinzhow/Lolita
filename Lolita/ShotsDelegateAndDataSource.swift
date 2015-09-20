//
//  ShotsDelegateAndDataSource.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/20.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import UIKit
import Kingfisher
import OLImageView
import Alamofire
import DateTools

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func userTapOnScrollView(gesture: UITapGestureRecognizer) {
//        let tapPoint = gesture.locationInView(shotsCollectionView)
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShotCell", forIndexPath: indexPath) as! ShotCell
        
        let shot = shots[indexPath.row]
        
        cell.shot = shot
        
        cell.shotImageView.image = nil
        
        if let normalImage = shot.images["normal"] as? String {
            
            if shot.animated {
                configCellWithShot(cell, shot: shot)
            } else {
                cell.shotImageView.kf_setImageWithURL(NSURL(string:normalImage )!, placeholderImage: nil, optionsInfo: [.Options: KingfisherOptions.BackgroundDecode], completionHandler:nil)
            }
            
        }
        
        cell.shotDescriptionLabel.text = shot.title
        
        cell.authorLabel.text = "by \(shot.user.username)"
        cell.shotTimeLabel.text = shot.created_at.timeAgoSinceNow()
        cell.avatarImageView.kf_setImageWithURL(NSURL(string:shot.user.avatar_url)!, placeholderImage: nil, optionsInfo: [.Options: KingfisherOptions.BackgroundDecode], completionHandler: { (image, error, cacheType, imageURL) -> () in
        })
        
        return cell
    }
    
    func configCellWithShot(cell: ShotCell, shot: DribbbleShot) {
        if let hidpi = shot.images["hidpi"] as? String  {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                var image: OLImage?
                
                if let data = findImageDataWithURL(hidpi, shotID: shot.id) {
                    
                    let animatedImage = OLImage(data:data)
                    image = animatedImage
                    
                } else {
                    
                    let data =  NSData(contentsOfURL: NSURL(string:hidpi)!)
                    
                    let animatedImage = OLImage(data:data!)
                    
                    image = animatedImage
                    
                    saveImageDataWithURL(data!, URL: hidpi, shotID: shot.id)
                }
                

                // 主界面的头像
                if cell.shot?.id == shot.id {
                    cell.shotImageView.image = image
                } else {
                    print("Cell Skiped")
                }

            }
        }

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 338.0)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shots.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
//        print(scrollView.contentOffset.y)
        
        handleTopBarView(scrollView)
        
        if scrollView.contentOffset.y > -40 {
            if !blurEffectAdded {
                blurEffectAdded = true
                
                if let blurView = blurView {
                    blurView.frame = blurViewContainer.bounds
                    blurViewContainer.addSubview(blurView)
                }

            }
        } else {
            if let blurView = blurView {
                blurEffectAdded = false
                blurView.removeFromSuperview()
            }
            
        }
    }
    
    func handleTopBarView(scrollView: UIScrollView) {
        
//        print("Scroll \(scrollView.contentOffset.y) \(scrollView.tag)")
//        print("Header \(topBarViewHeight.constant)")
        
        let velocity = scrollView.panGestureRecognizer.velocityInView(self.view)
        
        if topBarViewHeight.constant > 30 {
        
            if velocity.y < 0 || scrollUp {
                scrollUp = true
                topBarViewHeight.constant -= 1
            }
            
        }
        
        if topBarViewHeight.constant < 58 {
            
            if velocity.y > 0 || !scrollUp{
                scrollUp = false
                
                if scrollView.contentOffset.y < 300 {
                    topBarViewHeight.constant += 1
                }
                
            }
        }
        
        view.layoutIfNeeded()
        
        if let blurView = blurView {
            blurView.frame = blurViewContainer.bounds
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ShotCell
        
        cell.removeFromSuperview()
        
        cell.originFrame = cell.frame
        
        let tapPointInView = shotsCollectionView?.convertPoint(CGPointMake(cell.frame.origin.x, cell.frame.origin.y), toView: view)
        
        let newFrame = CGRect(x: tapPointInView!.x, y: tapPointInView!.y, width: cell.frame.width, height: cell.frame.height)
        
        cell.frame = newFrame
        
        cell.windowFrame = newFrame
        
        view.addSubview(cell)
        
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: {
            
            cell.frame = self.view.frame
            cell.state = .Detail
            cell.layoutIfNeeded()
            
            
        }, completion: nil)
    }
    
}
