//
//  HomeStatesMechine.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/19.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    
    func becomeTimeline() {
        
        logoImageCenterY.constant = -(view.frame.height/CGFloat(2.0)) + 30.0
        
        labelImage.hidden = true
        
        signInButton.hidden = true
        
        footerMessageLabel.hidden = true
        
        logoImage.hidden = true
        
        view.layoutIfNeeded()
        
        if let shotsCollectionView = shotsCollectionView {
            
            shotsCollectionView.hidden = false
            
        } else {
            shotsCollectionView = UICollectionView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height), collectionViewLayout: UICollectionViewFlowLayout())
            shotsCollectionView?.backgroundColor = UIColor.clearColor()
            
            shotsCollectionView?.registerNib(UINib(nibName: "ShotCell", bundle: nil), forCellWithReuseIdentifier: "ShotCell")
            
            shotsCollectionView?.dataSource = self
            
            shotsCollectionView?.delegate = self
            
            shotsCollectionView?.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0)
            
            view.insertSubview(shotsCollectionView!, belowSubview: topBarView)
        }
        
        shotsByListType(DribbbleListType.Default) { (shots) -> Void in
            if let shots = shots {
                self.shots = shots
                
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.shotsCollectionView!.reloadData()
                    
                })
            }
        }
    }
}