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
    @IBOutlet weak var txtFldAmount: FloatLabelTextField!
    @IBOutlet weak var txtVwDesc: FloatLabelTextView!
    @IBOutlet weak var lblImageName: UILabel!
    @IBOutlet weak var btnUploadImage: UIButton!
    @IBOutlet weak var btnNoReceipt: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vwUploadBg: UIView!
    @IBOutlet weak var constVwUploagImageBgHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnWalletAmt: UIButton!
    @IBOutlet weak var btnCard: UIButton!
    var imgBg = UIImageView()

    var imageData = Data()
    var fileName = ""
    var arrTitles = [String]()
    var isFromEdit = false
    var isImageModified = false

    var receiptBO = ReceiptBO()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtVwDesc.layer.cornerRadius = 5
        txtVwDesc.layer.masksToBounds = true
        txtVwDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtVwDesc.layer.borderWidth = 1
        vwUploadBg.layer.cornerRadius = 5
        vwUploadBg.layer.masksToBounds = true
        vwUploadBg.layer.borderColor = UIColor.lightGray.cgColor
        vwUploadBg.layer.borderWidth = 1
        if isFromEdit
        {
            self.designNavBarWithTitleAndBack(title: "Create New Form",showBack: true, isMenu: false)
            txtFldAmount.text = receiptBO.amount
            txtVwDesc.text = receiptBO.Description
            fileName = receiptBO.image
            lblImageName.text = fileName
            do {
                imageData = try Data(contentsOf: URL(string:IMAGE_BASE_URL + receiptBO.image)!)
            } catch {
                print("Invalid URL")
            }
            
        }
        else
        {
            if TaksyKraftUserDefaults.getUserRole() == "1" || TaksyKraftUserDefaults.getUserRole() == "2"
            {
                self.designNavBarWithTitleAndBack(title: "Create New Form",showBack: true, isMenu: false)
            }
            else
            {
                self.designNavBarWithTitleAndBack(title: "Create New Form",showBack: false, isMenu: true)
                arrTitles = ["My Expenses","Logout"]
            }
        }
        lblMobileNo.text = TaksyKraftUserDefaults.getUserMobile()
        lblName.text = TaksyKraftUserDefaults.getUserName()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func btnMenuClicked( sender:UIButton)
    {
        self.showPopOver(arrTitles: arrTitles, sender: sender ,tag:500)
    }
    func showPopOver(arrTitles : [String] ,sender : UIView ,tag : Int)  {
        imgBg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        imgBg.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(imgBg)
        
        let popoverVC = CustomPopOver()
        popoverVC.tag = tag
        popoverVC.modalPresentationStyle = .popover
        popoverVC.titles = arrTitles
        popoverVC.preferredContentSize = CGSize (width: 150, height: CGFloat(popoverVC.titles.count) * 45.0)
        popoverVC.delegate = self
        
        if let popoverController = popoverVC.popoverPresentationController
        {
            popoverController.sourceView = sender
            let bound = sender.bounds
            popoverController.sourceRect = bound
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
        }
        
        self.present(popoverVC, animated: true, completion: nil)
        
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController)
    {
        imgBg.removeFromSuperview()
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .none
    }
    

    @IBAction func btnWalletAmtClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnCardClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        else if imageData.count <= 0
        {
            self.showAlertWith(title: "Alert!", message: "Please Upload Receipt Image!")
        }
        else
        {
            app_delegate.showLoader(message: "Uploading...")
            let layer = ServiceLayer()
            
            layer.uploadWith(imageData: self.imageData, successMessage: { (response) in
                DispatchQueue.main.async
                    {
                        let alert = UIAlertController(title: "Success!", message: "Image uploaded successfully", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                }
            }, failureMessage: { (error) in
                DispatchQueue.main.async
                    {
                        let alert = UIAlertController(title: "Success!", message: "Image uploading failed.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                }

            })
            return
            let card = btnCard.isSelected == true ? "1" : "0"
            let wallet = btnWalletAmt.isSelected == true ? "1" : "0"
            if isFromEdit
            {
                if isImageModified
                {
                    layer.uploadEditedDetailsWith(imageData: self.imageData, card: card, wallet: wallet, desc: txtVwDesc.text, mobileNo: lblMobileNo.text!, amount: txtFldAmount.text!, fileName: self.fileName, contentType: "image/jpg", expenseID: String(receiptBO.receiptId), successMessage: { (response) in
                        layer.getWalletAmount(successMessage: { (bal) in
                            DispatchQueue.main.async
                                {
                                    TaksyKraftUserDefaults.setWalletAmount(object: "₹ \(bal as! String)")
                                    app_delegate.removeloder()
                                    let alert = UIAlertController(title: "Success!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                        DispatchQueue.main.async {
                                            self.reloadWallet()
                                            if TaksyKraftUserDefaults.getUserRole() == "0"
                                            {
                                                self.txtVwDesc.text = ""
                                                self.txtFldAmount.text = ""
                                                self.imageData = Data()
                                                self.fileName = ""
                                                self.lblImageName.text = ""
                                                self.btnCard.isSelected = false
                                                self.btnWalletAmt.isSelected = false
                                                self.btnNoReceipt.isSelected = true
                                                self.btnNoReceiptClicked(self.btnNoReceipt)
                                            }
                                            else
                                            {
                                                let _=self.navigationController?.popViewController(animated: true)
                                            }
                                        }
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                            }
                        }) { (error) in
                            DispatchQueue.main.async
                                {
                                    TaksyKraftUserDefaults.setWalletAmount(object: "₹ 0")
                                    app_delegate.removeloder()
                                    let alert = UIAlertController(title: "Success!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                        DispatchQueue.main.async {
                                            self.reloadWallet()
                                            if TaksyKraftUserDefaults.getUserRole() == "0"
                                            {
                                                self.txtVwDesc.text = ""
                                                self.txtFldAmount.text = ""
                                                self.imageData = Data()
                                                self.fileName = ""
                                                self.lblImageName.text = ""
                                                self.btnCard.isSelected = false
                                                self.btnWalletAmt.isSelected = false
                                                self.btnNoReceipt.isSelected = true
                                                self.btnNoReceiptClicked(self.btnNoReceipt)
                                            }
                                            else
                                            {
                                                let _=self.navigationController?.popViewController(animated: true)
                                            }
                                        }
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                    }, failureMessage: { (failure) in
                        app_delegate.removeloder()
                        
                    })
                }
                else
                {
                    layer.uploadEditedDetailsWith(imageData: Data(), card: card, wallet: wallet, desc: txtVwDesc.text, mobileNo: lblMobileNo.text!, amount: txtFldAmount.text!, fileName: self.fileName, contentType: "image/jpg", expenseID: String(receiptBO.receiptId), successMessage: { (response) in
                        layer.getWalletAmount(successMessage: { (bal) in
                            DispatchQueue.main.async
                                {
                                    TaksyKraftUserDefaults.setWalletAmount(object: "₹ \(bal as! String)")
                                    app_delegate.removeloder()
                                        let alert = UIAlertController(title: "Success!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                            DispatchQueue.main.async {
                                                self.reloadWallet()
                                                if TaksyKraftUserDefaults.getUserRole() == "0"
                                                {
                                                    self.txtVwDesc.text = ""
                                                    self.txtFldAmount.text = ""
                                                    self.imageData = Data()
                                                    self.fileName = ""
                                                    self.lblImageName.text = ""
                                                    self.btnCard.isSelected = false
                                                    self.btnWalletAmt.isSelected = false
                                                    self.btnNoReceipt.isSelected = true
                                                    self.btnNoReceiptClicked(self.btnNoReceipt)
                                                }
                                                else
                                                {
                                                    let _=self.navigationController?.popViewController(animated: true)
                                                }
                                            }
                                        }))
                                        self.present(alert, animated: true, completion: nil)
                                    
                            }
                        }) { (error) in
                            DispatchQueue.main.async
                                {
                                    TaksyKraftUserDefaults.setWalletAmount(object: "₹ 0")
                                    app_delegate.removeloder()
                                        let alert = UIAlertController(title: "Success!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                            DispatchQueue.main.async {
                                                self.reloadWallet()
                                                if TaksyKraftUserDefaults.getUserRole() == "0"
                                                {
                                                    self.txtVwDesc.text = ""
                                                    self.txtFldAmount.text = ""
                                                    self.imageData = Data()
                                                    self.fileName = ""
                                                    self.lblImageName.text = ""
                                                    self.btnCard.isSelected = false
                                                    self.btnWalletAmt.isSelected = false
                                                    self.btnNoReceipt.isSelected = true
                                                    self.btnNoReceiptClicked(self.btnNoReceipt)
                                                }
                                                else
                                                {
                                                    let _=self.navigationController?.popViewController(animated: true)
                                                }
                                            }
                                        }))
                                        self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }, failureMessage: { (failure) in
                        app_delegate.removeloder()
                        
                    })

                }
            }
            else
            {
                layer.uploadWith(imageData: self.imageData, desc: txtVwDesc.text, mobileNo: lblMobileNo.text!, card: card, wallet: wallet, amount: txtFldAmount.text!, fileName: self.fileName, contentType: "image/jpg", successMessage: { (response) in
                    layer.getWalletAmount(successMessage: { (bal) in
                        DispatchQueue.main.async
                            {
                                TaksyKraftUserDefaults.setWalletAmount(object: "₹ \(bal as! String)")
                                app_delegate.removeloder()
                                let alert = UIAlertController(title: "Success!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                    DispatchQueue.main.async {
                                        self.reloadWallet()
                                        if TaksyKraftUserDefaults.getUserRole() == "0"
                                        {
                                            self.txtVwDesc.text = ""
                                            self.txtFldAmount.text = ""
                                            self.imageData = Data()
                                            self.fileName = ""
                                            self.lblImageName.text = ""
                                            self.btnCard.isSelected = false
                                            self.btnWalletAmt.isSelected = false
                                            self.btnNoReceipt.isSelected = true
                                            self.btnNoReceiptClicked(self.btnNoReceipt)
                                        }
                                        else
                                        {
                                            let _=self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }))
                                self.present(alert, animated: true, completion: nil)
                        }
                    }) { (error) in
                        DispatchQueue.main.async
                            {
                                TaksyKraftUserDefaults.setWalletAmount(object: "₹ 0")
                                app_delegate.removeloder()
                                let alert = UIAlertController(title: "Success!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                    DispatchQueue.main.async {
                                        self.reloadWallet()
                                        if TaksyKraftUserDefaults.getUserRole() == "0"
                                        {
                                            self.txtVwDesc.text = ""
                                            self.txtFldAmount.text = ""
                                            self.imageData = Data()
                                            self.fileName = ""
                                            self.lblImageName.text = ""
                                            self.btnCard.isSelected = false
                                            self.btnWalletAmt.isSelected = false
                                            self.btnNoReceipt.isSelected = true
                                            self.btnNoReceiptClicked(self.btnNoReceipt)
                                            
                                        }
                                        else
                                        {
                                            let _=self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }))
                                self.present(alert, animated: true, completion: nil)
                        }
                    }

                }, failureMessage: { (failure) in
                    app_delegate.removeloder()
                    
                })
            }
        }
    }
    @IBAction func btnUploadImageClicked(_ sender: UIButton) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        isImageModified = true
        imageData = self.compressImageSize(image: info[UIImagePickerControllerOriginalImage] as! UIImage, compressionQuality: 1.0)
            
            
        
        let imageSize: Int = imageData.count
        print("size of image in KB: %f ", Double(imageSize) / 1024.0)

        if let url = info[UIImagePickerControllerReferenceURL] as? URL
        {
            if let assets = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil) as? PHFetchResult
            {
                if assets.count > 0
                {
                    if let name = PHAssetResource.assetResources(for: assets.firstObject!).first!.originalFilename as? String
                    {
                        fileName = name
                    }
                    else
                    {
                        fileName = String(Int(NSDate().timeIntervalSince1970) * 1000) + ".jpg"
                    }
                }
                else
                {
                    fileName = String(Int(NSDate().timeIntervalSince1970) * 1000) + ".jpg"
                }
                
            }
            else
            {
                fileName = String(Int(NSDate().timeIntervalSince1970) * 1000) + ".jpg"
            }
            

        }
        else
        {
            fileName = String(Int(NSDate().timeIntervalSince1970) * 1000) + ".jpg"
        }
        lblImageName.text = fileName
        self.dismiss(animated: true, completion: nil)
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension CreateExpenseViewController : popoverGeneralDelegate {
    func selectedText(selectedText: String, popoverselected: Int, tag: Int) {
        imgBg.removeFromSuperview()
        if selectedText == "Logout"
        {
            TaksyKraftUserDefaults.setLoginStatus(object: false)
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            app_delegate.navCtrl = UINavigationController(rootViewController: vc)
            app_delegate.navCtrl.isNavigationBarHidden = true
            app_delegate.window?.rootViewController = app_delegate.navCtrl
            
        }
        else if selectedText == "My Expenses"
        {
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyExpensesViewController") as! MyExpensesViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else
        {
            print("N/A")
        }
    }
}
