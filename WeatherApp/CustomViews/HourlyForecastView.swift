//
//  HourlyForecastView.swift
//  WeatherApp
//
//  Created by Patricia Costin on 08.01.2024.
//

import UIKit
import Accelerate

final class HourlyForecastView: UIView {
    
    init() {
        super.init(frame: .zero)
        setupTitle()
        backgroundColor = UIColor(named: "SecondaryViewBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let elementsCount = 24
    private var hourForecasts = [Int]()
    private var graphPoints = [Int]()
    private var temperatureLabels = [UILabel]()
    private lazy var temperatureViews: [TemperatureView] = {
        var temperatureViews = [TemperatureView]()
        for temperatureView in 0..<elementsCount {
            var temperatureView = TemperatureView()
            temperatureViews.append(temperatureView)
        }
        return temperatureViews
    }()
    
    private var titleView = SecondaryTitleView()
    
    private lazy var hourLabels: [UILabel] = {
        var labels = [UILabel]()
        for label in 0..<elementsCount {
            var label = UILabel()
            label.font = .systemFont(ofSize: 10)
            label.textAlignment = .center
            labels.append(label)
        }
        return labels
    }()
    
    private enum Constants {
        static let margin: CGFloat = 20.0
        static let topBorder: CGFloat = 60
        static let bottomBorder: CGFloat = 50
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let width = rect.width
        let height = rect.height
        
        // Calculate the x point
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            // Calculate the gap between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        
        // Calculate the y point
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        guard let maxValue = graphPoints.max() else {
            return
        }
        guard let minValue = graphPoints.min() else {
            return
        }
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let yPoint = CGFloat(Double(graphPoint) - Double(minValue))/CGFloat(maxValue - minValue) * graphHeight
            return graphHeight + topBorder - yPoint // Flip the graph
        }
        
        // Draw the line graph
        UIColor.gray.withAlphaComponent(0.4).setFill()
        UIColor.gray.withAlphaComponent(0.4).setStroke()
        
        // Set up the points line
        let graphPath = UIBezierPath()
        graphPath.lineWidth = 2.0
        
        // Go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(Int(graphPoints[0]))))
        
        // Add points for each item in the graphPoints array at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(Int(graphPoints[i])))
            graphPath.addLine(to: nextPoint)
        }
        
        graphPath.stroke()
        
        setupTemperatureViewsforGhraph(columnXPoint: columnXPoint, columnYPoint: columnYPoint)
        setupHourLabels()
        
    }
    
