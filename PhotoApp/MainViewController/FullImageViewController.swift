//
//  FullImageViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/27/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: ActiveLabel!

    @IBOutlet  var imageView: CachedImageView!
    var image: UIImage?
    var photoDescription = ""
    var hastags: [String]?
    var date: String?
    var searchbar = UISearchBar.init()
    var imageForStatusbar: UIImage?

    convenience init(id: String, description: String? ) {
        self.init()
         Bundle.main.loadNibNamed("FullImageViewController", owner: self, options: nil)
            self.imageView.loadImage(idString: id)
        photoDescription = description ?? ""
            load()
    }

    func load() {
        self.view.backgroundColor = UIColor.gray
        descriptionLabel.customize { label in
            label.text = " " + photoDescription
            label.numberOfLines = 0
            label.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.handleHashtagTap { self.hastagTaped("Hashtag", message: $0)}
        }

        let gradient = CAGradientLayer()
        let bounds = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/5 )
        gradient.frame = bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.imageView.layer.addSublayer(gradient)

        let gradientе = CAGradientLayer()
        let boundss = CGRect.init(x: 0, y: UIScreen.main.bounds.height - UIScreen.main.bounds.height/5, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/5)
        gradientе.frame = boundss
        gradientе.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientе.startPoint = CGPoint(x: 0, y: 1)
        gradientе.endPoint = CGPoint(x: 0, y: 0)
        self.imageView.layer.addSublayer(gradientе)
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true

    }
    func hastagTaped(_ title: String, message: String) {
       let timeLineVC = TimeLineViewController(ISsearhbar: false, message: message)
        self.navigationController?.pushViewController(timeLineVC, animated: true)
        timeLineVC.imageForStatusBar = self.imageForStatusbar
    }

    func getImageFrom(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }

    @IBAction func backTaped(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    @IBAction func edgeSwipe(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
