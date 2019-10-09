//
//  PhotoTableViewCell.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/3/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: CachedImageView!
    var id: String = ""
    @IBOutlet weak var hastagshLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
        if (self.photoImageView.image == nil){
        self.photoImageView.cancelTask(id: self.id)
        }
        self.photoImageView.image = nil
    }
}


