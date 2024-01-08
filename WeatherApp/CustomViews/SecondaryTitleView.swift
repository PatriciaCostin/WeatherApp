//
//  SecondaryTitleView.swift
//  WeatherApp
//
//  Created by Patricia Costin on 12.01.2024.
//

import UIKit

final class SecondaryTitleView: UIView {
    
    init() {
        super.init(frame: .zero)
        viewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let containerStack: UIStackView = {
        let containerStack = UIStackView()
        containerStack.axis = .horizontal
        containerStack.distribution = .fill
        containerStack.alignment = .center
        containerStack.spacing = 5
        return containerStack
    }()
    
    var icon: UIImageView = {
        let icon = UIImageView()
        icon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        icon.tintColor = UIColor.gray.withAlphaComponent(0.8)
        return icon
    }()
    var title: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 12, weight: .semibold)
        title.textColor = UIColor.gray.withAlphaComponent(0.8)
        return title
    }()
    
    func viewSetup() {
        self.addSubview(containerStack)
        containerStack.addArrangedSubview(icon)
        containerStack.addArrangedSubview(title)
        
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStack.topAnchor.constraint(equalTo: self.topAnchor),
            containerStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
    }
}
