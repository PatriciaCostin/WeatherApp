//
//  DetailView.swift
//  WeatherApp
//
//  Created by Patricia Costin on 03.01.2024.
//

import UIKit

class DetailView: UIView {
    
    init() {
        super.init(frame: .zero)
        self.setupDetailView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerStack: UIStackView = {
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.distribution = .equalSpacing
        containerStack.alignment = .center
        containerStack.spacing = 0
        return containerStack
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fill
        horizontalStack.alignment = .center
        horizontalStack.spacing = 5
        return horizontalStack
    }()
    
    var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return iconView
    }()
    
    var propertyLabel: UILabel = {
        let propertyLabel = UILabel()
        propertyLabel.textAlignment = .center
        propertyLabel.textColor = .white.withAlphaComponent(0.8)
        propertyLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        return propertyLabel
    }()
    
    var descriptorLabel: UILabel = {
        let descriptorLabel = UILabel()
        descriptorLabel.textAlignment = .center
        descriptorLabel.textColor = .white
        descriptorLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        return descriptorLabel
    }()
    
    private func setupDetailView() {
        self.addSubview(containerStack)
        
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: self.topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        containerStack.addArrangedSubview(horizontalStack)
        containerStack.addArrangedSubview(descriptorLabel)
        
        horizontalStack.addArrangedSubview(iconView)
        horizontalStack.addArrangedSubview(propertyLabel)
    }
}
