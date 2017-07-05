//
//  CustomPopOver.swift
//  UIFramework
//
//  Created by Mery Rani on 2/5/16.
//  Copyright © 2016 martjack. All rights reserved.
//

import UIKit
protocol popoverGeneralDelegate
{
    func selectedText(selectedText : String,popoverselected:Int,tag:Int)
}
class CustomPopOver: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var delegate : popoverGeneralDelegate?
    var tableView: UITableView  =   UITableView()
    var titles: [String] = []
    var selectedIndex : Int = 0
    var popOverSelected : Int = 0
    var tag : Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        tableView.frame         =   CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MyTestCell")
        cell.selectionStyle =  .gray
            cell.isSelected = false
            cell.backgroundColor = UIColor.clear
            cell.detailTextLabel?.textColor = UIColor.gray
        cell.detailTextLabel!.text = titles[indexPath.row]
        cell.detailTextLabel?.textAlignment = NSTextAlignment.center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        self.selectedIndex = indexPath.row
        if((self.delegate) != nil) {
            delegate?.selectedText(selectedText: (cell?.detailTextLabel?.text)!,popoverselected: indexPath.row,tag:self.tag)
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
