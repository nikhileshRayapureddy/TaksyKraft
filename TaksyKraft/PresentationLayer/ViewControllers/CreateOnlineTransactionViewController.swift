//
//  CreateOnlineTransactionViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 28/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class CreateOnlineTransactionViewController: BaseViewController {
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var vwBtnDateBase: UIView!
    @IBOutlet weak var txtFldOTP: UITextField!
    @IBOutlet weak var txtFldRefNo: UITextField!
    @IBOutlet weak var txtFldAmt: UITextField!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblEmpName: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var scrlVw: UIScrollView!

    @IBOutlet weak var clVwTrxImages: UICollectionView!
    
    @IBOutlet weak var constClVwTrxImagesHeight: NSLayoutConstraint!
    @IBOutlet weak var clVwInvoiceImg: UICollectionView!
    @IBOutlet weak var constclVwInvoiceImgHeight: NSLayoutConstraint!

    @IBOutlet weak var btnAttachTrxImg: UIButton!
    @IBOutlet weak var constBtnAttachTrxImgHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblDescCount: UILabel!
    @IBOutlet weak var txtVwDesc: UITextView!
    
    @IBOutlet weak var btnAttachInvoiceImg: UIButton!
    @IBOutlet weak var constBtnAttachInvoiceImgHeight: NSLayoutConstraint!
    let datePicker = UIDatePicker()
    var vwSep = UIView()

    var trxBO = TransactionBO()
    var isImageEditing = false
    var isTrxImage = false
    var imgTrxUrl = ""
    var imgTrx = UIImage()
    var arrInvoiceImagesUrl = [String]()
    var arrInvoiceImages = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Upload Online Transaction",showBack: true, isRefresh: false)
        lblMobileNo.text = TaksyKraftUserDefaults.getUser().mobile
        lblEmpName.text = TaksyKraftUserDefaults.getUser().name
        
        txtFldOTP.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtFldOTP.frame.size.height))
        txtFldRefNo.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtFldRefNo.frame.size.height))
        txtFldAmt.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtFldAmt.frame.size.height))

        txtFldAmt.leftViewMode = .always
        txtFldRefNo.leftViewMode = .always
        txtFldOTP.leftViewMode = .always

        if trxBO.transId != "" && isImageEditing == false
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.date(from: trxBO.transactionDate)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strDate = dateFormatter.string(from: date!)
            btnDate.setTitle(strDate, for: .normal)
            self.constBtnAttachTrxImgHeight.constant = 0
            self.btnAttachTrxImg.isHidden = true
            

            txtFldAmt.text = trxBO.amount
            txtVwDesc.text = trxBO.notes
            constClVwTrxImagesHeight.constant = 60
            constclVwInvoiceImgHeight.constant = 60
            txtFldOTP.text = trxBO.usedOtp
            txtFldRefNo.text = trxBO.onlineTransactionId
            self.imgTrxUrl = trxBO.transactionImage
            self.arrInvoiceImagesUrl = trxBO.invoice
            for _ in 0..<self.arrInvoiceImagesUrl.count
            {
                self.arrInvoiceImages.append(UIImage())
            }
            clVwTrxImages.reloadData()
            clVwInvoiceImg.reloadData()
            if self.arrInvoiceImagesUrl.count >= 5
            {
                self.constBtnAttachInvoiceImgHeight.constant = 0
                self.btnAttachInvoiceImg.isHidden = true
            }
            
        }
         if trxBO.transId == "" && isImageEditing == false
         {
            constClVwTrxImagesHeight.constant = 0
            constclVwInvoiceImgHeight.constant = 0

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlVw.contentSize = CGSize(width: ScreenWidth, height: 880.0)
    }
    @IBAction func btnDateClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        datePicker.frame = CGRect(x: 0, y: ScreenHeight-250, width: self.view.frame.width, height: 250)
        datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.datePickerMode = .date
        //        let tmpDate = Calendar.current.date(byAdding: .year, value: -500, to: Date())
        //        datePicker.minimumDate = tmpDate
        //        datePicker.maximumDate = Date()
        self.view.addSubview(datePicker)
        
        let btnDone = UIButton(type: .custom)
        btnDone.frame = CGRect(x: 0, y: ScreenHeight-280, width: ScreenWidth, height: 30)
        btnDone.backgroundColor = UIColor.white
        btnDone.setTitleColor(.black, for: .normal)
        btnDone.contentVerticalAlignment = .center
        btnDone.contentHorizontalAlignment = .left
        btnDone.titleLabel?.font = UIFont(name: "Roboto", size: 14.0)
        btnDone.setTitle("  Done", for: .normal)
        btnDone.addTarget(self, action: #selector(self.btnCatPickerDoneClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnDone)
        
        vwSep = UIView(frame: CGRect(x: 0, y: ScreenHeight-251, width: ScreenWidth, height: 1))
        vwSep.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.view.addSubview(vwSep)
        
    }
    @objc func btnCatPickerDoneClicked(sender:UIButton)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: datePicker.date)
        btnDate.setTitle(strDate, for: .normal)
        
        datePicker.removeFromSuperview()
        sender.removeFromSuperview()
        vwSep.removeFromSuperview()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: datePicker.date)
        btnDate.setTitle(strDate, for: .normal)
    }

    @IBAction func btnAttachTrxImgClicked(_ sender: UIButton) {
        isTrxImage = true
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
    @IBAction func btnAttachInvoiceImgClicked(_ sender: UIButton) {
        isTrxImage = false
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
    @IBAction func btnSubmitClicked(_ sender: UIButton) {
        if txtFldAmt.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Amount.")
        }
        else if txtFldRefNo.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Reference Number.")
        }
        else if txtFldOTP.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Used OTP.")
        }
        else if txtVwDesc.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Description.")
       }
        else if btnDate.titleLabel?.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please select date of transaction.")
        }
        else if self.imgTrxUrl == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please select Transaction Image.")
        }
        else if arrInvoiceImagesUrl.count <= 0
        {
            self.showAlertWith(title: "Alert!", message: "Please select atleast one Invoice Image.")
        }
        else
        {
            app_delegate.showLoader(message: "Uploading...")
            let layer = ServiceLayer()
            layer.createOrUpdateOnlineTransactionWith(strId: trxBO.transId, strAmount: txtFldAmt.text!, strOnlineTransactionId: txtFldRefNo.text!, strTransactionDate: (btnDate.titleLabel?.text!)!, strNotes: txtVwDesc.text!, strTransactionImage: self.imgTrxUrl, arrImages: arrInvoiceImagesUrl, strUsedOtp: txtFldOTP.text!, successMessage: { (response) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    let alert = UIAlertController(title: "Alert!", message: "Online Transaction uploaded successfully.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (failure) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    if EXP_TOKEN_ERR == failure as! String
                    {
                        self.logout()
                    }
                    else
                    {
                        self.showAlertWith(title: "Failed", message: failure as! String)
                    }
                }
                
            }
        }
    }
}
extension CreateOnlineTransactionViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageData = self.compressImageSize(image: info[UIImagePickerControllerOriginalImage] as! UIImage, compressionQuality: 1.0)
        let imageSize: Int = imageData.count
        
        print("size of image in KB: %f ", Double(imageSize) / 1024.0)
        isImageEditing = true
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                app_delegate.showLoader(message: "Uploading Image...")
                let layer = ServiceLayer()
                layer.uploadWith(imageData: imageData, successMessage: { (response) in
                    DispatchQueue.main.async
                        {
                        app_delegate.removeloder()
                            if self.isTrxImage
                            {
                                self.constClVwTrxImagesHeight.constant = 60
                                self.imgTrxUrl = response as! String
                                self.imgTrx = UIImage(data: imageData)!
                                self.constBtnAttachTrxImgHeight.constant = 0
                                self.btnAttachTrxImg.isHidden = true
                                self.clVwTrxImages.reloadData()
                            }
                            else
                            {
                                self.constclVwInvoiceImgHeight.constant = 60
                                self.arrInvoiceImagesUrl.append(response as! String)
                                self.arrInvoiceImages.append(UIImage(data: imageData)!)
                                if self.arrInvoiceImages.count >= 5
                                {
                                    self.constBtnAttachInvoiceImgHeight.constant = 0
                                    self.btnAttachInvoiceImg.isHidden = true
                                }
                                self.clVwInvoiceImg.reloadData()

                            }
                    }
                    
                }) { (failure) in
                    DispatchQueue.main.async
                        {
                            app_delegate.removeloder()
                            if EXP_TOKEN_ERR == failure as! String
                            {
                                self.logout()
                            }
                            else
                            {
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
    
}
extension CreateOnlineTransactionViewController :UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clVwTrxImages
        {
            return 1
        }
        else
        {
            if trxBO.transId == ""
            {
                return arrInvoiceImages.count
            }
            else
            {
                return arrInvoiceImagesUrl.count
           }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize (width: 60, height: 60)

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clVwTrxImages
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
            cell.imgVwItem.layer.masksToBounds = true
            cell.imgVwItem.layer.cornerRadius = cell.imgVwItem.frame.size.width / 2

            if trxBO.transId == ""
            {
                cell.imgVwItem.image = imgTrx
                if imgTrxUrl == ""
                {
                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadFail")
                }
                else
                {
                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadSuccess")
                }
            }
            else
            {
                cell.imgVwItem.kf.setImage(with: URL(string: IMAGE_BASE_URL + imgTrxUrl), placeholder: #imageLiteral(resourceName: "Loading"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                    self.imgTrx = cell.imgVwItem.image!
                })
                cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadSuccess")
            }


            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
            cell.imgVwItem.layer.masksToBounds = true
            cell.imgVwItem.layer.cornerRadius = cell.imgVwItem.frame.size.width / 2

            if trxBO.transId == ""
            {
                cell.imgVwItem.image = arrInvoiceImages[indexPath.row]
                if arrInvoiceImagesUrl[indexPath.row] == ""
                {
                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadFail")
                }
                else
                {
                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadSuccess")
                }
                return cell
            }
            else
            {
                if arrInvoiceImagesUrl[indexPath.row] == ""
                {
                    cell.imgVwItem.image = arrInvoiceImages[indexPath.row]
                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadFail")
                }
                else
                {
                    cell.imgVwItem.kf.setImage(with: URL(string: IMAGE_BASE_URL + arrInvoiceImagesUrl[indexPath.row]), placeholder: #imageLiteral(resourceName: "Loading"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    }, completionHandler: { image, error, cacheType, imageURL in
                        self.arrInvoiceImages[indexPath.row] = image!
                    })
                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadSuccess")
                }
                return cell
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        
        if collectionView == clVwTrxImages
        {
            vc.isEdit = true
            vc.arrImages.removeAll()
            vc.arrImages.append(imgTrx)
        }
        else
        {
            vc.isEdit = true
            vc.arrImages.removeAll()
            vc.arrImages.append(contentsOf: arrInvoiceImages)
        }
        vc.callBack = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 60 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
        
    }

    
}
extension CreateOnlineTransactionViewController : UITextViewDelegate
{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let strText = textView.text + text
        if (strText.count) <= TXTVW_MAX_COUNT
        {
            lblDescCount.text = "\(strText.count - range.length)/\(TXTVW_MAX_COUNT)"
            return true
        }
        else
        {
            return false
        }
    }
    
    
}
extension CreateOnlineTransactionViewController : ImagePreviewViewControllerDelegate
{
    func reloadArrImagesWith(arrImages : [UIImage])
    {
        if arrImages.count > 0
        {
            if isTrxImage
            {
                imgTrx = arrImages[0]
                clVwTrxImages.reloadData()

            }
            else
            {
                arrInvoiceImages.removeAll()
                arrInvoiceImages.append(contentsOf: arrImages)
                clVwInvoiceImg.reloadData()
                if arrImages.count < 5
                {
                    self.constBtnAttachInvoiceImgHeight.constant = 30
                    btnAttachInvoiceImg.isHidden = false
                }

            }
        }
        else
        {
            if isTrxImage
            {
                imgTrx = UIImage()
                clVwTrxImages.reloadData()
                self.constBtnAttachTrxImgHeight.constant = 30
                btnAttachTrxImg.isHidden = false
                constClVwTrxImagesHeight.constant = 0
            }
            else
            {
                arrInvoiceImages.removeAll()
                clVwInvoiceImg.reloadData()
                self.constBtnAttachInvoiceImgHeight.constant = 30
                btnAttachInvoiceImg.isHidden = false
                constclVwInvoiceImgHeight.constant = 0
            }
        }
    }
}
extension  CreateOnlineTransactionViewController : UITextFieldDelegate
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
