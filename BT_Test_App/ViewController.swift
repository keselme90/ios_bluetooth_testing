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
    
    @IBAction func fetchLocal(_ sender: Any) {
        
        let userDefaults = UserDefaults.standard
        let uuids = userDefaults.object(forKey: "service-uuid-array")as? [String] ?? [String]()
        print ("retrieved uuids = ", uuids)
        
        if(uuids.count == 0) {
            print("fetched 0 services from local storage")
        } else {
            print("fetched " + uuids.count.description + " services from local storage")
            
            var cbbuids = [CBUUID]()
            for uuid in uuids {
                cbbuids.append(CBUUID(string:uuid))
            }
            
            let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: cbbuids)as? [CBPeripheral] ?? [CBPeripheral]()
            
            print("connected peripherals ", connectedPeripherals)
            
            if(connectedPeripherals.count > 0) {
                
                let peripheral = connectedPeripherals[0];
                
                connectedPeripheral = peripheral
                
                let alert = UIAlertController(title: "Connected Peripheral Found", message: "Found peripheral " + peripheral.description, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                    
                    self.centralManager?.connect(self.connectedPeripheral!, options: nil)
                }))

                // show the alert
                self.present(alert, animated: true, completion: nil)
                
            }
            else {
                print("didn't find any connected peripherals")
                
                let alert = UIAlertController(title: "Connected Peripheral NOT Found", message: "Failed to find peripherals with given services", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    @IBAction func startScanning(_ sender: Any) {
        
        if(self.isBluetoothOn) {
            
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
        
        var serviceUUIDArray = [String]()
        for service in peripheral.services! {
            print("service uuid = ", service.uuid.uuidString)
            serviceUUIDArray.append(service.uuid.uuidString)
        }
        
        print("serviceUUIDArray = ", serviceUUIDArray)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(serviceUUIDArray, forKey: "service-uuid-array")
        
        // create the alert
        let alert = UIAlertController(title: "Services Dound", message: "Found " + peripheral.services!.count.description + " services and saved them to local storage", preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect to ", peripheral)
        
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        
        self.centralManager?.stopScan();
        print("scan stopped")
        
        peripheral.discoverServices(nil)
        
        let alert = UIAlertController(title: "Peripheral Connected", message: "Connected to " + connectedPeripheral!.description + " services and saved them to local storage", preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
                
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("connection event did occur with = ", peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if(peripheral.name == nil) {
            return
        }
        
        print("*******************************\nperipheral identifier = ", peripheral.identifier)
        
        print("discovered peripheral = ", peripheral)
        print("advertisement data = ", advertisementData)
        if(advertisementData["kCBAdvDataManufacturerData"] != nil)
        {
            print ("kCBAdvDataManufacturerData = ", advertisementData["kCBAdvDataManufacturerData"] as! NSData)
        }

        if(peripheralsArray.contains(where: { $0.identifier == peripheral.identifier})) {
            
            if let row = self.peripheralsArray.firstIndex(where: {$0.identifier == peripheral.identifier}) {
                   peripheralsArray[row] = peripheral
                
                peripheralsTableView.reloadData()
            }
        }
        else {
            
            peripheralsArray.append(peripheral)
            peripheralsTableView.reloadData()
            
        }
            
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
        
        let peripheral = peripheralsArray[indexPath.row];
        centralManager?.connect(peripheral, options: nil)

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
