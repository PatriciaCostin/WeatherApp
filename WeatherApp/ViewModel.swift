//
//  ViewModel.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import CoreLocation
import UIKit
import Accelerate

struct HourlyWeatherModel: Equatable {
    let hour: String
    let weatherIcon: String
    let temperature: String
}

@MainActor
final class ViewModel{
    
    private let currentWeather = WeatherServiceImp()
    var currentWeatherModel: Observable<CurrentWeatherModel?> = Observable(nil)
    var weatherForecastModel: Observable<WeatherForecastModel?> = Observable(nil)
    
    func getWeatherForUserLocation() async throws {
        let locationResult = await LocationService.shared.getLocation()
        
        switch locationResult {
        case .authorized(let cLLocation):
            let lat = String(cLLocation.coordinate.latitude)
            let lon = String(cLLocation.coordinate.longitude)
            let model = try await self.currentWeather.fetchCurrentWeatherService(lat: lat, lon: lon)
            currentWeatherModel.value = model
        case .userDenied:
            throw "User denied"
        case .osRestricted:
            throw "Restricted"
        case .failed(let error):
            throw "Failed \(error)"
        }
    }
    
    func getHourlyForecastForUserLocation() async throws {
        let locationResult = await LocationService.shared.getLocation()
        
        switch locationResult {
        case .authorized(let cLLocation):
            let lat = String(cLLocation.coordinate.latitude)
            let lon = String(cLLocation.coordinate.longitude)
            let model = try await self.currentWeather.fetchWeatherForecast(lat: lat, lon: lon)
            weatherForecastModel.value = model
        case .userDenied:
            throw "User denied"
        case .osRestricted:
            throw "Restricted"
        case .failed(let error):
            throw "Failed \(error)"
        }
    }
    
    func interpolateHourlyWeatherData(model: WeatherForecastModel) throws -> [HourlyWeatherModel] {
        var hourlyWeatherModels = [HourlyWeatherModel]()
        
        guard model.list.count >= 1 else {
            throw "[WeatherForHour] is empty"
        }
        
        let hoursArray = generateHoursArray(model: model.list[0])
        let temperatureArray = generateTemperatureArray(model: model.list)
        let iconsNamesArray = generateIconsNamesArray(model: model)
        
        guard hoursArray.count == 24 && temperatureArray.count == 24 && iconsNamesArray.count == 24 else {
            throw "hoursArray or temperatureArray or iconsNamesArray does not contain exactly 24 items"
        }
        
        for (hour, iconName, temperature) in zip3(hoursArray, iconsNamesArray, temperatureArray) {
            let model = HourlyWeatherModel(hour: hour, weatherIcon: iconName, temperature: temperature)
            hourlyWeatherModels.append(model)
        }
        return hourlyWeatherModels
    }
    
