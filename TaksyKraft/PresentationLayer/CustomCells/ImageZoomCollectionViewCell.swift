//
//  ImageZoomCollectionViewCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 07/03/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class ImageZoomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var scrlVw: UIScrollView!
    var isZooming = false
    var originalImageCenter:CGPoint?
}
extension ImageZoomCollectionViewCell:UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return imgVw
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

    }
}

