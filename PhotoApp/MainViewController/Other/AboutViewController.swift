//
//  AboutViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/16/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var githubButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = UIImage.init(named: "me")
        self.imageView.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
    }

    @IBAction func vkbuttonTaped(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"https://vk.com/fukakasiama")! as URL)
    }
    @IBAction func githubButtonTaped(_ sender: Any) {
       UIApplication.shared.open(NSURL(string:"https://github.com/Kasiama/PhotoApp")! as URL)
    }
}
