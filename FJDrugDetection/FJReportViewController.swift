//
//  FJReportViewController.swift
//  FJDrugDetection
//
//  Created by peng on 2019/4/22.
//  Copyright © 2019 peng. All rights reserved.
//

import UIKit

class FJReportViewController: UITableViewController {
    
    var originDict : Dictionary<AnyHashable,Any>?
    @objc public var detectionArray:[DetectValue]!
    @IBOutlet weak var addressBackGround: UIView!
    @IBOutlet weak var policBackGround: UIView!
    @IBOutlet weak var userInfoBackGroundView: UIView!
    @IBOutlet weak var reportBackGround: UIView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var policeLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSexLabel: UILabel!
    @IBOutlet weak var nationLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var numberIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        reloadUI()
        
    }
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    func initUI() {
        
        tableView.separatorStyle = .none
        userInfoBackGroundView.clipsToBounds = true
        
        addressBackGround.layer.masksToBounds = true
        addressBackGround.layer.cornerRadius = 4.8
        policBackGround.layer.masksToBounds = true
        policBackGround.layer.cornerRadius = 4.8
        userInfoBackGroundView.layer.masksToBounds = true
        userInfoBackGroundView.layer.cornerRadius = 4.8
        reportBackGround.layer.masksToBounds = true
        reportBackGround.layer.cornerRadius = 4.8
        
        
        for i in 0...4 {
            let height = userInfoBackGroundView.frame.size.height
            let width = userInfoBackGroundView.frame.size.width
            
            let rect = CGRect(x: 0, y: height - 55 - CGFloat(55*i), width: width, height: 1)
            let line = UIView(frame: rect)
            line.backgroundColor = UIColor.lightGray
            userInfoBackGroundView.addSubview(line)
            
            
        }
        
    }
    func reloadUI() {
        
        let words_result : Dictionary<AnyHashable,Any> = originDict!["words_result"] as! Dictionary<AnyHashable, Any>
        let nameDict : Dictionary<AnyHashable,Any> = words_result["姓名"] as! Dictionary<AnyHashable,Any>
        let name : String = nameDict["words"] as! String
        
        let sexDict : Dictionary<AnyHashable,Any> = words_result["性别"] as! Dictionary<AnyHashable,Any>
        let sex : String = sexDict["words"] as! String
        
        let nationDict : Dictionary<AnyHashable,Any> = words_result["民族"] as! Dictionary<AnyHashable,Any>
        let nation : String = nationDict["words"] as! String
        
        let birthdayDict : Dictionary<AnyHashable,Any> = words_result["出生"] as! Dictionary<AnyHashable,Any>
        let birthday : String = birthdayDict["words"] as! String
        
        
        let addressDict : Dictionary<AnyHashable,Any> = words_result["住址"] as! Dictionary<AnyHashable,Any>
        let address : String = addressDict["words"] as! String
        
        let cardDict : Dictionary<AnyHashable,Any> = words_result["公民身份号码"] as! Dictionary<AnyHashable,Any>
        let card : String = cardDict["words"] as! String
        cityLabel.text = "上海市"
        policeLabel.text = "US00189"
        userNameLabel.text =  userNameLabel.text! + name
        userSexLabel.text = userSexLabel.text! + sex
        nationLabel.text = nationLabel.text! + nation
        birthdayLabel.text = birthdayLabel.text! + birthday
        addressLabel.text = addressLabel.text! + address
        numberIDLabel.text = numberIDLabel.text! + card
        
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowString = dateFormatter1.string(from: NSDate() as Date)
        dateLabel.text = nowString;
        
        
        
        let apples = 5
        let oranges = 3
        let quotation = """
        I said "I have \(apples) apples."
        And then I said "I have \(apples + oranges) pieces of fruit."
        """
        print(quotation)
    }

}

//class FJReportCityCustomCell: UITableViewCell {
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//}
//
//class FJReportPoliceNameCustomCell: UITableViewCell {
//
//}
//
//class FJReportUserInfoCustomCell: UITableViewCell {
//
//}
//class FJReportCustomCell: UITableViewCell {
//
//
//}



