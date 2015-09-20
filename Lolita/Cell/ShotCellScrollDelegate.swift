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
            
            var bottomBounceValue = -scrollView.contentOffset.y - 340
            bottomBounceValue = bottomBounceValue/10.0
            
//            print(bottomBounceValue)
            
            if bottomBounceValue <= ShotMaxDegree && bottomBounceValue >= 0 {
                self.handleCardChange(Double(bottomBounceValue))
            } else {
                
                if bottomBounceValue > ShotMaxDegree {
                    
                    handleCardChange(Double(ShotMaxDegree))
                    
                    if bottomBounceValue > ShotMaxDegree {
                        NSNotificationCenter.defaultCenter().postNotificationName(DribbleMoveSelectedCellBack, object: true)
                        self.pageLoaded = false
                    }
                    
                } else {
                    ResetCardChange()
                }
                
            }
            
            
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
            bottomBounceValue = bottomBounceValue/13.0
            
//            print(bottomBounceValue)
            
            if bottomBounceValue <= ShotMaxDegree && bottomBounceValue >= 0 {
                self.handleCardChange(Double(-bottomBounceValue))
            } else {
                
                if bottomBounceValue > ShotMaxDegree {
                    
                    handleCardChange(-Double(ShotMaxDegree))
                    
                    if bottomBounceValue > ShotMaxDegree + 2 && velocity.y > -100{

                        NSNotificationCenter.defaultCenter().postNotificationName(DribbleMoveSelectedCellBack, object: false)
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