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

    @IBOutlet weak var shotContainerView: UIView!
    
    @IBOutlet weak var shotImageView: OLImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var shotDescriptionLabel: UILabel!
    
    @IBOutlet weak var shotTimeLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var shot: DribbbleShot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shotImageView.runLoopMode = NSRunLoopCommonModes
        shotContainerView.layer.cornerRadius = 8
        shotContainerView.layer.masksToBounds = true
        // Initialization code
    }

}
