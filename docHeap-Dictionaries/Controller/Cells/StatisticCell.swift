//
//  StatisticCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 14.01.24.
//

import UIKit

class StatisticCell: UITableViewCell {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var launchesLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var mistakesLabel: UILabel!
    @IBOutlet weak var rightAnswersLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellBackground.layer.cornerRadius = 10
        cellBackground.layer.shadowColor = UIColor.systemGray2.cgColor
        cellBackground.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellBackground.layer.shadowRadius = 2.0
        cellBackground.layer.shadowOpacity = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
