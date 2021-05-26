//
//  ViewController.swift
//  BT_Test_App
//
//  Created by Edward Keselman on 11/05/2021.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager?
    var connectedPeripheral: CBPeripheral?
    var isBluetoothOn = false;
    var peripheralsArray = [CBPeripheral]()
    
    var gameTimer: Timer?
    
    
    
    @IBOutlet var peripheralsTableView: UITableView!
    
    @IBAction func clearResults(_ sender: Any) {
        
        if(!centralManager!.isScanning) {
            
            peripheralsArray.removeAll()
            peripheralsTableView.reloadData()
        }
    }
    
    @IBAction func startScanning(_ sender: Any) {
        
        if(self.isBluetoothOn) {
            
//            self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: "0BD95D98-D979-67DA-F3AA-C6C03781E70B"), CBUUID(string: "0xFE8F"), CBUUID(string: "FE8F"), CBUUID(string: "0BD95D98-D979-67DA-F3AA-C6C03781E70B")], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            
            self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            
        }
    }
    
    @IBAction func stopScanning(_ sender: Any) {
        
        if((centralManager?.isScanning) != nil) {
            centralManager?.stopScan()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print ("centralManagerDidUpdateState")
        
        switch central.state {
            case .unknown:
                print("unknown")
                break
            case .resetting:
                print("resetting")
                break
            case .unsupported:
                print("unsupported")
                break
            case .unauthorized:
                print("unauthorized")
                break
            case .poweredOff:
                print("poweredoff")
                self.isBluetoothOn = false;
                break
            case .poweredOn:
                print("poweredOn")
                
                self.isBluetoothOn = true;
                
//                let connected = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "65786365-6C70-6F69-6E74-2E636F6D0000"), CBUUID(string: "FE8F")])
                
//                print("connected = ", connected)
                
//                self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
                
//                var connectionEventsOptions = [
//                    CBConnectPeripheralOptionNotifyOnConnectionKey:true]
                
//                self.centralManager?.registerForConnectionEvents(options: connectionEventsOptions)
                
//                self.centralManager?.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
                
//                let uuids = [UUID(uuidString: "7E34D617-731F-616E-8C89-5729870CDD5E"), UUID(uuidString: "0BD95D98-D979-67DA-F3AA-C6C03781E70B")].compactMap({ $0 })
//                let peripherals = centralManager?.retrievePeripherals(withIdentifiers: uuids)
//                print("peripherals: ", peripherals)
//
//                let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "0x0000"), CBUUID(string: "0x6666")])
//                print("connected peripherals = ", connectedPeripherals)
                
                break
            @unknown default:
                print("default")
                break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("did discover services")
            
        guard let services = peripheral.services else {
               return
       }
        print("services = ", peripheral.services)
//       discoverCharacteristics(peripheral: peripheral)
        
        let connected = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "65786365-6C70-6F69-6E74-2E636F6D0000")])
        
        print("connected = ", connected)
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect to ", peripheral)
        
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        
//        peripheral.discoverServices(nil)
        
//        let connected = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "65786365-6C70-6F69-6E74-2E636F6D0000")])
//
//        print("connected = ", connected)
        
//        let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "0x0000"), CBUUID(string: "0x6666")])
//        print("connected peripherals = ", connectedPeripherals)
//
//        let uuids = [UUID(uuidString: "7E34D617-731F-616E-8C89-5729870CDD5E"), UUID(uuidString: "0BD95D98-D979-67DA-F3AA-C6C03781E70B")].compactMap({ $0 })
//        let peripherals = centralManager?.retrievePeripherals(withIdentifiers: uuids)
//        print("peripherals: \(peripherals)")
        
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("connection event did occur with = ", peripheral)
        
        let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "0x0000"), CBUUID(string: "0x6666")])
        print("connected peripherals = ", connectedPeripherals)
        
//        let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "0x0000")])
//        print("connected peripherals = ", connectedPeripherals)
        
//        let peripherals = centralManager?.retrievePeripherals(withIdentifiers: [])
//        print("peripherals = ", peripherals)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        print("*******************************\nperipheral identifier = ", peripheral.identifier)
        
        print("discovered peripheral = ", peripheral)
        print("advertisement data = ", advertisementData)
        if(advertisementData["kCBAdvDataManufacturerData"] != nil)
        {
            print ("kCBAdvDataManufacturerData = ", advertisementData["kCBAdvDataManufacturerData"] as! NSData)
        }

        if(peripheralsArray.contains(where: { $0.identifier == peripheral.identifier})) {
//            peripheralsArray.append(peripheral)
            
            if let row = self.peripheralsArray.firstIndex(where: {$0.identifier == peripheral.identifier}) {
                   peripheralsArray[row] = peripheral
                
                peripheralsTableView.reloadData()
            }
        }
        else {
            
            peripheralsArray.append(peripheral)
            peripheralsTableView.reloadData()
            
        }
        
        // 7E34D617-731F-616E-8C89-5729870CDD5E samsung phone
        // 0BD95D98-D979-67DA-F3AA-C6C03781E70B // jbl
        
//        if(peripheral.identifier.uuidString == "0BD95D98-D979-67DA-F3AA-C6C03781E70B") {
//            self.peripheral = peripheral
//            self.peripheral?.delegate = self
//
//            centralManager?.connect(peripheral, options: nil)
//            centralManager?.stopScan()
//
//            let uuids = [UUID(uuidString: "7E34D617-731F-616E-8C89-5729870CDD5E"), UUID(uuidString: "0BD95D98-D979-67DA-F3AA-C6C03781E70B")].compactMap({ $0 })
//            let peripherals = centralManager?.retrievePeripherals(withIdentifiers: uuids)
//            print("peripherals: \(peripherals)")
//
//            print("stopping scan")
//        }
        
        print("*******************************\n")
        
     }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        isBluetoothOn = false;
        
        peripheralsTableView.dataSource = self
        peripheralsTableView.delegate = self
    }

}


extension ViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("you tapped me!")
        
        let peripheral = peripheralsArray[indexPath.row];
        centralManager?.connect(peripheral, options: nil)
        
//        let defaults = UserDefaults.standard;
        //        defaults.set(peripheral, forKey: "car_network");
        
//        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
////            let randomNumber = Int.random(in: 1...20)
////            print("Number: \(randomNumber)")
////
////            if randomNumber == 10 {
////                timer.invalidate()
////            }
//            print("calling connect in sqeuled task")
//            self.centralManager?.connect(peripheral, options: nil)
//        }

    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! TableViewCell
        
        var name = ""
        
        name = peripheralsArray[indexPath.row].name ?? "N\\A"
        
        cell.nameLabel.text = name
        
        cell.indentifierLabel.text = peripheralsArray[indexPath.row].identifier.uuidString
        
        cell.stateLabel.text = peripheralsArray[indexPath.row].state.rawValue.description
        
        return cell
    }
}
// 7E34D617-731F-616E-8C89-5729870CDD5E
