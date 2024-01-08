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
                label.text = "\(Int(graphPoints[i]))" + "\u{00B0}"
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
        
        for (index, temperatureView) in temperatureViews.enumerated() {
            temperatureView.weatherIcon.image = UIImage(systemName: model[index].weatherIcon)
        }
        
        setNeedsDisplay()
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

enum WeatherIconsString: String {
    case dayFewClouds = "cloud.sun.fill"
    case clouds = "cloud.fill"
    case dayClearSky = "sun.max.fill"
    case dayRain = "cloud.sun.rain.fill"
    case showerRain = "cloud.rain.fill"
    case thunderstorm = "cloud.bolt.fill"
    case snow = "snowflake"
    case drizzle = "cloud.drizzle.fill"
    case smoke = "sun.haze.fill"
    case nightFewClouds = "cloud.moon.fill"
    case nightRain = "cloud.moon.rain.fill"
    case nightClearSky = "moon.stars.fill"
}
