//
//  CreateChequeViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 05/03/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class CreateChequeViewController: BaseViewController {
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var vwBtnDateBase: UIView!
    @IBOutlet weak var txtFldRefNo: UITextField!
    @IBOutlet weak var txtFldAmt: UITextField!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblEmpName: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var scrlVw: UIScrollView!
    
    @IBOutlet weak var clVwChqImages: UICollectionView!
    
    @IBOutlet weak var constClVwChqImagesHeight: NSLayoutConstraint!
    @IBOutlet weak var clVwInvoiceImg: UICollectionView!
    @IBOutlet weak var constclVwInvoiceImgHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnAttachChqImg: UIButton!
    @IBOutlet weak var constBtnAttachChqImgHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblDescCount: UILabel!
    @IBOutlet weak var txtVwDesc: UITextView!
    
    @IBOutlet weak var btnAttachInvoiceImg: UIButton!
    @IBOutlet weak var constBtnAttachInvoiceImgHeight: NSLayoutConstraint!
    let datePicker = UIDatePicker()
    var vwSep = UIView()
    
    var chqBO = ChequeBO()
    var isImageEditing = false
    var ischqImage = false
    var imgchqUrl = ""
    var imgchq = UIImage()
    var arrInvoiceImagesUrl = [String]()
    var arrInvoiceImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Create New Cheque",showBack: true, isRefresh: false)
        lblMobileNo.text = TaksyKraftUserDefaults.getUser().mobile
        lblEmpName.text = TaksyKraftUserDefaults.getUser().name
        
        txtFldRefNo.leftViewMode = .always
        txtFldAmt.leftViewMode = .always
        
        txtFldRefNo.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtFldRefNo.frame.size.height))
        txtFldAmt.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtFldAmt.frame.size.height))
        
        txtVwDesc.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtVwDesc.layer.borderWidth = 1.0
        
        txtFldRefNo.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtFldRefNo.layer.borderWidth = 1.0
        
        txtFldAmt.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtFldAmt.layer.borderWidth = 1.0
        
        vwBtnDateBase.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        vwBtnDateBase.layer.borderWidth = 1.0
        if chqBO.chequeId != "" && isImageEditing == false
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.date(from: chqBO.chequeClearanceDate)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strDate = dateFormatter.string(from: date!)
            btnDate.setTitle(strDate, for: .normal)
            self.constBtnAttachChqImgHeight.constant = 0
            self.btnAttachChqImg.isHidden = true
            
            
            txtFldAmt.text = chqBO.amount
            txtVwDesc.text = chqBO.Description
            constClVwChqImagesHeight.constant = 60
            constclVwInvoiceImgHeight.constant = 60
            txtFldRefNo.text = chqBO.chequeId
            self.imgchqUrl = chqBO.cheque_image
            self.arrInvoiceImagesUrl = chqBO.invoice_image
            for _ in 0..<self.arrInvoiceImagesUrl.count
            {
                self.arrInvoiceImages.append(UIImage())
            }
            clVwChqImages.reloadData()
            clVwInvoiceImg.reloadData()
            if self.arrInvoiceImagesUrl.count >= 5
            {
                self.constBtnAttachInvoiceImgHeight.constant = 0
                self.btnAttachInvoiceImg.isHidden = true
            }
            
        }
        if chqBO.chequeId == "" && isImageEditing == false
        {
            constClVwChqImagesHeight.constant = 0
            constclVwInvoiceImgHeight.constant = 0
            
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlVw.contentSize = CGSize(width: ScreenWidth, height: 880.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnDateClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        datePicker.frame = CGRect(x: 0, y: ScreenHeight-250, width: self.view.frame.width, height: 250)
        datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.datePickerMode = .date
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
    @IBAction func btnAttachChqImgClicked(_ sender: UIButton) {
        ischqImage = true
        let alert = UIAlertController(title: "Select an Image to Uplaod", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                
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
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                
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
        ischqImage = false
        let alert = UIAlertController(title: "Select an Image to Uplaod", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                
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
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                
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
        else if txtVwDesc.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Description.")
        }
        else if btnDate.titleLabel?.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please select date of transaction.")
        }
        else if self.imgchqUrl == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please select Transaction Image.")
        }
        else if arrInvoiceImagesUrl.count <= 0
        {
            self.showAlertWith(title: "Alert!", message: "Please select atleast one Invoice Image.")
        }
        else
        {
            let layer = ServiceLayer()
            layer.createOrUpdateChequeWith(strId: chqBO.chequeId, strAmount: txtFldAmt.text!, strChequeNo: txtFldRefNo.text!, strChequeClearanceDate: (btnDate.titleLabel?.text!)!, strDesc: txtVwDesc.text!, strCheque_image: self.imgchqUrl, arrImages: arrInvoiceImagesUrl, successMessage: { (response) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    let alert = UIAlertController(title: "Alert!", message: "Cheque uploaded successfully.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)

                }
            }, failureMessage: { (failure) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    if EXP_TOKEN_ERR == failure as! String
                    {
                        self.logout()
                    }
                    else
                    {
                        self.showAlertWith(title: "Failed", message: "Failed to upload Online Transaction.")
                    }
                }
            })
        }
    }
}
extension CreateChequeViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate
{
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return print("error found")
        }
        let imageData = self.compressImageSize(image: image, compressionQuality: 1.0)
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
                            if self.ischqImage
                            {
                                self.constClVwChqImagesHeight.constant = 60
                                self.imgchqUrl = response as! String
                                self.imgchq = UIImage(data: imageData)!
                                self.constBtnAttachChqImgHeight.constant = 0
                                self.btnAttachChqImg.isHidden = true
                                self.clVwChqImages.reloadData()
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
        imageData = image.jpegData(compressionQuality: compressionQuality) ?? Data()
        print("compressImageSize in KB: %f ", Double(imageData.count) / 1024.0)
        
        if imageData.count > 2097152 {
            return self.compressImageSize(image: image, compressionQuality: compressionQuality - 0.1)
        }
        return imageData
    }
    
}
extension CreateChequeViewController :UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clVwChqImages
        {
            return 1
        }
        else
        {
            if chqBO.chequeId == ""
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
        if collectionView == clVwChqImages
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
//            cell.imgVwItem.layer.masksToBounds = true
//            cell.imgVwItem.layer.cornerRadius = (cell.imgVwItem.frame.size.width ) / 2
//            self.setMaskTo(view: cell.imgVwItem, corner: [.bottomLeft,.bottomRight,.topLeft,.topRight])
            if chqBO.chequeId == ""
            {
                cell.imgVwItem.image = imgchq
                if imgchqUrl == ""
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
                
                let url = URL(string: IMAGE_BASE_URL + imgchqUrl)
                
                cell.imgVwItem.kf.indicatorType = .activity
                cell.imgVwItem.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "Loading"),
                    options: [.transition(.fade(1))])
                {
                    result in
                    switch result {
                    case .success(let value):
                        self.imgchq = cell.imgVwItem.image!
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                }

                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadSuccess")
            }
            
            
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
            cell.imgVwItem.layer.masksToBounds = true
            cell.imgVwItem.layer.cornerRadius = cell.imgVwItem.frame.size.width / 2
            if chqBO.chequeId == ""
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
                    
                    let url = URL(string: IMAGE_BASE_URL + arrInvoiceImagesUrl[indexPath.row])
                    
                    cell.imgVwItem.kf.indicatorType = .activity
                    cell.imgVwItem.kf.setImage(
                        with: url,
                        placeholder: UIImage(named: "Loading"),
                        options: [.transition(.fade(1))])
                    {
                        result in
                        switch result {
                        case .success(let value):
                            self.arrInvoiceImages[indexPath.row] = value.image
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                        }
                    }
                    cell.imgOverlay.image = #imageLiteral(resourceName: "ImageUploadSuccess")
                }
                return cell
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController

        if collectionView == clVwChqImages
        {
            vc.isEdit = true
            vc.arrImages.removeAll()
            vc.arrImages.append(imgchq)
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
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        
    }
    
    
}
extension CreateChequeViewController : UITextViewDelegate
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
    func setMaskTo(view : UIView,corner:UIRectCorner)
    {
        let rounded = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: view.frame.size.width/2, height: view.frame.size.height/2))
        let shape = CAShapeLayer()
        shape.frame = self.view.bounds
        shape.path = rounded.cgPath
        view.layer.mask = shape
    }

}
extension CreateChequeViewController : ImagePreviewViewControllerDelegate
{
    func reloadArrImagesWith(arrImages : [UIImage])
    {
        if arrImages.count > 0
        {
            if ischqImage
            {
                imgchq = arrImages[0]
                clVwChqImages.reloadData()
                
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
            if self.ischqImage
            {
                self.constClVwChqImagesHeight.constant = 0
                self.imgchqUrl = ""
                self.imgchq = UIImage()
                self.constBtnAttachChqImgHeight.constant = 30
                self.btnAttachChqImg.isHidden = false
                self.clVwChqImages.reloadData()
            }
            else
            {
                self.constclVwInvoiceImgHeight.constant = 0
                self.arrInvoiceImagesUrl.removeAll()
                self.arrInvoiceImages.removeAll()
                self.constBtnAttachInvoiceImgHeight.constant = 30
                self.btnAttachInvoiceImg.isHidden = false
                self.clVwInvoiceImg.reloadData()
                
            }
        }
    }
}
extension  CreateChequeViewController : UITextFieldDelegate
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
