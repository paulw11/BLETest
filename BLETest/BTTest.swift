//
//  BTTest.swift
//  BLETest
//
//  Created by Richard Nelson on 3/5/20.
//  Copyright © 2020 RIchard. All rights reserved.
//

import Foundation
import CoreBluetooth
import BackgroundTasks

class BluetoothTest: NSObject, CBCentralManagerDelegate {
    private var centralManager : CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var bluetoothQueue: DispatchQueue
    
    override init() {
        bluetoothQueue = DispatchQueue(label: "net.whatsbeef.bt-serial-queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
    }
    
    func startScanning() {
        print("\(Date()): Starting scan");
        self.bluetoothQueue.async {
            self.centralManager.scanForPeripherals(withServices: [CBUUID(string: "B82AB3FC-1595-4F6A-80F0-FE094CC218F9")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func stopScanning() {
        print("\(Date()): Stopping scan");
        self.centralManager.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Powered on")
            startScanning()
        default:
            print("Bluetooth is not active")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("\(Date()): \(peripheral.name ?? "") \(peripheral.identifier.uuidString) RSSI: \(RSSI)")
    }
}

extension BluetoothTest: CBPeripheralManagerDelegate {

public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

    guard peripheral.state == .poweredOn else { return }
    print("Peripheral advertising..")
    peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "HI THERE",
                                        CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "B82AB3FC-1595-4F6A-80F0-FE094CC218F9")]])
    }
}
