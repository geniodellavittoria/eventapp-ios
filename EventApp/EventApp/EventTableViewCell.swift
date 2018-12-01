//
//  EventTableViewCell.swift
//  EventApp
//
//  Created by Pascal on 19.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTimeToLbl: UILabel!
    
    @IBOutlet weak var eventTimeFromLbl: UILabel!
    @IBOutlet weak var eventPriceLbl: UILabel!
    @IBOutlet weak var eventCategoryLbl: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var evenLocationLbl: UILabel!
    @IBOutlet weak var eventTitleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
