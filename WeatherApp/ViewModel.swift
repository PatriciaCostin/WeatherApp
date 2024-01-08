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
    var hourlyForecastModel: Observable<[HourlyWeatherModel]?> = Observable(nil)
    
    private let forecastedItemsCount = 24
    
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
            hourlyForecastModel.value = try interpolateHourlyWeatherData(model: model)
        case .userDenied:
            throw "User denied"
        case .osRestricted:
            throw "Restricted"
        case .failed(let error):
            throw "Failed \(error)"
        }
    }
    
   public func interpolateHourlyWeatherData(model: WeatherForecastModel) throws -> [HourlyWeatherModel] {
        guard !model.list.isEmpty && model.list.count > 8 else {
            throw "[WeatherForHour] is empty or has less than 8 items"
        }
        
        let hoursArray = generateHoursArray(model: model.list[0])
        let temperatureArray = generateTemperatureArray(model: model.list)
        let iconsNamesArray = try generateIconsNamesArray(model: model)
        
        guard hoursArray.count == forecastedItemsCount
                && temperatureArray.count == forecastedItemsCount
                && iconsNamesArray.count == forecastedItemsCount
        else {
            throw "hoursArray or temperatureArray or iconsNamesArray does not contain exactly 24 items"
        }
        
        var hourlyWeatherModels = [HourlyWeatherModel]()
        for (hour, iconName, temperature) in zip3(hoursArray, iconsNamesArray, temperatureArray) {
            let model = HourlyWeatherModel(hour: hour, weatherIcon: iconName, temperature: temperature)
            hourlyWeatherModels.append(model)
        }
        return hourlyWeatherModels
    }
    
    private func generateTemperatureArray(model: [WeatherForHour]) -> [String] {
        let temperatureArray = model.prefix(8).map { $0.main.temp.celsiusFromKelvinValue }
        
        let controlVector: [Double] = vDSP.ramp(in: 0 ... Double(temperatureArray.count) - 1,
                                                count: 24)
        let interpolatedTemperatureArray = vDSP.linearInterpolate(elementsOf: temperatureArray,
                                                                  using: controlVector)
            .map { ceil($0) }
        
        return interpolatedTemperatureArray.map { String(Int($0)) }
    }
    
    
    private func generateHoursArray(model: WeatherForHour) -> [String] {
        let restoredDate = Date(timeIntervalSince1970: TimeInterval(model.unixTimeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: restoredDate)
        
        var hourInt = Int(hourString) ?? 0
        
        var hourForecastArray = [Int]()
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
        
        return hourForecastArray.map { String(format: "%02d", $0) }
    }
    
    private func generateIconsNamesArray(model: WeatherForecastModel) throws -> [String] {
        let hoursForecastArray = [0, 3, 6, 9, 12, 15, 18, 21]
        var hoursOfNight = [Int]()
        var hoursOfDay = [Int]()
        var descriptionForecast = [String]()
        
        for (index, partOfDay) in model.list.prefix(8).enumerated() {
            if partOfDay.sys.partOfTheDay == "n" {
                let description = model.list[index].weather.first?.description.lowercased() ?? "moon.stars.fill"
                hoursOfNight.append(hoursForecastArray[index])
                hoursOfNight.append(hoursForecastArray[index] + 1)
                hoursOfNight.append(hoursForecastArray[index] + 2)
                
                for _ in 0...2 {
                    descriptionForecast.append(description)
                }
                
            } else if partOfDay.sys.partOfTheDay == "d" {
                let description = model.list[index].weather.first?.description.lowercased() ?? "sun.max.fill"
                hoursOfDay.append(hoursForecastArray[index])
                hoursOfDay.append(hoursForecastArray[index] + 1)
                hoursOfDay.append(hoursForecastArray[index] + 2)
                
                for _ in 0...2 {
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
    
    
    private func determineWeatherIconsNames(descriptionForecast: [String], hoursOfDay: [Int], hoursOfNight: [Int]) -> [String] {
        var iconsNamesArray = [String]()
        for index in 0..<forecastedItemsCount {
            let description = descriptionForecast[index]
            
            if description.contains("clouds") {
                if description.contains("few clouds") {
                    if hoursOfDay.contains(index) {
                        iconsNamesArray.append(WeatherIconsString.dayFewClouds.rawValue)
                    } else if hoursOfNight.contains(index) {
                        iconsNamesArray.append(WeatherIconsString.nightFewClouds.rawValue)
                    }
                } else {
                    iconsNamesArray.append(WeatherIconsString.clouds.rawValue)
                }
            } else if description.contains("clear sky") {
                if hoursOfDay.contains(index) {
                    iconsNamesArray.append(WeatherIconsString.dayClearSky.rawValue)
                } else if hoursOfNight.contains(index) {
                    iconsNamesArray.append(WeatherIconsString.nightClearSky.rawValue)
                }
            } else if description.contains("rain") {
                if description.contains("shower") {
                    iconsNamesArray.append(WeatherIconsString.showerRain.rawValue)
                } else {
                    if hoursOfDay.contains(index) {
                        iconsNamesArray.append(WeatherIconsString.dayRain.rawValue)
                    } else if hoursOfNight.contains(index) {
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
