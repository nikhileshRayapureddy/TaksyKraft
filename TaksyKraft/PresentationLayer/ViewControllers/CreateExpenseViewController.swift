//
//  CreateExpenseViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
import Photos
class CreateExpenseViewController: BaseViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var txtFldAmount: UITextField!
    @IBOutlet weak var txtVwDesc: UITextView!
    @IBOutlet weak var btnExpenseImage: UIButton!
    @IBOutlet weak var btnNoReceipt: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vwUploadBg: UIView!
    @IBOutlet weak var constVwUploagImageBgHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constBtnAttachImageHeight: NSLayoutConstraint!
    @IBOutlet weak var constBtnExpenseImageHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAttachImage: UIButton!
    var imgBg = UIImageView()

    @IBOutlet weak var imgExpenseImageOverlay: UIImageView!
    var imageURL = ""
    var expenseBO = ReceiptBO()
    var isImageEditing = false
    var isEdited = false
    @IBOutlet weak var lblCharCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Create New Form",showBack: true, isRefresh: false)
        lblMobileNo.text = TaksyKraftUserDefaults.getUser().mobile
        lblName.text = TaksyKraftUserDefaults.getUser().name
        if expenseBO.expenseId != "" && isImageEditing == false
        {
            txtFldAmount.text = expenseBO.amount
            txtVwDesc.text = expenseBO.Description
            if expenseBO.image != "pzrUPuD8zqdWKaxD7cAfLjptKhNjag5XUckkk3ho.png"
            {
                imageURL = expenseBO.image
                let url = URL(string: IMAGE_BASE_URL + expenseBO.image)
                btnExpenseImage.kf.setImage(with: url, for: .normal, placeholder: #imageLiteral(resourceName: "Bill_Default"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
                btnExpenseImage.layer.cornerRadius = btnExpenseImage.frame.size.width/2
                btnExpenseImage.layer.masksToBounds = true
                
                constVwUploagImageBgHeight.constant = 75
                constBtnExpenseImageHeight.constant = 75
                constBtnAttachImageHeight.constant = 0
                btnAttachImage.isHidden = true
            }
            else
            {
                self.btnNoReceiptClicked(self.btnNoReceipt)
            }
            
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
 
    @IBAction func btnSubmitClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if txtFldAmount.text == ""
        {
           self.showAlertWith(title: "Alert!", message: "Please enter Amount.")
        }
        else if txtVwDesc.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Description.")
        }
        else if btnNoReceipt.isSelected == false && imageURL.count <= 0
        {
            self.showAlertWith(title: "Alert!", message: "Please upload expense image.")
        }
        else
        {
            if txtFldAmount.text != expenseBO.amount
            {
                isEdited = true
            }
            if txtVwDesc.text != expenseBO.Description
            {
                isEdited = true
            }
            if expenseBO.image == "pzrUPuD8zqdWKaxD7cAfLjptKhNjag5XUckkk3ho.png"
            {
                if imageURL != ""
                {
                    isEdited = true
                }
            }
            else
            {
                if expenseBO.image != imageURL
                {
                    isEdited = true
                }
            }
            
            if isEdited == true
            {
                app_delegate.showLoader(message: "Uploading...")
                let layer = ServiceLayer()
                layer.createOrUpdateExpenseWith(strID: expenseBO.expenseId, strAmt: txtFldAmount.text!, strDescription: txtVwDesc.text, strImage: self.imageURL, successMessage: { (response) in
                    DispatchQueue.main.async
                        {
                            app_delegate.removeloder()
                            let alert = UIAlertController(title: "Success!", message: "Expense Uploaded Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name("reloadExpense"), object: nil)
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }))
                            self.present(alert, animated: true, completion: nil)
                    }
                    
                }, failureMessage: { (failure) in
                    DispatchQueue.main.async
                        {
                            app_delegate.removeloder()
                            if EXP_TOKEN_ERR == failure as! String
                            {
                                self.logout()
                            }
                            else
                            {
                                let alert = UIAlertController(title: "Failure!", message: failure as? String, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                    }
                    
                })
            }
            else
            {
                self.showAlertWith(title: "Alert!", message: "Please edit before updating")
            }
        }
        
    }
    @IBAction func btnAttachImageClicked(_ sender: UIButton) {
        if self.imageURL != ""
        {
            if let img = self.btnExpenseImage.imageView?.image
            {
                let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
                //        vc.arrUrl = [chqBO.cheque_image]
                vc.isEdit = true
                vc.callBack = self
                vc.arrImages.removeAll()
                vc.arrImages.append(img)
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }
        else
        {
            let alert = UIAlertController(title: "Select an Image to Uplaod", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
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
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageData = self.compressImageSize(image: info[UIImagePickerControllerOriginalImage] as! UIImage, compressionQuality: 1.0)
        let imageSize: Int = imageData.count
        
        print("size of image in KB: %f ", Double(imageSize) / 1024.0)
        btnExpenseImage.layer.cornerRadius = btnExpenseImage.frame.size.width/2
        btnExpenseImage.layer.masksToBounds = true
        btnExpenseImage.setImage(UIImage(data: imageData), for: .normal)
        constVwUploagImageBgHeight.constant = 75
        constBtnExpenseImageHeight.constant = 75
        constBtnAttachImageHeight.constant = 0
        btnAttachImage.isHidden = true
        isImageEditing = true
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                app_delegate.showLoader(message: "Uploading Image...")
                let layer = ServiceLayer()
                layer.uploadWith(imageData: imageData, successMessage: { (response) in
                    DispatchQueue.main.async
                        {
                            self.imageURL = response as! String
                            app_delegate.removeloder()
                            self.imgExpenseImageOverlay.image = #imageLiteral(resourceName: "ImageUploadSuccess")
                            self.imgExpenseImageOverlay.isHidden = false
                    }
                    
                }) { (failure) in
                    DispatchQueue.main.async
                        {
                            if EXP_TOKEN_ERR == failure as! String
                            {
                                self.logout()
                            }
                            else
                            {
                                app_delegate.removeloder()
                                self.showAlertWith(title: "Alert!", message: "Uploading failed.")
                            }
                    }
                    
                }
            }
        }

    }
    func compressImageSize(image: UIImage,compressionQuality : CGFloat) -> Data
    {
        var imageData = Data()
        imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))!
        print("compressImageSize in KB: %f ", Double(imageData.count) / 1024.0)

        if imageData.count > 2097152 {
           return self.compressImageSize(image: image, compressionQuality: compressionQuality - 0.1)
        }
        return imageData
    }

    @IBAction func btnNoReceiptClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            constVwUploagImageBgHeight.constant = 0
            vwUploadBg.isHidden = true
            self.imageURL = ""
        }
        else
        {
            if btnExpenseImage.imageView?.image == nil
            {
                constVwUploagImageBgHeight.constant = 40
                constBtnExpenseImageHeight.constant = 40
                constBtnAttachImageHeight.constant = 40
                btnAttachImage.isHidden = false
            }
            else
            {
                constVwUploagImageBgHeight.constant = 100
                constBtnExpenseImageHeight.constant = 75
                constBtnAttachImageHeight.constant = 0
                btnAttachImage.isHidden = true
            }
            vwUploadBg.isHidden = false
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension CreateExpenseViewController : UITextViewDelegate
{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let strText = textView.text + text
        
        if (strText.count) <= TXTVW_MAX_COUNT
        {
            lblCharCount.text = "\(strText.count - range.length)/\(TXTVW_MAX_COUNT)"
            return true
        }
        else
        {
            return false
        }
    }

}
extension CreateExpenseViewController : ImagePreviewViewControllerDelegate
{
    func reloadArrImagesWith(arrImages : [UIImage])
    {
        if arrImages.count > 0
        {
            self.btnExpenseImage.imageView?.image = arrImages[0]
        }
    }
}
extension  CreateExpenseViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 0 && string == "0" {
            
            return false
        }
        if ((textField.text!) + string).count > 7 {
            
            return false
        }
        if (textField.text?.contains("."))! && string == "." {
            
            return false
        }
        let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789.")
        let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
        if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
            return false
        }
        return true
    }

}

