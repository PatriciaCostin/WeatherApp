//
//  TemperatureView.swift
//  WeatherApp
//
//  Created by Patricia Costin on 12.01.2024.
//

import UIKit

final class TemperatureView: UIView {
    
    init() {
        super.init(frame: .zero)
        temperatureViewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        temperatureLabel.textColor = UIColor.gray.withAlphaComponent(0.8)
        temperatureLabel.backgroundColor = UIColor.secondaryViewBackground
        temperatureLabel.textAlignment = .right
        return temperatureLabel
    }()
    
    let weatherIcon: UIImageView = {
        let weatherIcon = UIImageView()
        return weatherIcon
    }()
    
    func temperatureViewSetup() {
        self.addSubview(temperatureLabel)
        self.addSubview(weatherIcon)
        self.backgroundColor = UIColor.secondaryViewBackground
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            temperatureLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: self.topAnchor),
            
            weatherIcon.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor),
            weatherIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            weatherIcon.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            weatherIcon.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
