//
//  PostTableViewCell.swift
//  found
//
//  Created by Ellen Li on 5/1/22.
//

import Foundation
import UIKit

class PostTableViewCell: UITableViewCell {

    let profileImageView = UIImageView()
    let posterImageView = UIImageView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let posterLabel = UILabel()
    let timestampLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        profileImageView.image = UIImage(systemName: "person.crop.circle")
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileImageView)
        
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        bodyLabel.font = UIFont.systemFont(ofSize: 15)
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)
        
        posterLabel.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        posterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterLabel)
        
        timestampLabel.font = UIFont.systemFont(ofSize: 10)
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timestampLabel)
    }
    
    func setupConstraints() {
        let profileImageDim: CGFloat = 30
        let topPadding: CGFloat = 20.0
        let sidePadding: CGFloat = 20.0

        // profileImageView - Person Icon
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageDim),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageDim)
        ])

        // titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topPadding),
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: sidePadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // bodyLabel
        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: topPadding),
            bodyLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: sidePadding),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding)
        ])


        // posterLabel
        NSLayoutConstraint.activate([
            posterLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: topPadding),
            posterLabel.leadingAnchor.constraint(equalTo: bodyLabel.leadingAnchor),
            posterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        // timestampLabel
        NSLayoutConstraint.activate([
            timestampLabel.topAnchor.constraint(equalTo: posterLabel.bottomAnchor, constant: topPadding / 3),
            timestampLabel.leadingAnchor.constraint(equalTo: posterLabel.leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with postObject: Post) {
        titleLabel.text = postObject.title
        bodyLabel.text = postObject.body
        posterLabel.text = postObject.poster
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        if let date = dateFormatter.date(from: postObject.timeStamp) {
            dateFormatter.dateFormat = "E, d MMM yyyy h:mm a"
            timestampLabel.text = "Posted on \(dateFormatter.string(from: date)) (EST)"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
