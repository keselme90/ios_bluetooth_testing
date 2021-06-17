//
//  MainScreenViewController.swift
//  BT_Test_App
//
//  Created by Edward Keselman on 17/06/2021.
//

import UIKit
import AVFoundation

class MainScreenViewController: UIViewController {
    
    @IBOutlet weak var connectingLabel: UILabel!
    
    @IBOutlet weak var carName: UILabel!
    
    @IBOutlet weak var clearDataButton: UIButton!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var notConnectedLabel: UILabel!
    
    @IBOutlet weak var reconnectLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
               
        self.connectingLabel.text = "אנא המתן,\nבודקים שאתה מחובר לרכב שלך"
           // Position Activity Indicator in the center of the main view
           myActivityIndicator.center = view.center
           
           // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
           myActivityIndicator.hidesWhenStopped = true
           
           // Start Activity Indicator
           myActivityIndicator.startAnimating()
           
           // Call stopAnimating() when need to stop activity indicator
           //myActivityIndicator.stopAnimating()
           
           
           view.addSubview(myActivityIndicator)
        
        let userDefaults = UserDefaults.standard
        let userConfirmation = userDefaults.object(forKey: "user_car_confirmation")as? String ?? ""
        let values = userConfirmation.components(separatedBy: ",")
        let car = values[1].components(separatedBy: "--")[1]
        let uuid = values[2].components(separatedBy: "--")[1]
        
        print("car name = ", car)
        print("car uuid = ", uuid)
        
        let connectedAvSession = AVAudioSession.sharedInstance().currentRoute
        let outputs = connectedAvSession.outputs
        var isConnected = false
        
        for output in outputs {
            if(output.uid.description == uuid) {
                isConnected = true
                break
            }
        }
        
        if(isConnected) {
           
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                
                self.connectingLabel.text = "מחובר אל רכב..."
                
                self.carName.isHidden = false
                self.carName.text = car
                
                self.recordingLabel.isHidden = false
                self.recordingLabel.text = "מקליט נסיעה כעת"
                
                self.clearDataButton.isHidden = false
                
                myActivityIndicator.stopAnimating()
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                
                self.connectingLabel.isHidden = true
                
                self.notConnectedLabel.isHidden = false
                
                self.reconnectLabel.isHidden = false
                
                self.clearDataButton.isHidden = false
                
                myActivityIndicator.stopAnimating()
            }
        }
    }
    
    
    @IBAction func clearAllData(_ sender: Any) {
        
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey:"user_car_confirmation")
        prefs.removeObject(forKey: "av_session_devices")
        
        let alert = UIAlertController(title: "המידע נמחק", message: "כל המידע ששמור נמחק!" , preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "סגור", style: UIAlertAction.Style.default, handler: nil))

        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}


//print("user confirmation = ", userConfirmation)
//let values = userConfirmation.components(separatedBy: ",")
//let uuidConfirmation = values[2].components(separatedBy: "--")[1]
//print("user confirmation uuid = ", uuidConfirmation)
//
//let connectedAvSession = AVAudioSession.sharedInstance().currentRoute
//print("curernt connected Av session = " , connectedAvSession.description)
//
//if(connectedAvSession.outputs[0].uid.description == uuidConfirmation) {
//
//    self.window!.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
//
//    print("conencted to your car!")
//}
//else {
//
//    let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OnboardingViewController")
//    let navigation = UINavigationController(rootViewController: rootController)
//
//    self.window!.rootViewController = navigation
//}
