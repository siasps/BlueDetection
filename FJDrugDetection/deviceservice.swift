//
//  deviceservice.swift
//  FJBiotechnology
//
//  Created by gu yingjiong on 2019/3/1.
//  Copyright © 2019 peng. All rights reserved.
//

import Foundation


extension Data {
  struct HexEncodingOptions: OptionSet {
    let rawValue: Int
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
  }
  
  func hexEncodedString(options: HexEncodingOptions = []) -> String {
    let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
    return map { String(format: format, $0) }.joined()
  }
  
  func toUInt16() -> [UInt16]? {
    let byteArr = [UInt8](self)
    let numBytes = byteArr.count
    var byteArrSlice = byteArr[0..<numBytes]
    
    guard numBytes % 2 == 0 else { return nil }
    
    var arr = [UInt16](repeating: 0, count: numBytes/2)
    for i in (0..<numBytes/2).reversed() {
      arr[i] = UInt16(byteArrSlice.removeLast()) +
        UInt16(byteArrSlice.removeLast()) << 8
    }
    return arr
  }
}


@objc public class DetectValue:NSObject{
  var softVision:String = ""
  var hardVision:String = ""
  var GroupNum:String = ""
  var AD1:String = ""
  var AD1M:String = ""
  var AD2:String = ""
  var AD2M:String = ""
  var AD3:String = ""
  var AD3M:String = ""
  var off:String = ""
  var enddate:String = ""
  
  init(with data:Data) {
    super.init()
    parserDecimal(data: data)
  }
  
  public func parserDecimal(data:Data){
    let a = data.toUInt16()!
    softVision = String(format:"%d", a[0])
    hardVision = String(format:"%d", a[1])
    GroupNum = String(format:"%d", a[2])
    AD1 = String(format:"%d", a[3])
    AD1M = String(format:"%d", a[4])
    AD2 = String(format:"%d", a[5])
    AD2M = String(format:"%d", a[6])
    AD3 = String(format:"%d", a[7])
    AD3M = String(format:"%d", a[8])
    off = String(format:"%d", a[9])
    //enddate = NSDate.getStringFrom(Date(), dateFormatter: "yyyy-MM-dd HH:mm:ss")
    print("AD1:\(AD1) AD1M:\(AD1M) AD3:\(AD3)  AD3M:\(AD3M)  AD2:\(AD2) AD2M:\(AD2M)")
    let dateFormatter2 = DateFormatter()
    dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let nowString = dateFormatter2.string(from: NSDate() as Date)// Date 转 String
    enddate = nowString
    
    print("---\(a)")
  }
  
  override public var description: String { return toDicForBsJson().description }
  public func toDicForBsJson()-> [String:String]{
    return ["GroupNum":GroupNum, "AD1":AD1, "AD1M":AD1M, "AD2":AD2, "AD2M":AD2M, "AD3":AD3, "AD3M":AD3M, "enddate": enddate]
  }
}

@objc public protocol DeviceServiceDelegate : NSObjectProtocol{
  @objc optional func found(form service:DeviceService, deviceName:String, uuid:String) -> Bool
  @objc optional func recive(from service:DeviceService, idx:Int, data:DetectValue)
  @objc optional func connected(from service:DeviceService, byDeviceName:String, uuid:String)
  @objc optional func disConnect(from service:DeviceService, byDeviceName:String, uuid:String, err:Error?)
  @objc optional func connectFail(from service:DeviceService, byDeviceName:String, uuid:String, err:Error?)
  @objc optional func bleNotOpen(from service:DeviceService)
}


public class DeviceService: NSObject {
  
  var ble:BabyBluetooth
  var dectectedDevs = [String:PeripheralItem]()
  @objc weak var delegate:DeviceServiceDelegate? = nil
  
  class PeripheralItem{
    var peripheral:CBPeripheral? = nil
    var name:String? = nil
    var uuid:String? = nil
    var rssi:NSNumber? = nil
    
    init(withPeripheral p:CBPeripheral, advertisementData:[AnyHashable:Any], rssi r:NSNumber) {
      let ln = (advertisementData["kCBAdvDataLocalName"] as? String) ?? peripheral?.name
      peripheral = p
      name = ln
      uuid = p.identifier.uuidString
      rssi = r
    }
  }
  
  
  let bleHdLastState = CBCentralManagerState.poweredOn
  let channelIdentify = "peripheralView"
  let deviceNamePrefix = "Pregnancy"
  let rhythm = BabyRhythm()
  var currentPeripheral:PeripheralItem? = nil
//  let dfuCtl = DFUServiceController()
  
