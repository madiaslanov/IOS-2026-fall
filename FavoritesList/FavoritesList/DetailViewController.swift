//
//  DetailViewController.swift
//  FavoritesList
//
//  Created by madiaslanov on 19.11.2026.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!

    var item: FavoriteItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        guard let item else { return }

        title = item.title
        carImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
            if let imageView = view as? UIImageView {
                imageView.image = UIImage(
                    systemName: index < item.rating ? "star.fill" : "star"
                )
                imageView.tintColor = .systemYellow
            }
        }
    }
}
