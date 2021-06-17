//
//  AppDelegate.swift
//  BT_Test_App
//
//  Created by Edward Keselman on 11/05/2021.
//

import UIKit
import AVFoundation
import CoreBluetooth
import UserNotifications
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let geoCoder = CLGeocoder()
    
    var centralManager: CBCentralManager?
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    let locationManager = CLLocationManager()
    
    var didShowNotificationLocationUpdate = false;
    
    var myPeritheral: CBPeripheral?
    
    var filename:String?

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        guard CLLocationManager.locationServicesEnabled() else {
            return true
        }
        
        locationManager.requestAlwaysAuthorization()

        locationManager.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        setupNotifications()
        
        // check if we are connected to our car
        let userDefaults = UserDefaults.standard
        let userConfirmation = userDefaults.object(forKey: "user_car_confirmation")as? String ?? ""
        if((userConfirmation) != "") {
            
                self.window!.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        }
        else {
            
            let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OnboardingViewController")
            let navigation = UINavigationController(rootViewController: rootController)

            self.window!.rootViewController = navigation
        }
        
        return true
    }

    func setupNotifications() {
        
        print("AppDeleagte: setupNotification")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
        
    }
    
    @objc func handleRouteChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        
        
        switch reason {
        
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            print("AppDelegate: handleRouteChange () --> new device available")
            for output in session.currentRoute.outputs {
                
                /// Write data to user details
                    let deviceName = output.portName.description
                    let deviceUid = output.uid.description
                    let dataToWrite = deviceName + "," + deviceUid
                    
                    let userDefaults = UserDefaults.standard
                    var strings: [String] = userDefaults.object(forKey: "av_session_devices") as? [String] ?? []
                    
                    strings.append(dataToWrite)
                    userDefaults.set(strings, forKey: "av_session_devices")
                
                // End of saving to user details
                
                let content = UNMutableNotificationContent()
                content.title = "התחברות חדשה זוהתה"
                content.body = "התחברת אל  " + output.portName.description + " הקלטה התחילה"
                
                let uuidString = UUID().uuidString
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                
                notificationCenter.add(request, withCompletionHandler: nil)
                
//                headphonesConnected = true
                print("output port type = ", output.portType, " output port name = ", output.portName, " full output = ", output)
                
                let timestamp = NSDate().timeIntervalSince1970
                let name = "AVAudioSession_newDeviceAvailable_" + "date_" + Date().description + "desctiption_" + timestamp.description + ".txt"
                let fileName = getDocumentsDirectory().appendingPathComponent(name)
                
                do {
                    let str = "AVAudioSession_newDeviceAvailable_" + "date_" + Date().description + "_output_" + output.description
                    try str.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                }
            }
            
            let peripheral = UserDefaults.standard.object(forKey: "car_network")
            
            if((peripheral) != nil)
            {
                centralManager?.connect(peripheral as! CBPeripheral, options: nil)
            }
            
        case .oldDeviceUnavailable:
            print("AppDelegate: handleRouteChange () --> old device unavailable")
            
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs  {
                    
                    let content = UNMutableNotificationContent()
                    content.title = "התנתקות חדשה זוהתה"
                    content.body = "התנתקת מ  " + output.portName.description + "הקלטה נעצרה"
                    
                    let uuidString = UUID().uuidString
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                    
                    notificationCenter.add(request, withCompletionHandler: nil)
                    
//                    headphonesConnected = false
                    
                    let timestamp = NSDate().timeIntervalSince1970
                    let name = "AVAudioSession_newDeviceUnavailable_" + "date_" + Date().description + "_timestamp" + timestamp.description + ".txt"
                    let fileName = getDocumentsDirectory().appendingPathComponent(name)
                    
                    do {
                        let str = "AVAudioSession_newDeviceUnavailable_" + output.description + "_date_" + Date().description
                        try str.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                    }
                }
            }
        default: ()
        }
    }
    
}

