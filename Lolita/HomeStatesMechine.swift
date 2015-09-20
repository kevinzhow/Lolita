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
        
        appLogoImage.hidden = false
        
        logoImageCenterY.constant = -(view.frame.height/CGFloat(2.0)) + 30.0
        
        labelImage.hidden = true
        
        signInButton.hidden = true
        
        footerMessageLabel.hidden = true
        
        logoImage.hidden = true
        
        menuButton.hidden = false
        
        profileButton.hidden = false
        
        view.layoutIfNeeded()
        
        if let shotsCollectionView = shotsCollectionView {
            
            shotsCollectionView.hidden = false
            
        } else {
            shotsCollectionView = UICollectionView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height), collectionViewLayout: DribbbleFlowLayout())
            shotsCollectionView?.backgroundColor = UIColor.clearColor()
            
            shotsCollectionView?.registerNib(UINib(nibName: "ShotCell", bundle: nil), forCellWithReuseIdentifier: "ShotCell")
            
            shotsCollectionView?.dataSource = self
            
            shotsCollectionView?.delegate = self
            
            shotsCollectionView?.contentInset = UIEdgeInsets(top: ShotCollectionViewTopInset, left: 0, bottom: 30, right: 0)
            
            view.insertSubview(shotsCollectionView!, belowSubview: topBarView)
            
//            let tap = UITapGestureRecognizer(target: self, action: "userTapOnScrollView:")
            
//            shotsCollectionView?.addGestureRecognizer(tap)
            
        }
        
        loadPage(currentPage)
    }
    
    func becomeWelcome() {
        
        menuButton.hidden = true
        
        profileButton.hidden = true
        
        appLogoImage.hidden = true
        
        labelImage.hidden = false
        
        signInButton.hidden = false
        
        footerMessageLabel.hidden = false
        
        logoImage.hidden = false
        
        if let shotsCollectionView = shotsCollectionView {
            
            shotsCollectionView.hidden = true
            
        }
    }
}