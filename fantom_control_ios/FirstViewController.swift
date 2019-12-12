//
//  FirstViewController.swift
//  fantom_control_ios
//
//  Created by Roy Zhao on 2019-12-01.
//  Copyright © 2019 Ziyi Zhao. All rights reserved.
//

import UIKit
import CoreBluetooth

let RPiServiceCBUUID = CBUUID(string: "0xFFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF0")
let RPiWriteCharacteristicCBUUID = CBUUID(string: "0xFFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF4")

class FirstViewController: UIViewController {
    var centralManager: CBCentralManager!
    var raspberryPeripheral: CBPeripheral!
    var raspberryWriteCharacteristic: CBCharacteristic!
    @IBOutlet weak var l_connectionIdicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onButton(_ sender: Any) {
        if raspberryPeripheral != nil && raspberryWriteCharacteristic != nil {
            var parameter = NSInteger(0x00)
            let data = NSData(bytes: &parameter, length: 1)
            raspberryPeripheral.writeValue(data as Data, for: raspberryWriteCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            print("Turn on message sent")
        }
    }
    
    @IBAction func offButton(_ sender: Any) {
        if raspberryPeripheral != nil && raspberryWriteCharacteristic != nil {
            var parameter = NSInteger(0x01)
            let data = NSData(bytes: &parameter, length: 1)
            raspberryPeripheral.writeValue(data as Data, for: raspberryWriteCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            print("Turn off message sent")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FirstViewController:CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case.unknown:
            print("central.state is now unknown")
        case.resetting:
            print("central.state is now resetting")
        case.unsupported:
            print("central.state is now unsupported")
        case.unauthorized:
            print("central.state is now unauthorized")
        case.poweredOff:
            print("central.state is now poweredOff")
        case.poweredOn:
            print("central.state is now poweredOn")
            centralManager.scanForPeripherals(withServices: [RPiServiceCBUUID])
        @unknown default:
            print("unknown central.state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        raspberryPeripheral = peripheral
        raspberryPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(raspberryPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        l_connectionIdicator.text = "• Connected"
        l_connectionIdicator.textColor = UIColor.green
        raspberryPeripheral.discoverServices([RPiServiceCBUUID])
    }
}

extension FirstViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics([RPiWriteCharacteristicCBUUID], for: service)

        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
                raspberryWriteCharacteristic = characteristic
                var parameter = NSInteger(0xFF)
                let data = NSData(bytes: &parameter, length: 1)
                peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }

        }
    }
}