extension  AppDelegate : CBPeripheralDelegate, CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("powerOff")
        case .poweredOn:
            print("powerOn")
        @unknown default:
            print("default")
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect to peripheral = ", peripheral)
        
        
        let timestamp = NSDate().timeIntervalSince1970
        let name = "didConnectToPeripheral_" + timestamp.description + ".txt"
        let fileName = getDocumentsDirectory().appendingPathComponent(name)
        
        do {
            let str = "didConnectToPeripheral, peripheral = " + peripheral.description
            try str.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
        let content = UNMutableNotificationContent()
        content.title = "BLE successfully connected"
        content.body = "Connected to JBL Speaker"
        content.sound = .default

        // 2
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "1111", content: content, trigger: trigger)

        // 3
        notificationCenter.add(request, withCompletionHandler: nil)
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("falied to conenct to peripheral = ", peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("did disconnect from peripheral ", peripheral)
        
        let timestamp = NSDate().timeIntervalSince1970
        let name = "didDisconnectFromPeripheral_" + timestamp.description + ".txt"
        let fileName = getDocumentsDirectory().appendingPathComponent(name)
        
        do {
            let str = "didDisconnectFromPeripheral, peripheral = " + peripheral.description
            try str.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
        let content = UNMutableNotificationContent()
        content.title = "BLE successfully disconencted"
        content.body = "Disconnected from JBL Speaker"
        content.sound = .default

        // 2
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "2222", content: content, trigger: trigger)

        // 3
        notificationCenter.add(request, withCompletionHandler: nil)
    }
}


extension AppDelegate: CLLocationManagerDelegate {
   
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch (manager.authorizationStatus)
        {
        
        case .notDetermined:
            print("location authorization not determnied")
        case .restricted:
            print("location authorization not restricted")
        case .denied:
            print("location authorization not denied")
        case .authorizedAlways:
            print("location authorization not authorization always")
            // 2
            locationManager.allowsBackgroundLocationUpdates = true;
            
            locationManager.showsBackgroundLocationIndicator = true;
            // 3
            locationManager.startUpdatingLocation()
            
//            locationManager.startMonitoringVisits()
            
            locationManager.startMonitoringSignificantLocationChanges()
            
        case .authorizedWhenInUse:
            print("location authorization not authorization when in use")
        @unknown default:
            print("location authorization default - unknown")
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        print("didUpdateLocatins, location = ", locations)
        
        let timestamp = NSDate().timeIntervalSince1970
        let name = "didupdateLocations_" + timestamp.description + ".txt"
        let fileName = getDocumentsDirectory().appendingPathComponent(name)
        
        do {
            let str = "didUpdateLocatins, location = " + locations.description
            try str.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
        if(!didShowNotificationLocationUpdate) {
            
            didShowNotificationLocationUpdate = true;
            let content = UNMutableNotificationContent()
            content.title = "New Journal entry 📌"
            content.body = "description"
            content.sound = .default

            // 2
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "3333", content: content, trigger: trigger)

            // 3
//            notificationCenter.add(request, withCompletionHandler: nil)
        }
        let uuids = [UUID(uuidString: "0BD95D98-D979-67DA-F3AA-C6C03781E70B")].compactMap({ $0 })
        let peripherals = centralManager?.retrievePeripherals(withIdentifiers: uuids)
//        print("peripherals ", peripherals)
        
        if(peripherals!.count > 0) {

            self.myPeritheral = peripherals![0];

            if(self.myPeritheral?.state.rawValue == 0)
            {
                centralManager?.connect(self.myPeritheral!, options: nil)
            }
        }
    }
    
    
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    // create CLLocation from the coordinates of CLVisit
    let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)

    print("CLLocationManagerDelegate, location manager = ", clLocation )
    // Get location description
    
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "\(place)"
        self.newVisitReceived(visit, description: description)
      }
    }
  }

  func newVisitReceived(_ visit: CLVisit, description: String) {
    
    print("CLLocationManagerDelegate, newVisitReceived = ", description)
    
    // 1
    let content = UNMutableNotificationContent()
    content.title = "New Journal entry 📌"
    content.body = description
    content.sound = .default

    // 2
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: NSDate().timeIntervalSince1970.description, content: content, trigger: trigger)

    // 3
//    notificationCenter.add(request, withCompletionHandler: nil)

//    let location = Location(visit: visit, descriptionString: description)

    // Save location to disk
  }
}



/// BC:42:8C:7A:D8:1C-tacl
