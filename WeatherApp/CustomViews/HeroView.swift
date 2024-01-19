//
//  HeroView.swift
//  WheatherApp
//
//  Created by Patricia Costin on 30.12.2023.
//

import UIKit

final class HeroView: UIView {
    
    // MARK: - Required methods
    
    init(){
        super.init(frame: .zero)
        self.heroViewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private properties
    
    private lazy var linearGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor.heroLightBlue.cgColor,
            UIColor.heroPowderyPurple.cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.cornerRadius = 20
        return gradient
    }()
    
    private lazy var cityLabel: UILabel = {
        let cityLabel = UILabel()
        cityLabel.textAlignment = .center
        cityLabel.text = "Chisinau Municipality"
        cityLabel.textColor = .white.withAlphaComponent(0.8)
        cityLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        return cityLabel
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.textAlignment = .center
        temperatureLabel.text = "0"
        temperatureLabel.textColor = .white
        temperatureLabel.font = .systemFont(ofSize: 100, weight: .heavy)
        return temperatureLabel
    }()
    
    private lazy var feelsLikeLabel: UILabel = {
        let feelsLikeLabel = UILabel()
        feelsLikeLabel.textAlignment = .center
        feelsLikeLabel.text = "Feels like 1 C"
        feelsLikeLabel.textColor = .white
        feelsLikeLabel.font = .systemFont(ofSize: 20, weight: .medium)
        return feelsLikeLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "Cloudy"
        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        return descriptionLabel
    }()
    
    private let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .white.withAlphaComponent(0.5)
        separator.layer.cornerRadius = 2
        return separator
    }()
    
    private let horizontalStack: UIStackView = {
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.alignment = .center
        return horizontalStack
    }()
    
    private let celsiusLabel: UILabel = {
        let celsiusLabel = UILabel()
        celsiusLabel.text = "\u{00B0}"
        celsiusLabel.textAlignment = .center
        celsiusLabel.textColor = .white
        celsiusLabel.font = .systemFont(ofSize: 40, weight: .bold)
        return celsiusLabel
    }()
    
    private let temperatureView = UIView()
    private let pressureView = DetailView()
    private let humidityView = DetailView()
    private let windSpeedView = DetailView()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.linearGradient.colors = [UIColor.heroLightBlue.cgColor, UIColor.heroPowderyPurple.cgColor]
    }
    
    private func heroViewSetup() {
        linearGradient.frame = self.bounds
        self.layer.insertSublayer(linearGradient, at: 0)
        
        addSubview(cityLabel)
        addSubview(temperatureView)
        addSubview(feelsLikeLabel)
        addSubview(descriptionLabel)
        addSubview(separator)
        addSubview(horizontalStack)
        temperatureView.addSubview(temperatureLabel)
        temperatureView.addSubview(celsiusLabel)
        horizontalStack.addArrangedSubview(pressureView)
        horizontalStack.addArrangedSubview(humidityView)
        horizontalStack.addArrangedSubview(windSpeedView)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        celsiusLabel.translatesAutoresizingMaskIntoConstraints = false
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cityLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            cityLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            temperatureView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            temperatureView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            temperatureView.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 20),
            temperatureView.heightAnchor.constraint(equalToConstant: 100),
            
            feelsLikeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            feelsLikeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            feelsLikeLabel.topAnchor.constraint(equalTo: temperatureView.bottomAnchor, constant: 0),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor),
            
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            separator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            separator.heightAnchor.constraint(equalToConstant: 3),
            
            horizontalStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            horizontalStack.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 10),
            horizontalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: temperatureView.centerXAnchor),
            temperatureLabel.centerYAnchor.constraint(equalTo: temperatureView.centerYAnchor),
            
            celsiusLabel.topAnchor.constraint(equalTo: temperatureView.topAnchor),
            celsiusLabel.leadingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor),
            
        ])
        
        setInitialValuesDetailView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        linearGradient.frame = self.bounds
    }
    
    func setInitialValuesDetailView() {
        pressureView.iconView.image = UIImage(systemName: "barometer")?.withTintColor(.white.withAlphaComponent(0.8),
                                                                                      renderingMode: .alwaysOriginal)
        pressureView.propertyLabel.text = "Pressure"
        pressureView.descriptorLabel.text = "1000 hPa"
        
        humidityView.iconView.image = UIImage(systemName: "drop")?.withTintColor(.white.withAlphaComponent(0.8),
                                                                                 renderingMode: .alwaysOriginal)
        humidityView.propertyLabel.text = "Humidity"
        humidityView.descriptorLabel.text = "50 %"
        
        windSpeedView.iconView.image = UIImage(systemName: "wind")?.withTintColor(.white.withAlphaComponent(0.8),
                                                                                  renderingMode: .alwaysOriginal)
        windSpeedView.propertyLabel.text = "Wind speed"
        windSpeedView.descriptorLabel.text = "0.0 m/s"
    }
    
    func update(with model: CurrentWeatherModel) {
        let temperature = Int(model.main.temp.celsiusFromKelvinValue)
        let feelsLikeTemperature = Int(model.main.feelsLike.celsiusFromKelvinValue)
        let description = descriptionSetup(model.weather[0].description)
        let celsiusSymbol = "\u{00B0}"
        
        cityLabel.text = model.name
        temperatureLabel.text = "\(temperature)"
        feelsLikeLabel.text = "Feels like \(feelsLikeTemperature)\(celsiusSymbol)"
        descriptionLabel.text = description
        
        pressureView.descriptorLabel.text = "\(model.main.pressure) hPa"
        humidityView.descriptorLabel.text = "\(model.main.humidity) %"
        windSpeedView.descriptorLabel.text = "\(model.wind.speed) m/s"
    }
    
    func descriptionSetup(_ description: String) -> String {
        let words = description.components(separatedBy: " ")
        let capitalizedWords = words.map {$0.capitalized}
        var newDescription = ""
        
        for (index, word) in capitalizedWords.enumerated() {
            if index < (capitalizedWords.count - 1) {
                newDescription.append(word + " ")
            } else {
                newDescription.append(word)
            }
        }
        return newDescription
    }
}

extension Double {
    var celsiusFromKelvinValue: Double {
        return ceil(self - 273.15)
    }
}
