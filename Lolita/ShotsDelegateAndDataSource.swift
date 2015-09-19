//
//  ShotsDelegateAndDataSource.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/20.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import UIKit
import Kingfisher

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShotCell", forIndexPath: indexPath) as! ShotCell
        let shot = shots[indexPath.row]
        
        if let normalImage = shot.images["normal"] as? String {
            
            cell.shotImageView.kf_setImageWithURL(NSURL(string:normalImage )!, placeholderImage: nil, optionsInfo: [.Options: KingfisherOptions.BackgroundDecode], completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
        }
        
        cell.shotDescriptionLabel.text = "\(shot.title) by \(shot.user.username)"
        cell.shotTimeLabel.text = shot.created_at.description
        cell.avatarImageView.kf_setImageWithURL(NSURL(string:shot.user.avatar_url)!, placeholderImage: nil, optionsInfo: [.Options: KingfisherOptions.BackgroundDecode], completionHandler: { (image, error, cacheType, imageURL) -> () in
        })
        
        return cell
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
        
        print(scrollView.contentOffset.y)
        
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
        
        print("Scroll \(scrollView.contentOffset.y) \(scrollView.tag)")
        print("Header \(topBarViewHeight.constant)")
        let velocity = scrollView.panGestureRecognizer.velocityInView(self.view)
        
        if topBarViewHeight.constant > 35 {
        
            if velocity.y < 0 || scrollUp {
                scrollUp = true
                topBarViewHeight.constant -= 1
            }
            
        }
        
        if topBarViewHeight.constant < 58 {
            
            if velocity.y > 0 || !scrollUp{
                scrollUp = false
                topBarViewHeight.constant += 1
            }
        }
        
        topBarView.layoutIfNeeded()
        view.setNeedsLayout()
        
        if let blurView = blurView {
            blurView.frame = blurViewContainer.bounds
        }
    }
    
}