    func setupTemperatureViewsforGhraph(columnXPoint: (Int) -> CGFloat, columnYPoint: (Int) -> CGFloat) {
        temperatureLabels.removeAll()
        
        //Set TemperatureView for each temperature forecast
        for i in 0..<graphPoints.count {
            let point = CGPoint(x: columnXPoint(i), y: columnYPoint(Int(graphPoints[i])))
            
            let temperatureView = temperatureViews[i]
            
            let temperatureLabel: UILabel = {
                let label = temperatureView.temperatureLabel
                return label
            }()
            
            temperatureLabels.append(temperatureLabel)
            self.addSubview(temperatureView)
            
            temperatureView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                temperatureView.centerXAnchor.constraint(equalTo: self.leadingAnchor, constant: point.x),
                temperatureView.centerYAnchor.constraint(equalTo: self.topAnchor, constant: point.y)
            ])
        }
    }
    
    func setupHourLabels() {
        for (index, label) in hourLabels.enumerated() {
            self.addSubview(label)
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textColor = UIColor.gray.withAlphaComponent(0.8)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: temperatureLabels[index].centerXAnchor),
                label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
    
    func update(with model: [HourlyWeatherModel]) {
        graphPoints.removeAll()
        
        for index in 0..<elementsCount {
            graphPoints.append(Int(model[index].temperature) ?? 0)
        }
        
        for (index, hourLabel) in hourLabels.enumerated() {
            hourLabel.text = "\(model[index].hour)"
        }
        
        setupTemperatureViews(model: model)
        
        setNeedsDisplay()
    }
    
    func setupTemperatureViews(model: [HourlyWeatherModel]) {
        let paletteDayConfig = UIImage.SymbolConfiguration.init(paletteColors: [UIColor.day, .systemYellow, UIColor.rain])
        let paletteDayShowerConfig = UIImage.SymbolConfiguration.init(paletteColors: [UIColor.day, UIColor.rain])
        let gradientConfig = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.night)
        let paletteNightShowerConfig = UIImage.SymbolConfiguration.init(paletteColors: [UIColor.night, UIColor.day, UIColor.rain])
        let paletteNightConfig = UIImage.SymbolConfiguration.init(paletteColors: [UIColor.night, UIColor.rain])
        let paletteNightBoltConfig = UIImage.SymbolConfiguration.init(paletteColors: [UIColor.night, .systemYellow])
        
        for (index, temperatureView) in temperatureViews.enumerated() {
            temperatureView.backgroundColor = UIColor(named: "SecondaryViewBackground")
            temperatureView.weatherIcon.image = UIImage(systemName: model[index].weatherIcon)
            temperatureView.temperatureLabel.text = model[index].temperature + "\u{00B0}"
            
            if model[index].partOfTheDay == "n" {
                temperatureView.weatherIcon.tintColor = UIColor.night
                if model[index].weatherIcon.contains(WeatherIconsString.nightClearSky) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = gradientConfig
                } else if model[index].weatherIcon.contains(WeatherIconsString.showerRain) || model[index].weatherIcon.contains(WeatherIconsString.drizzle) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = paletteNightConfig
                    temperatureView.temperatureLabel.textColor = UIColor.rain
                } else if model[index].weatherIcon.contains(WeatherIconsString.thunderstorm) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = paletteNightBoltConfig
                    temperatureView.temperatureLabel.textColor = UIColor.rain
                } else if model[index].weatherIcon.contains(WeatherIconsString.nightRain) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = paletteNightShowerConfig
                    temperatureView.temperatureLabel.textColor = UIColor.rain
                } else if model[index].weatherIcon.contains(WeatherIconsString.snow) {
                    temperatureView.weatherIcon.tintColor = UIColor.rain
                    temperatureView.temperatureLabel.textColor = UIColor.rain
                } else if model[index].weatherIcon.contains(WeatherIconsString.nightSmoke) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = gradientConfig
                } else if model[index].weatherIcon.contains(WeatherIconsString.nightFewClouds) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = gradientConfig
                }
                
            } else if model[index].partOfTheDay == "d" {
                temperatureView.weatherIcon.tintColor = UIColor.day
                if model[index].weatherIcon.contains(WeatherIconsString.dayFewClouds) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = paletteDayConfig
                    temperatureView.weatherIcon.tintColor = .systemYellow
                } else if model[index].weatherIcon.contains(WeatherIconsString.dayClearSky) {
                    temperatureView.temperatureLabel.textColor = .systemYellow
                    temperatureView.weatherIcon.tintColor = .systemYellow
                } else if model[index].weatherIcon.contains(WeatherIconsString.dayRain) || model[index].weatherIcon.contains(WeatherIconsString.thunderstorm) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = paletteDayConfig
                    temperatureView.temperatureLabel.textColor = UIColor.rain
                } else if model[index].weatherIcon.contains(WeatherIconsString.showerRain) || model[index].weatherIcon.contains(WeatherIconsString.drizzle) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = paletteDayShowerConfig
                    temperatureView.temperatureLabel.textColor = UIColor.rain
                } else if model[index].weatherIcon.contains(WeatherIconsString.snow) {
                    temperatureView.weatherIcon.tintColor = UIColor.rain
                    temperatureView.temperatureLabel.textColor = UIColor.rain
                } else if model[index].weatherIcon.contains(WeatherIconsString.daysmoke) {
                    temperatureView.weatherIcon.preferredSymbolConfiguration = paletteDayConfig
                }
            }
        }
    }
    
    func setupTitle() {
        self.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
        ])
        titleView.icon.image = UIImage(systemName: "clock")
        titleView.title.text = "HOURLY FORECAST"
    }
}

class WeatherIconsString {
    static let dayFewClouds = "cloud.sun.fill"
    static let clouds = "cloud.fill"
    static let dayClearSky = "sun.max.fill"
    static let dayRain = "cloud.sun.rain.fill"
    static let showerRain = "cloud.rain.fill"
    static let thunderstorm = "cloud.bolt.fill"
    static let snow = "snowflake"
    static let drizzle = "cloud.drizzle.fill"
    static let daysmoke = "sun.haze.fill"
    static let nightSmoke = "moon.haze.fill"
    static let nightFewClouds = "cloud.moon.fill"
    static let nightRain = "cloud.moon.rain.fill"
    static let nightClearSky = "moon.stars.fill"
}

class ColorNamesString {
    static let dayColor = "dayColor"
    static let nightColor = "nightColor"
    static let heroBorderColor = "HeroBorderColor"
    static let heroLightBlue = "HeroLightBlue"
}
