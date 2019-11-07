//
//  MainTabController.swift
//  fantom_control_ios
//
//  Created by Roy Zhao on 2019-11-02.
//  Copyright © 2019 Ziyi Zhao. All rights reserved.
//

import UIKit
import CoreBluetooth

let genericAccessServiceCBUUID = CBUUID(string: "0x1800")

class MainTabController: UITabBarController {
    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)

        // Do any additional setup after loading the view.
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

extension MainTabController:CBCentralManagerDelegate {
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
            centralManager.scanForPeripherals(withServices: [genericAccessServiceCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
      print(peripheral)
    }
}
