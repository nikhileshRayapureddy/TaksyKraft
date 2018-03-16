//
//  ImagePreviewViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 12/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit
protocol ImagePreviewViewControllerDelegate
{
    func reloadArrImagesWith(arrImages : [UIImage])
}

class ImagePreviewViewController: BaseViewController {
    @IBOutlet weak var lblPageNumber: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var clVwImages: UICollectionView!
    @IBOutlet weak var constBtnDeleteHeight: NSLayoutConstraint!
    var arrUrl = [String]()
    var arrImages = [UIImage]()
    var isEdit = false
    var callBack : ImagePreviewViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        clVwImages.translatesAutoresizingMaskIntoConstraints = false
        clVwImages.isPagingEnabled = true
        if isEdit
        {
            lblPageNumber.text = "1/\(arrImages.count)"
            constBtnDeleteHeight.constant = 40
            btnDelete.isHidden = false
        }
        else
        {
            constBtnDeleteHeight.constant = 0
            btnDelete.isHidden = true

            for _ in 0..<self.arrUrl.count
            {
                self.arrImages.append(UIImage())
            }

            lblPageNumber.text = "1/\(arrUrl.count)"
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }

    @IBAction func btnBackClicked(_ sender: UIButton) {
        if isEdit
        {
            if callBack != nil
            {
                callBack.reloadArrImagesWith(arrImages: arrImages)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDeleteClicked(_ sender: UIButton) {
        if isEdit
        {
            let page = Int(clVwImages.contentOffset.x/(ScreenWidth-16))
            arrImages.remove(at: page)
            if arrImages.count > 0
            {
                self.clVwImages.reloadData()
                clVwImages.performBatchUpdates({
                }, completion: { (finished) in
                    DispatchQueue.main.async {
                        self.lblPageNumber.text = "\(Int(self.clVwImages.contentOffset.x/(ScreenWidth-16))+1)/\(self.arrImages.count)"
                    }
                })
            }
            else
            {
                self.btnBackClicked(UIButton())
            }
        }
    }
    
}
extension ImagePreviewViewController:UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageZoomCollectionViewCell", for: indexPath) as! ImageZoomCollectionViewCell
        cell.imgVw.translatesAutoresizingMaskIntoConstraints = false
        cell.imgVw.contentMode = .scaleAspectFit
        if isEdit == false{
            let url = URL(string: IMAGE_BASE_URL + arrUrl[indexPath.row])
            cell.imgVw.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "Loading"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
            }, completionHandler: { image, error, cacheType, imageURL in
                if image != nil
                {
                    self.arrImages.insert(image!, at: indexPath.row)
                }
            })
        }
        else
        {
            cell.imgVw.image = arrImages[indexPath.row]
        }
        cell.scrlVw.minimumZoomScale = 1.0
        cell.scrlVw.maximumZoomScale = 3.0
        cell.scrlVw.bouncesZoom = true
        cell.scrlVw.clipsToBounds = true
        cell.scrlVw.backgroundColor = UIColor.clear
        cell.scrlVw.showsVerticalScrollIndicator = false
        cell.scrlVw.showsHorizontalScrollIndicator = false
        cell.scrlVw.contentSize = CGSize(width: cell.frame.size.width, height: cell.frame.size.width)
        cell.scrlVw.zoomScale = 1
        
        cell.imgVw.layer.cornerRadius = 11.0
        cell.imgVw.backgroundColor = UIColor.clear
        cell.imgVw.clipsToBounds = true
        cell.imgVw.contentMode = .scaleAspectFit
        cell.imgVw.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        cell.imgVw.clipsToBounds = false
        cell.imgVw.center = cell.scrlVw.center
        
        return cell
    }
    
    
}
extension ImagePreviewViewController:UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == clVwImages
        {
            if isEdit
            {
                lblPageNumber.text = "\(Int(clVwImages.contentOffset.x/(ScreenWidth-16))+1)/\(arrImages.count)"
            }
            else
            {
                lblPageNumber.text = "\(Int(clVwImages.contentOffset.x/(ScreenWidth-16))+1)/\(arrUrl.count)"
            }
        }
        

    }
}




