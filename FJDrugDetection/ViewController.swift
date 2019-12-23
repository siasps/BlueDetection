//
//  ViewController.swift
//  FJDrugDetection
//
//  Created by peng on 2019/4/22.
//  Copyright © 2019 peng. All rights reserved.
//

import UIKit

class ViewController: UIViewController,FJBaiduToolDelegate,DeviceServiceDelegate {

    var devService:DeviceService!
    var cannectStatus = false
    
    var resultString : String = ""
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self,action: #selector(self.titleLabelClick(tapGes: )))
        self.view.addGestureRecognizer(tapGes)
        
 
        
        devService = DeviceService()
    }
    
    @objc func titleLabelClick(tapGes:UITapGestureRecognizer){
        // 1、获取当前label
//        guard let currentLabel = tapGes.view as? UIView else {
//            return
//        }
        
       textView.resignFirstResponder()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        devService.delegate = self
        
        statusLabel.text = "连接蓝牙设备，方可检测！"
        statusLabel.textColor = UIColor.black
        cannectStatus = false
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
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
        //print(deviceName,uuid)
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
        
        print(resultString)
        
        textView.text = resultString
    }

    @IBAction func stopServer(_ sender: Any) {
        
        devService.stopService()
        
        
    }
    

    @IBAction func starServer(_ sender: Any) {
        
        devService.scanBlePeripheral()

    }
    
    @IBAction func clierButton(_ sender: Any) {
        
        resultString = ""
        
        textView.text = resultString
    }
}




