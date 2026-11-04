//
//  FavoriteCell.swift
//  FavoritesList
//
//  Created by madiaslanov on 04.11.2026.
//

import UIKit

class FavoriteCell: UITableViewCell {

    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!

    func configure(with item: FavoriteItem) {
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
