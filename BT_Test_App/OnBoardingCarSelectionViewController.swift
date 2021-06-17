//
//  OnBoardingCarSelectionViewController.swift
//  BT_Test_App
//
//  Created by Edward Keselman on 17/06/2021.
//

import UIKit

class OnBoardingCarSelectionViewController: UIViewController {
    
    var bluetoothObjects: [BluetoothObject] = []

    @IBOutlet weak var bluetoothTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bluetoothObjects = createArray();
        
        bluetoothTableView.delegate = self;
        bluetoothTableView.dataSource = self;
    }
    
    func createArray() -> [BluetoothObject] {
        let userDefaults = UserDefaults.standard
        let btObjects = userDefaults.object(forKey: "av_session_devices")as? [String] ?? [String]()
        print ("retrieved uuids = ", btObjects)
        
        var objetcs: [BluetoothObject] = []
        for btObject in btObjects {
            let components = btObject.components(separatedBy: ",")
            let name = components[0]
            let uid = components[1]
            
            objetcs.append(BluetoothObject(name: name, uid: uid));
            
        }
        return objetcs
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


extension OnBoardingCarSelectionViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bluetoothObjects.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let btObject = bluetoothObjects[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoohCell")as!BluetoothTableViewCell
        
        cell.setBtObject(btObject: btObject)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let btObject = bluetoothObjects[indexPath.row]
        
        let alert = UIAlertController(title: "בחירת רכב", message: "האם אתה בטוח ש" + btObject.name + " הוא הרכב שלך?" , preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "כן", style: UIAlertAction.Style.default, handler: {action in
            
            let userDefaults = UserDefaults.standard
            let confirmation = "user_car_confirmation--true,valueName--" + btObject.name + ",valueUid--"+btObject.uid;
            
            userDefaults.set(confirmation, forKey: "user_car_confirmation")
        }))

        alert.addAction(UIAlertAction(title: "לא", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