  var scanning = false
  var debug = true
  
  public override init() {
    ble = BabyBluetooth.share()
    super.init()
    ble.setBlockOnDiscoverToPeripherals(handlerDiscoverToPeripherals)
    ble.setBlockOnCentralManagerDidUpdateState(handlerBleHardwareState)
    useVerboseScan()
  }
  
  func useVerboseScan()->Void{
    ble.setBabyOptionsWithScanForPeripheralsWithOptions([CBCentralManagerScanOptionAllowDuplicatesKey:true],
                                                                    connectPeripheralWithOptions: nil,
                                                                    scanForPeripheralsWithServices: nil, discoverWithServices: nil, discoverWithCharacteristics: nil)
  }
  
  @objc public func scanBlePeripheral(){
    ble.cancelAllPeripheralsConnection()
    ble.scanForPeripherals()()?.begin()()
    scanning = true
  }
  
  @objc public func stopService(){
    ble.cancelScan()
    scanning = false
    ble.cancelAllPeripheralsConnection()
  }
  
  @objc public func connectPeripheral(name:String){
    guard let dev = dectectedDevs[name]?.peripheral else {return}
    currentPeripheral = dectectedDevs[name]
    
    let connOpt = [CBConnectPeripheralOptionNotifyOnConnectionKey:true, CBConnectPeripheralOptionNotifyOnDisconnectionKey:true, CBConnectPeripheralOptionNotifyOnNotificationKey:true]
    let peripheralOpts = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
    
    ble.cancelScan()
    scanning = false
    
    ble.setBabyOptionsAtChannel(channelIdentify, scanForPeripheralsWithOptions: peripheralOpts, connectPeripheralWithOptions: connOpt, scanForPeripheralsWithServices: nil, discoverWithServices: nil, discoverWithCharacteristics: nil)
    ble.setBlockOnConnectedAtChannel(channelIdentify, block: handlerConnectedAtChannel)
    ble.setBlockOnFailToConnectAtChannel(channelIdentify, block: handlerConnectedFailAtChannel)
    ble.setBlockOnDisconnectAtChannel(channelIdentify, block: handlerDisconnectedAtChannel)
    ble.setBlockOnDiscoverServicesAtChannel(channelIdentify, block: handlerDiscoverService)
    ble.setBlockOnDiscoverCharacteristicsAtChannel(channelIdentify, block: handlerCharacteristics)
    ble.setBlockOnReadValueForCharacteristicAtChannel(channelIdentify, block: handlerValueOfCharacteristics)
    
    ble.having()(dev)?.and().channel()(channelIdentify)?.then()
      .connectToPeripherals()()?
      .discoverServices()()?
      .discoverCharacteristics()()?
      .readValueForCharacteristic()()?
      .discoverDescriptorsForCharacteristic()()?
      .readValueForDescriptors()()?.begin()()
  }
  
  // MARK: - baby framework call back handler functions:
  
