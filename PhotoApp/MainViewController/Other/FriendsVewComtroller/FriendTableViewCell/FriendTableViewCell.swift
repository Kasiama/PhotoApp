//
//  FriendTableViewCell.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/18/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    var friendId = ""
    var friendName = ""
    @IBOutlet weak var friendImageView: CachedImageView!
    @IBOutlet weak var friendUserName: UILabel!
    @IBOutlet weak var statusName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.friendImageView.image == nil {
            self.friendImageView.cancelTask(id: self.friendId)
        }
    }

}
