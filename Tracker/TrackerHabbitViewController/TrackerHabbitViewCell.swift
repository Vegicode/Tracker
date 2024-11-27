//
//  TrackerHabbitViewCell.swift
//  Tracker
//
//  Created by Mac on 20.11.2024.
//

import UIKit

class TrackerHabbitViewCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 16
        return label
    }()
    
    
    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let innerColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(colorView)
        colorView.addSubview(innerColorView)
        
        
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 52),
            titleLabel.heightAnchor.constraint(equalToConstant: 52),
            
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            innerColorView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 6),
            innerColorView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -6),
            innerColorView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 6),
            innerColorView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
