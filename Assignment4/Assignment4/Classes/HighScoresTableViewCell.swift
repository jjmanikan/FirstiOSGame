//
//  HighScoresTableViewCell.swift
//  Assignment4
//
//  Created by Justine Manikan on 11/29/18.
//  Copyright © 2018 Justine Manikan. All rights reserved.
//

import UIKit

class HighScoresTableViewCell: UITableViewCell {
    
    @IBOutlet var name : UILabel!
    @IBOutlet var score : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
