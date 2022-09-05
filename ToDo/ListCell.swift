//
//  ListCell.swift
//  ToDo
//
//  Created by Chris Boshoff on 2022/09/05.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
