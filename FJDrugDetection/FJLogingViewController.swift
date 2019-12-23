//
//  FJLogingViewController.swift
//  FJDrugDetection
//
//  Created by peng on 2019/4/29.
//  Copyright © 2019 peng. All rights reserved.
//

import UIKit

class FJLogingViewController: UIViewController,DeviceServiceDelegate {
    
    @objc public var bleService:DeviceService? = nil
    @objc public var targetDevName:String? = nil
    var disConnectStatus = false
    
    
    var originDict : Dictionary<AnyHashable,Any>?
    var activityView : UIActivityIndicatorView!
    var dataArr : [DetectValue] = [DetectValue]()
    var index : integer_t = 0
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleService?.delegate = self
        
        activityView = UIActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: self.view.frame.size.width - 200, height: self.view.frame.size.width - 200))
        activityView.style = .whiteLarge
        activityView.color = UIColor.black
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    @objc func stopActivity() {
        self.activityView.stopAnimating()
        self.performSegue(withIdentifier: "PushReportVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushReportVC"{
            let controller = segue.destination as! FJReportViewController
            controller.originDict = self.originDict
            controller.detectionArray = dataArr
        }
    }
    
    
    
    func recive(from service: DeviceService, idx: Int, data: DetectValue) {
        
       index+=1
        if index < 5{
            dataArr.append(data)
            print("+++++\(data.AD1)--\(data.AD2)--\(data.AD3)")
        }else{
            disConnectStatus = true  //检测完成断开
            service.stopService()
            stopActivity()
            
        }
        
        //        connected = true
        //        stopTimeoutTimer()
        //        if model.collectDetectedData(d: data) {
        //            progressView.setProcess(percent: model.collectedProgress)
        //            traceDetect(data: data)
        //        }
    }
    
    @objc func disConnect(from service:DeviceService, byDeviceName:String, uuid:String, err:Error?) {
        print("蓝牙断开了连接")
        service.scanBlePeripheral()
        
        if !disConnectStatus {
            let alertVC = UIAlertController(title: "温馨提示", message: "蓝牙断开链接", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "知道了", style: .default) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alertVC.addAction(alertAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
}
