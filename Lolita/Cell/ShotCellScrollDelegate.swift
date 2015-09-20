//
//  ShotCellScrollDelegate.swift
//  Lolita
//
//  Created by zhowkevin on 15/9/20.
//  Copyright © 2015年 zhowkevin. All rights reserved.
//

import UIKit

extension ShotCell : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let velocity = scrollView.panGestureRecognizer.velocityInView(self)
        
        if !self.pageLoaded  {
            return
        }
        
        //For Bounce
        
        if scrollView.contentOffset.y < -340{
            
            print(scrollView.contentOffset.y)
            
            if shotImageTop.constant < 0 {
                
                let newValue = shotImageTop.constant + 1
                
                if newValue <= 0 {
                    shotImageTop.constant = newValue
                } else {
                    shotImageTop.constant = 0
                }
            }
            return
        }
        
        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height {
            
            var bottomBounceValue = (scrollView.contentOffset.y + scrollView.frame.height) - scrollView.contentSize.height - 20
            bottomBounceValue = bottomBounceValue/10.0
            
            print(bottomBounceValue)
            
            if bottomBounceValue <= 10 && bottomBounceValue >= 0 {
                self.handleCardChange(Double(-bottomBounceValue))
            } else {
                
                if bottomBounceValue > 10 {
                    
                    handleCardChange(-10)
                    
                    if bottomBounceValue > 12 {
                        NSNotificationCenter.defaultCenter().postNotificationName(DribbleMoveSelectedCellBack, object: nil)
                        self.pageLoaded = false
                    }
                    
                } else {
                    ResetCardChange()
                }
                
            }
            return
        }
        //
        
        let newOffset = scrollView.contentOffset.y + 340
        
        if newOffset <= 270 {
            shotImageTop.constant = -newOffset
        } else {
            shotImageTop.constant = -270
        }
        

        layoutIfNeeded()
    }
}