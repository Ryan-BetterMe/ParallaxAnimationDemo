//
//  MyCollectionViewCell.swift
//  ParallaxAnimation
//
//  Created by 向辉 on 2018/3/26.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var imageOffset: CGPoint = CGPoint.init(x: 0.0, y: 0.0) {
        didSet {
            let frame = self.imageView.bounds
            // 返回一个同样size的rect，但是origin却经过偏移
            let offsetFrame = frame.offsetBy(dx: imageOffset.x, dy: imageOffset.y)
            print("offsetFrame.origin： \(offsetFrame.origin)")
            self.imageView.frame = offsetFrame
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