    func generateTemperatureArray(model: [WeatherForHour]) -> [String] {
        var temperatureArray = [Double]()
        
        for (index,forecastedTemperature) in model.enumerated() {
            if index <= 7 {
                // Include the temperature forecast for first 8 results (for current day only).
                temperatureArray.append(forecastedTemperature.main.temp.celsiusFromKelvinValue)
            }
        }
        
        let controlVector: [Double] = vDSP.ramp(in: 0 ... Double(temperatureArray.count) - 1,
                                                count: 24)
        let interpolatedTemperatureArray = vDSP.linearInterpolate(elementsOf: temperatureArray,
                                                                  using: controlVector)
            .map{ceil($0)}
        
        return interpolatedTemperatureArray.map { String(Int($0)) }
    }
    
    
    func generateHoursArray(model: WeatherForHour) -> [String] {
        var hourForecastArray = [Int]()
        
        var hourInt: Int = 0
        let restoredDate = Date(timeIntervalSince1970: TimeInterval(model.unixTimeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: restoredDate)
        
        hourInt = Int(hourString) ?? 0
        
        if hourInt <= 23 {
            for hour in hourInt..<24 {
                hourForecastArray.append(hour)
            }
        }
        
        if hourForecastArray.count < 24 {
            let remainingHours = 24 - hourForecastArray.count
            
            for hour in 0..<remainingHours {
                hourForecastArray.append(hour)
            }
        }
        
        let formattedHourForecasts = hourForecastArray.map { String(format: "%02d", $0) }
        return formattedHourForecasts
    }
    
    func generateIconsNamesArray(model: WeatherForecastModel) -> [String] {
        let hoursForecastArray = [0, 3, 6, 9, 12, 15, 18, 21]
        var hoursOfNight = [Int]()
        var hoursOfDay = [Int]()
        var descriptionForecast = [String]()
        
        for (index, partOfDay) in model.list.prefix(8).enumerated() {
            let description = model.list[index].weather[0].description.lowercased()
            
            if partOfDay.sys.partOfTheDay == "n" {
                hoursOfNight.append(hoursForecastArray[index])
                hoursOfNight.append(hoursForecastArray[index] + 1)
                hoursOfNight.append(hoursForecastArray[index] + 2)
                
                for _ in 1...3 {
                    descriptionForecast.append(description)
                }
                
            } else if partOfDay.sys.partOfTheDay == "d" {
                hoursOfDay.append(hoursForecastArray[index])
                hoursOfDay.append(hoursForecastArray[index] + 1)
                hoursOfDay.append(hoursForecastArray[index] + 2)
                
                for _ in 1...3 {
                    descriptionForecast.append(description)
                }
            }
        }
        
        let iconsNamesArray = determineWeatherIconsNames(
            descriptionForecast: descriptionForecast,
            hoursOfDay: hoursOfDay,
            hoursOfNight: hoursOfNight
        )
        
        return iconsNamesArray
    }
    
    
    func determineWeatherIconsNames(descriptionForecast: [String], hoursOfDay: [Int], hoursOfNight: [Int]) -> [String] {
        var iconsNamesArray = [String]()
        for index in 0...23 {
            let description = descriptionForecast[index]
            
            if description.contains("clouds") {
                if description.contains("few clouds") {
                    if hoursOfDay.contains(index) {
                        iconsNamesArray.append(WeatherIconsString.dayFewClouds.rawValue)
                    }
                    if hoursOfNight.contains(index) {
                        iconsNamesArray.append(WeatherIconsString.nightFewClouds.rawValue)
                    }
                } else {
                    iconsNamesArray.append(WeatherIconsString.clouds.rawValue)
                }
            } else if description.contains("clear sky") {
                if hoursOfDay.contains(index) {
                    iconsNamesArray.append(WeatherIconsString.dayClearSky.rawValue)
                }
                if hoursOfNight.contains(index) {
                    iconsNamesArray.append(WeatherIconsString.nightClearSky.rawValue)
                }
            } else if description.contains("rain") {
                if description.contains("shower") {
                    iconsNamesArray.append(WeatherIconsString.showerRain.rawValue)
                } else {
                    if hoursOfDay.contains(index) {
                        iconsNamesArray.append(WeatherIconsString.dayRain.rawValue)
                    }
                    if hoursOfNight.contains(index) {
                        iconsNamesArray.append(WeatherIconsString.nightRain.rawValue)
                    }
                }
            }
            else if description.contains("thunderstorm") {
                iconsNamesArray.append(WeatherIconsString.thunderstorm.rawValue)
            } else if description.contains("snow") {
                iconsNamesArray.append(WeatherIconsString.snow.rawValue)
            } else if description.contains("drizzle") {
                iconsNamesArray.append(WeatherIconsString.drizzle.rawValue)
            } else if description.contains("smoke")
                        || description.contains("mist")
                        || description.contains("haze")
                        || description.contains("ash")
                        || description.contains("dust")
                        || description.contains("tornado")
                        || description.contains("squalls")
                        || description.contains("sleet") {
                iconsNamesArray.append(WeatherIconsString.smoke.rawValue)
            }
        }
        return iconsNamesArray
    }
}

extension String: Error {  }
