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
    
    @IBOutlet weak var authorLabel: UILabel!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shotImageView.runLoopMode = NSRunLoopCommonModes
        shotContainerView.layer.cornerRadius = 8
        shotContainerView.layer.masksToBounds = true
        // Initialization code
    }
    
    func configCard() {
        shotContainerTop.constant = 15
        shotContainerTrailing.constant = 15
        shotContainerBottom.constant = 15
        shotContainerLeading.constant = 15
        shotContainerView.layer.cornerRadius = 8
    }
    
    func configDetail() {
        shotContainerTop.constant = 0
        shotContainerTrailing.constant = 0
        shotContainerBottom.constant = 0
        shotContainerLeading.constant = 0

        let animation = CABasicAnimation(keyPath: "cornerRadius")
        
        // 设置动画初始值
        animation.fromValue = 8
        
        animation.duration = 0.5
        
        // 设置动画结束时候的值
        animation.toValue = 0
        
        // 动画重复多少次
        animation.repeatCount = 0
        
        animation.fillMode = kCAFillModeForwards
            
        animation.removedOnCompletion = false
        
        // 最后，将动画添加到 Layer 上
        shotContainerView.layer.addAnimation(animation, forKey: "cornerRadius")
        
    }

}
