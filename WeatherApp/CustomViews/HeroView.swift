//
//  HeroView.swift
//  WheatherApp
//
//  Created by Patricia Costin on 30.12.2023.
//

import UIKit

class HeroView: UIView {
    
    init(){
        super.init(frame: .zero)
        self.heroViewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy private var cityLabel: UILabel = {
        let cityLabel = UILabel()
        cityLabel.textAlignment = .center
        cityLabel.text = "Chisinau"
        cityLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        return cityLabel
    }()

    lazy private var temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.textAlignment = .center
        temperatureLabel.text = "0"
        temperatureLabel.font = .systemFont(ofSize: 50, weight: .bold)
        return temperatureLabel
    }()
    
    private lazy var feelsLikeLabel: UILabel = {
        let feelsLikeLabel = UILabel()
        feelsLikeLabel.textAlignment = .center
        feelsLikeLabel.text = "Feels like 1 C"
        feelsLikeLabel.font = .systemFont(ofSize: 20, weight: .medium)
        return feelsLikeLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "Cloudy"
        descriptionLabel.font = .systemFont(ofSize: 20, weight: .medium)
        return descriptionLabel
    }()
    
    private let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .gray
        return separator
    }()
    
    private func heroViewSetup() {
        addSubview(cityLabel)
        addSubview(temperatureLabel)
        addSubview(feelsLikeLabel)
        addSubview(descriptionLabel)
        addSubview(separator)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cityLabel.topAnchor.constraint(equalTo: self.topAnchor),
            cityLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            temperatureLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 30),
            
            feelsLikeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            feelsLikeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            feelsLikeLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 7),
            
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            separator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            separator.heightAnchor.constraint(equalToConstant: 5),

            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
    
    func update(with model: CurrentWeatherModel) {
        cityLabel.text = model.name
        let temperature = Int(ceil(Double(model.main.temp - Double.kelvinToCelsiusValue)))
        let feelsLikeTemperature = Int(ceil(Double(model.main.feelsLike - Double.kelvinToCelsiusValue)))
        let celsiusSymbol = "\u{00B0}"
        temperatureLabel.text = "\(temperature)\(celsiusSymbol)"
        feelsLikeLabel.text = "Feels like \(feelsLikeTemperature)\(celsiusSymbol)"
        descriptionLabel.text = model.weather[0].description
    }
}

extension Double {
   static var kelvinToCelsiusValue: Double {
        return 273.15
    }
}
