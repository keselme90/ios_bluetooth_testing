//
//  TableViewCell.swift
//  BT_Test_App
//
//  Created by Edward Keselman on 18/05/2021.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var indentifierLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    func setCell(name: String, identifier: String, state: String ) {
        
        nameLabel.text = name;
        indentifierLabel.text = identifier;
        stateLabel.text = state;
    }
    
}
