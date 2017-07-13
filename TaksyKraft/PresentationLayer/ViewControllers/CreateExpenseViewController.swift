//
//  CreateExpenseViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
import Photos
class CreateExpenseViewController: BaseViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var txtFldAmount: FloatLabelTextField!
    @IBOutlet weak var txtVwDesc: FloatLabelTextView!
    @IBOutlet weak var lblImageName: UILabel!
    @IBOutlet weak var btnUploadImage: UIButton!
    @IBOutlet weak var btnNoReceipt: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vwUploadBg: UIView!
    @IBOutlet weak var constVwUploagImageBgHeight: NSLayoutConstraint!
    var imageData = Data()
    var fileName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        txtVwDesc.layer.cornerRadius = 5
        txtVwDesc.layer.masksToBounds = true
        txtVwDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtVwDesc.layer.borderWidth = 1
        vwUploadBg.layer.cornerRadius = 5
        vwUploadBg.layer.masksToBounds = true
        vwUploadBg.layer.borderColor = UIColor.lightGray.cgColor
        vwUploadBg.layer.borderWidth = 1
        self.designNavBarWithTitleAndBack(title: "Create New Form",showBack: true)
        lblMobileNo.text = TaksyKraftUserDefaults.getUserMobile()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func btnSubmitClicked(_ sender: UIButton) {
        if txtFldAmount.text == ""
        {
           self.showAlertWith(title: "Alert!", message: "Please enter Amount.")
        }
        else if txtVwDesc.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Description.")
        }
        else if imageData.count <= 0
        {
            self.showAlertWith(title: "Alert!", message: "Please Upload Receipt Image!")
        }
        else
        {
            app_delegate.showLoader(message: "Uploading...")
            let layer = ServiceLayer()
            layer.uploadWith(data: self.imageData, desc: self.fileName, mobileNo: lblMobileNo.text!, amount: txtFldAmount.text!, fileName: self.fileName, contentType: "image/jpg", successMessage: { (response) in
                app_delegate.removeloder()
                let alert = UIAlertController(title: "Success!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                        let _=self.navigationController?.popViewController(animated: true)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                

                
            }, failureMessage: { (failure) in
                app_delegate.removeloder()
                
            })
        }
    }
    @IBAction func btnUploadImageClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select an Image to Uplaod", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
            // perhaps use action.title here
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("camera not available.")
            }

        })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { action in
            // perhaps use action.title here
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("photoLibrary not available.")
            }

        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            // perhaps use action.title here
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage] as! UIImage, 0.7)!
        let url = info[UIImagePickerControllerReferenceURL] as! URL
        let assets = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
        fileName = PHAssetResource.assetResources(for: assets.firstObject!).first!.originalFilename
        lblImageName.text = fileName
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnNoReceiptClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            constVwUploagImageBgHeight.constant = 0
            vwUploadBg.isHidden = true
            imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "no_receipt"), 0.7)!
            fileName = "no_receipt.jpg"
            lblImageName.text = fileName

        }
        else
        {
            constVwUploagImageBgHeight.constant = 40
            vwUploadBg.isHidden = false
        }
    }
}
