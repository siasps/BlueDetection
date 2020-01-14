//
//  ViewController.swift
//  FJDrugDetection
//
//  Created by peng on 2019/4/22.
//  Copyright © 2019 peng. All rights reserved.
//

import UIKit

class ViewController: UIViewController,FJBaiduToolDelegate,DeviceServiceDelegate,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCellCustom = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCellCustom
        let detectValue : DetectValue = arrayData[indexPath.row]
        cell.label_1.text = detectValue.AD1
        cell.label_2.text = detectValue.AD1M
        cell.label_3.text = detectValue.AD2
        cell.label_4.text = detectValue.AD2M
        cell.label_5.text = detectValue.AD3
        cell.label_6.text = detectValue.AD3M
        cell.label_7.text = "\(indexPath.row + 1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.02
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.02
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableView.scrollToRow(at: NSIndexPath.init(row: self.arrayData.count - 1, section: 0) as IndexPath, at: UITableView.ScrollPosition.bottom, animated: false)
    }
    

    var devService:DeviceService!
    var cannectStatus = false
    
    var resultString : String = ""
    var arrayData:[DetectValue] = [DetectValue]()
    
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self,action: #selector(self.titleLabelClick(tapGes: )))
        self.view.addGestureRecognizer(tapGes)
        
        
        self.navigationItem.titleView = statusLabel
                
        //不写headerView 距离头部存在间距
//        let header = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 0.01))
//        header.backgroundColor = UIColor.blue
//        self.tableView.tableHeaderView = header
        
        
        devService = DeviceService()
    }
    
    @objc func titleLabelClick(tapGes:UITapGestureRecognizer){
        // 1、获取当前label
//        guard let currentLabel = tapGes.view as? UIView else {
//            return
//        }
        
//       textView.resignFirstResponder()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        devService.delegate = self
        
        statusLabel.text = "连接蓝牙设备，方可检测！"
        statusLabel.textColor = UIColor.black
        cannectStatus = false
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        devService.stopService()

    }

    @IBAction func startButtonClick(_ sender: Any) {
        
        if cannectStatus == false {
            let vc :UIAlertController = UIAlertController(title: "温馨提示", message: "当前未连接蓝牙设备", preferredStyle: .alert)
            let action :UIAlertAction = UIAlertAction(title: "知道了", style: .default, handler: nil)
            vc.addAction(action)
            present(vc, animated: true, completion: nil)
            return
        }
        FJBaiduTool.init(self).cardOCROnlineFront(self)
    }
    
    func collect(withResult resultDict: [AnyHashable : Any]) {
        performSegue(withIdentifier: "pushProgress", sender: resultDict)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushProgress"{
            let controller = segue.destination as! FJLogingViewController
            controller.originDict = sender as? Dictionary<AnyHashable,Any>
            controller.bleService = devService
        }
    }
    
    // MARK: - DeviceServiceDelegate method
    func found(form service: DeviceService, deviceName: String, uuid: String) -> Bool {
        print(deviceName,uuid)
        if deviceName.hasPrefix("Pregnancy") {
            service.connectPeripheral(name: deviceName)
            
            service.stopService()
        }
        return false
    }
    
    func connected(from service: DeviceService, byDeviceName: String, uuid: String) {
        //print("[debug]:\(byDeviceName) connect successful.")
        statusLabel.text = "连接成功：\(byDeviceName)"
        statusLabel.textColor = UIColor.blue
        cannectStatus = true
    }
    
    @objc func disConnect(from service:DeviceService, byDeviceName:String, uuid:String, err:Error?) {
        print("蓝牙断开了连接")
        statusLabel.text = "连接蓝牙设备，方可检测！"
        statusLabel.textColor = UIColor.black
        cannectStatus = false
    }
    
    func connectFail(from service: DeviceService, byDeviceName: String, uuid: String, err: Error?) {
//        connected = false
//        print("[debug]:\(byDeviceName) connect fail.")
//        showConnFailAlert()
    }
    
    
    func recive(from service: DeviceService, idx: Int, data: DetectValue) {
        
        //print("AD1:\(data.AD1) AD1M:\(data.AD1M)  AD2:\(data.AD2) AD2M:\(data.AD2M) AD3:\(data.AD3) AD3M:\(data.AD3M)"  )

        let dataStr = "AD1:\(data.AD1) AD1M:\(data.AD1M)  AD2:\(data.AD2) AD2M:\(data.AD2M) AD3:\(data.AD3) AD3M:\(data.AD3M)"
        
        resultString += dataStr + "\n"
        
        print(dataStr)
        
        arrayData.append(data)
        
        tableView.reloadData()
        
//        textView.text = resultString
    }

    @IBAction func stopServer(_ sender: Any) {
        
        devService.stopService()
        
        
    }
    

    @IBAction func starServer(_ sender: Any) {
        
        devService.scanBlePeripheral()

    }
    
    @IBAction func clierButton(_ sender: Any) {
        
        resultString = ""
        
//        textView.text = resultString
        
        arrayData.removeAll()
        tableView.reloadData()
    }
}




