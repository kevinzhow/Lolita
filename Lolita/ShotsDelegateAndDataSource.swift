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
import SVProgressHUD

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
                cell.shotImageView.kf_setImageWithURL(NSURL(string:normalImage )!, placeholderImage: nil, optionsInfo: [.Options([KingfisherOptions.BackgroundDecode])], completionHandler:nil)
            }
            
        }
        
        cell.shotDescriptionLabel.text = shot.title
        
        cell.authorLabel.text = "by \(shot.user.username)"
        cell.shotTimeLabel.text = shot.created_at.timeAgoSinceNow()
        cell.avatarImageView.kf_setImageWithURL(NSURL(string:shot.user.avatar_url)!, placeholderImage: nil, optionsInfo: [.Options([KingfisherOptions.BackgroundDecode])], completionHandler: { (image, error, cacheType, imageURL) -> () in
        })
        
        return cell
    }
    
    func configCellWithShot(cell: ShotCell, shot: DribbbleShot) {
        
        var filePath: String?
        
        if let hidpi = shot.images["hidpi"] as? String  {
            filePath = hidpi
        } else {
            if let normal = shot.images["normal"] as? String {
                filePath = normal
            }
            print("need fallback")
        }
        
        if let filePath = filePath {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                var image: OLImage?
                
                if let data = findImageDataWithURL(filePath, shotID: shot.id) {
                    
                    let animatedImage = OLImage(data:data)
                    image = animatedImage
                    
                } else {
                    
                    if let _ = DribbbleShotDownloading[shot.id] {
                        return
                    }
                    
                    DribbbleShotDownloading[shot.id] = true
                    
                    let data = NSData(contentsOfURL: NSURL(string:filePath)!)
                    
                    print(filePath)
                    
                    let animatedImage = OLImage(data:data!)
                    
                    image = animatedImage
                    
                    saveImageDataWithURL(data!, URL: filePath, shotID: shot.id)
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
        
        let distanceFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y

        if distanceFromBottom < view.frame.height*5 {
            loadPage(currentPage + 1)
        }
        
        if MenuOpen {
            return
        }
        
        handleTopBarView(scrollView)
        
        handleTopViewBlurViewExisit(scrollView)

    }
    
    func handleTopViewBlurViewExisit(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -40 {
            addBlurViewOnTopView()
        } else {
            if let blurView = blurView {

                blurEffectAdded = false
                blurView.removeFromSuperview()
                blurView.alpha = 1.0
            }
            
        }
    }
    
    func addBlurViewOnTopView() {
        if !blurEffectAdded {
            blurEffectAdded = true
            
            if let blurView = blurView {

                blurView.frame = blurViewContainer.bounds
                blurViewContainer.addSubview(blurView)
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
                if menuButtomTop.constant >= -2 {
                    menuButtomTop.constant -= 0.5
                }
            }
            
        }
        
        if topBarViewHeight.constant < 58 {
            
            if velocity.y > 0 || !scrollUp{
                scrollUp = false
                
                if scrollView.contentOffset.y < 300 {
                    topBarViewHeight.constant += 1
                    if menuButtomTop.constant <= 11 {
                        menuButtomTop.constant += 0.5
                    }
                }
                
            }
        }
        
        view.layoutIfNeeded()
        
        if let blurView = blurView {
            blurView.frame = blurViewContainer.bounds
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if MenuOpen {
            return
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ShotCell
        
        selectedCell = cell
        
        cell.removeFromSuperview()
        
        cell.originFrame = cell.frame
        
        print(cell.frame)
        
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
    
    func moveSelectedCellBack(notification: NSNotification) {
        if let selectedCell = selectedCell, originFrame = selectedCell.originFrame, top = notification.object as? Bool{
            
            selectedCell.removeFromSuperview()
            
            print(selectedCell.originFrame)

            shotsCollectionView?.addSubview(selectedCell)
            
            let tapPointInView = view.convertPoint(CGPointMake(selectedCell.frame.origin.x, selectedCell.frame.origin.y), toView: shotsCollectionView)
            
            let newFrame = CGRect(x: tapPointInView.x, y: tapPointInView.y, width: selectedCell.frame.width, height: selectedCell.frame.height)
            
            selectedCell.frame = newFrame
            
            if top {
                selectedCell.handleCardChange(Double(ShotMaxDegree))
            } else {
                selectedCell.handleCardChange(-Double(ShotMaxDegree))
            }

            
            UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: {
                
                selectedCell.frame = originFrame
                selectedCell.state = .Card
                selectedCell.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    
    func loadPage(page: Int) {
        
        if loadingNewPage {
            return
        }
        
        animateOnLogo()
        
        self.loadingNewPage = true
        
        let productCount = self.shots.count
        
        if let menuChannel = menuChannel {
        
            if menuChannel != .Followed {
                shotsByListType(menuChannel, page: page) { (shots) -> Void in
                    self.handleNewShots(shots, page: page, productCount: productCount)
                }
            } else {
                followedShots(page, complete: { (shots) -> Void in
                    self.handleNewShots(shots, page: page, productCount: productCount)
                })
            }
            
        }

    }
    
    func handleNewShots(shots: [DribbbleShot]?, page: Int, productCount: Int) {
        
        dispatch_async(dispatch_get_main_queue(),{
            SVProgressHUD.dismiss()
            
            delay(1.0, work: { () -> Void in
                SVProgressHUD.setBackgroundColor(UIColor.whiteColor())
            })
        })
        
        
        if let shots = shots {
            
            self.shots.appendContentsOf(shots)
            
            if self.shots.count > productCount {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let totalInsert = self.shots.count - productCount
                    
                    var indexPaths = [NSIndexPath]()
                    
                    for i in 0...(totalInsert-1) {
                        
                        let row = productCount + i
                        
                        let indexPath = NSIndexPath(forRow: row, inSection: 0)
                        
                        indexPaths.append(indexPath)
                    }
                    
                    print(indexPaths.count)
                    
                    self.shotsCollectionView?.insertItemsAtIndexPaths(indexPaths)
                    self.loadingNewPage = false
                    self.currentPage += 1
                })
            } else {
                self.loadingNewPage = false
            }
            
            
        } else {
            self.loadingNewPage = false
        }
    }
}
