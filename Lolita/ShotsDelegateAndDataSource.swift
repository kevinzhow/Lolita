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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        
        cell.shotDescriptionLabel.text = "\(shot.title) by \(shot.user.username)"
        cell.shotTimeLabel.text = shot.created_at.description
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
    
}
