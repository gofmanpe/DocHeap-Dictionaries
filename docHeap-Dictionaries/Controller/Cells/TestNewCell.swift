//
//  TestNewCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 18.01.24.
//

import UIKit

class TestNewCell: UITableViewCell {
    @IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var testName: UILabel!
    @IBOutlet weak var testDescription: UILabel!
    @IBOutlet weak var testCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        testCellView.layer.cornerRadius = 15
        testCellView.layer.shadowColor = UIColor.black.cgColor
        testCellView.layer.shadowOpacity = 0.2
        testCellView.layer.shadowOffset = .zero
        testCellView.layer.shadowRadius = 2
        // Configure the view for the selected state
    }
    
}
