//
//  BluetoothTableViewCell.swift
//  BT_Test_App
//
//  Created by Edward Keselman on 17/06/2021.
//

import UIKit

class BluetoothTableViewCell: UITableViewCell {

    @IBOutlet weak var bluetoothNameValue: UILabel!
    
    @IBOutlet weak var bluetoothUidValue: UILabel!
    
    func setBtObject(btObject: BluetoothObject) -> Void {
        bluetoothUidValue.text = btObject.uid
        bluetoothNameValue.text = btObject.name
    }
}
