//
//  RejectPopup.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 13/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class RejectPopup: UIView {
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var txtVwResaon: UITextView!
    @IBOutlet weak var constLblReasonAlertHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblCharCount: UILabel!
}
extension RejectPopup : UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.constLblReasonAlertHeight.constant = 0
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