  private func handlerDiscoverToPeripherals(central:CBCentralManager?, peripheral:CBPeripheral?, advertisementData:[AnyHashable:Any]?, RSSI:NSNumber?)->Void {
    let tmpDev = PeripheralItem(withPeripheral: peripheral!, advertisementData: advertisementData!, rssi: RSSI!)
    guard let rn = tmpDev.name else { return }
    dectectedDevs[rn] = tmpDev
    let callbackBlock : ()->Bool = { [weak self] in
      guard let d = self?.delegate else { return false }
      guard d.responds(to: #selector(DeviceServiceDelegate.found(form:deviceName:uuid:) )) else { return false }
      return d.found!(form: self!, deviceName: rn, uuid: tmpDev.uuid!)
    }
    
    if(rn.hasPrefix(deviceNamePrefix) && callbackBlock()) {
      connectPeripheral(name: rn)
    }
  }
  
  private func handlerConnectedAtChannel(central:CBCentralManager?, peripheral:CBPeripheral?)->Void{
    guard let d = delegate else { return }
    guard d.responds(to: #selector(DeviceServiceDelegate.connected(from:byDeviceName:uuid:) )) else { return }
    d.connected!(from: self, byDeviceName: currentPeripheral!.name!, uuid: currentPeripheral!.uuid!)
  }
  
  private func handlerConnectedFailAtChannel(central:CBCentralManager?,
                                              peripheral:CBPeripheral?, error:Error?)->Void{
    guard let d = delegate else { return }
    guard d.responds(to: #selector(DeviceServiceDelegate.connectFail(from:byDeviceName:uuid:err:) )) else { return }
    d.connectFail!(from: self, byDeviceName: currentPeripheral!.name!, uuid: currentPeripheral!.uuid!, err: error)
  }
  
  private func handlerDisconnectedAtChannel(central:CBCentralManager?,
                                          peripheral:CBPeripheral?, error:Error?)->Void{
    guard let d = delegate else { return }
    guard d.responds(to: #selector(DeviceServiceDelegate.disConnect(from:byDeviceName:uuid:err:) )) else { return }
    d.disConnect!(from: self, byDeviceName: currentPeripheral!.name!, uuid: currentPeripheral!.uuid!, err: error)
  }
  
  private func handlerBleHardwareState(central:CBCentralManager?)->Void{
    guard let d = delegate else { return }
    guard let c = central else {return}
    guard d.responds(to: #selector(DeviceServiceDelegate.bleNotOpen(from:) )) else { return }
    if(c.state == .poweredOff){
      d.bleNotOpen!(from: self)
    }
  }
  
  private func handlerDiscoverService(peripheral:CBPeripheral?, error:Error?)->Void{
    guard let ss = peripheral?.services else { return }
    
    ss.forEach { (s) in
      if(debug) {
        print("[debug]: found service \(s.uuid.uuidString)")
      }
    }
  }
  
  private func handlerCharacteristics(peripheral:CBPeripheral?, service:CBService?, error:Error?)->Void{
    guard let cs = service?.characteristics else { return }
    cs.forEach { (c) in
      if(debug) {
        print("[debug]: found service->characteristics \(c.uuid.uuidString)")
      }
      ble.notify(peripheral!, characteristic: c, block: handlerPeripheralNotify)
    }
  }
  
  private func handlerValueOfCharacteristics(peripheral:CBPeripheral?, characteristics:CBCharacteristic?, error:Error?)->Void{
    guard let c = characteristics else { return }
    if(debug) {
      print("[debug]: read characteristic info of id: \(c.uuid.uuidString)")
      print("[debug]:\(c.value ?? Data())")
    }
  }
  
  private func handlerPeripheralNotify(peripheral:CBPeripheral?, characteristics:CBCharacteristic?, error:Error?)->Void{
    guard let data = characteristics?.value else { return }
    guard data.count == 20 else {return}
    
    let idx = data[5]
    let dv = DetectValue(with: data)
    guard let d = delegate else { return }
    guard d.responds(to: #selector(DeviceServiceDelegate.recive(from:idx:data:))) else { return }
    d.recive!(from: self, idx: Int(idx), data: dv)
  }
}



//@objc class DeviceLock : NSObject {
//    private let uuid:String!
//    var devName:String? = nil
//    private var targetUuid:String
//    private var isValidTarget:Bool = false
    
//    @objc public init(withUUID uid:String, saveIfCacheIsEmpty:Bool = true) throws {
//        if uid.lengthOfBytes(using: .utf8) < 6 { throw DetectionModuleErr.InvalidBluetoothUUID }
//        targetUuid = uid
//        let cachedUuid = UserManager.lastBleDevUUID()
//        print("[debug] cache is:\(cachedUuid ?? String()), target is:\(uid)")
//        let isEmptyCache = ((cachedUuid ?? String()).lengthOfBytes(using: .utf8) < 6 )
//        if isEmptyCache { uuid = targetUuid } else { uuid = cachedUuid }
//        isValidTarget = (targetUuid == uuid)
//        super.init()
//        if saveIfCacheIsEmpty && isEmptyCache { UserManager.setLastBleDevUUID(targetUuid) }
//    }
//    
//    @objc public static func releaseDevice(){ UserManager.setLastBleDevUUID(nil) }
//    var isValid:Bool { get { return isValidTarget } }
//    func update() -> DeviceLock{
//        guard  isValid == false && targetUuid.isEmpty == false else { return self }
//        UserManager.setLastBleDevUUID(targetUuid)
//        print("[debug]: device \(targetUuid) did")
//        return try! DeviceLock(withUUID: targetUuid)
//    }
//}
