//
//  ImageCollectionViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

let IMAGE_COLLECTION_CELL = "imageCollectionCell"

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var showImageView: UIImageView!
    @IBOutlet weak var showPM25Label: UILabel!
    @IBOutlet weak var showAddressLabel: UILabel!
    @IBOutlet weak var showSupportBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
