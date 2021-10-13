//
//  PicturesCollectionViewCell.swift
//  RentaTeam
//
//  Created by Давид Горзолия on 10/13/21.
//

import UIKit

final class PicturesCollectionViewCell: UICollectionViewCell {

    let picImageView: UIImageView = {
        let picImageView = UIImageView()
        picImageView.clipsToBounds = true
        picImageView.contentMode = .scaleAspectFill
        return picImageView
    }()

    private let numberOfLikesLabel: UILabel = {
        let numberOfLikesLabel = UILabel()
        numberOfLikesLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfLikesLabel.backgroundColor = .blue
        numberOfLikesLabel.layer.masksToBounds = true
        numberOfLikesLabel.layer.cornerRadius = 6
        numberOfLikesLabel.textColor = .white
        numberOfLikesLabel.font = UIFont.boldSystemFont(ofSize: 12)
        return numberOfLikesLabel
    }()

    private let activityIndicatorView = UIActivityIndicatorView()

    var isLoading = true {
        didSet {
            if isLoading {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .white
        activityIndicatorView.startAnimating()
        picImageView.addSubview(activityIndicatorView)
        contentView.addSubview(picImageView)
        contentView.addSubview(numberOfLikesLabel)
        numberOfLikesLabel.leftAnchor.constraint(equalTo: picImageView.leftAnchor, constant: 5).isActive = true
        numberOfLikesLabel.bottomAnchor.constraint(equalTo: picImageView.bottomAnchor, constant: -5).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        picImageView.frame = contentView.bounds
        activityIndicatorView.center = picImageView.center
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        picImageView.image = nil
    }

    func configureImage(with image: UIImage) {
        isLoading = false
        picImageView.image = image
    }

    func configureLikesNumber(with numberOfLikes: Int) {
        numberOfLikesLabel.text = " LIKES: \(numberOfLikes) "
    }
}
