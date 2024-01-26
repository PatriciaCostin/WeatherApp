//
//  TrialViewModel.swift
//  WeatherApp
//
//  Created by Patricia Costin on 23.01.2024.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
import Collections


@MainActor
class WeeklyForecastViewModel: ObservableObject {
    @Published var weatherModels: [DailyForecast] = []
    private let weatherService = WeatherServiceImp()
    
    func getWeeklyForecastForUserLocation() async throws {
        let locationResult = await LocationService.shared.getLocation()
       // let locationResult = LocationService.LocationResult.authorized(CLLocation(latitude: 47.0105, longitude: 28.8638))
        switch locationResult {
        case .authorized(let cLLocation):
            let lat = String(cLLocation.coordinate.latitude)
            let lon = String(cLLocation.coordinate.longitude)
            let model = try await self.weatherService.fetchWeatherForecast(lat: lat, lon: lon)
            let day = createDayDescriptions(model: model)
            let night = createNightDescriptions(model: model)
            weatherModels = createDailyForecasts(dayDescriptions: day, nightDescriptions: night)
        case .userDenied:
            throw "User denied"
        case .osRestricted:
            throw "Restricted"
        case .failed(let error):
            throw "Failed \(error)"
        }
    }
    
    private func createDailyForecasts(
        dayDescriptions: PartOfTheDayDescription,
        nightDescriptions: PartOfTheDayDescription
    ) -> [DailyForecast] {
        let nightMinTemperatures = nightDescriptions.temperatures
        let weekDaysForNightTimeForecasts = nightDescriptions.weekDays
        let iconNamesForNightTimeForecasts = nightDescriptions.iconNames
        
        let daysMaxTemperatures = dayDescriptions.temperatures
        let weekDaysForDayTimeForecasts = dayDescriptions.weekDays
        let iconNamesForDayTimeForecasts = dayDescriptions.iconNames
        
        let forecastedWeekDays = createForecastedWeekDays(weekDaysForDayTime: weekDaysForDayTimeForecasts, weekDaysForNightTime: weekDaysForNightTimeForecasts)
        
        return forecastedWeekDays.map { weekDay in
            let dayIndex = weekDaysForDayTimeForecasts.firstIndex(of: weekDay) ?? 0
            let nightIndex = weekDaysForNightTimeForecasts.firstIndex(of: weekDay) ?? 0
            
            if weekDaysForDayTimeForecasts.contains(weekDay) &&
                weekDaysForNightTimeForecasts.contains(weekDay) {
                return DailyForecast(
                    dayTimeWeekDay: weekDaysForDayTimeForecasts[dayIndex],
                    dayTimeTemp: daysMaxTemperatures[dayIndex],
                    dayTimeIcon: iconNamesForDayTimeForecasts[dayIndex],
                    nightTimeWeekDay: weekDaysForNightTimeForecasts[nightIndex],
                    nightTimeTemp: nightMinTemperatures[nightIndex],
                    nightTimeIcon: iconNamesForNightTimeForecasts[nightIndex]
                )
            } else if !weekDaysForDayTimeForecasts.contains(weekDay) &&
                        weekDaysForNightTimeForecasts.contains(weekDay) {
                return DailyForecast(
                    dayTimeWeekDay: nil,
                    dayTimeTemp: nil,
                    dayTimeIcon: nil,
                    nightTimeWeekDay: weekDaysForNightTimeForecasts[nightIndex],
                    nightTimeTemp: nightMinTemperatures[nightIndex],
                    nightTimeIcon: iconNamesForNightTimeForecasts[nightIndex]
                )
            } else if weekDaysForDayTimeForecasts.contains(weekDay) &&
                        !weekDaysForNightTimeForecasts.contains(weekDay) {
                return DailyForecast(
                    dayTimeWeekDay: weekDaysForDayTimeForecasts[dayIndex],
                    dayTimeTemp: daysMaxTemperatures[dayIndex],
                    dayTimeIcon: iconNamesForDayTimeForecasts[dayIndex],
                    nightTimeWeekDay: nil,
                    nightTimeTemp: nil,
                    nightTimeIcon: nil
                )
            }
            
            return DailyForecast()
        }
    }
    
    private func createNightDescriptions(model: WeatherForecastModel) -> PartOfTheDayDescription {
        // Properties used to build PartOfTheDayDescription
        var nightMinTemp = [Int]()
        var weekDaysForNightTimeForecasts = [String]()
        var iconNamesForNightTimeForecasts = [String]()
        
        let (datesArray, _) = createsForecastsDatesAndUniqueDaysArrays(model: model)
        let (_, uniqueDays) = createsForecastsDatesAndUniqueDaysArrays(model: model)
        
        // Properties used in the ForLoop for storing temporary data.
        var dayIndexes = [Int]()
        var dayTemps = [Int]()
        var weekDay = [String]()
        var weatherDescriptions = [String]()
        
        for day in uniqueDays {
            
            // Get the indexes of forecasts for a day at a time
            dayIndexes.removeAll()
            for (index, date) in datesArray.enumerated() {
                if day == date {
                    dayIndexes.append(index)
                }
            }
            
            dayTemps.removeAll()
            weekDay.removeAll()
            weatherDescriptions.removeAll()
            for dayIndex in dayIndexes {
                if model.list[dayIndex].sys.partOfTheDay == "n" {
                    
                    // Append the maximum temperature for night time
                    dayTemps.append(Int(model.list[dayIndex].main.tempMin.celsiusFromKelvinValue))

                    // Append only one weekDay name (its gonna be the same for all forecasts for a particular night)
                    if weekDay.count == 0 {
                        let currentWeekDay = model.list[dayIndex].weekDay
                        weekDay.append(currentWeekDay)
                    }
                    
                    // Append the weather descriptions for all forecasts of the night
                    weatherDescriptions.append(model.list[dayIndex].weather[0].description)
                    
                }
            }
            
            // After collecting data from the forecasts for a night, only the min temperature, the unduplicated week name and one icon name will be added to the arrays that will be returned.
            if dayTemps.count >= 1 {
                nightMinTemp.append(dayTemps.min() ?? 0)
            }
            
            if weekDay.count == 1 {
                weekDaysForNightTimeForecasts.append(weekDay[0])
            }
            
            if weatherDescriptions.count >= 1 {
                let iconName = determineWeatherIconsNames(description: weatherDescriptions[0], isDayTime: true)
                iconNamesForNightTimeForecasts.append(iconName)
            }
        }
        
        return PartOfTheDayDescription(
            temperatures: nightMinTemp,
            weekDays: weekDaysForNightTimeForecasts,
            iconNames: iconNamesForNightTimeForecasts
        )
    }
    
    private func createDayDescriptions(model: WeatherForecastModel) -> PartOfTheDayDescription {
        // Properties used to build PartOfTheDayDescription
        var daysMaxTemp = [Int]()
        var weekDaysForDayTimeForecasts = [String]()
        var iconNamesForDayTimeForecasts = [String]()
        
        let (datesArray, _) = createsForecastsDatesAndUniqueDaysArrays(model: model)
        let (_, uniqueDays) = createsForecastsDatesAndUniqueDaysArrays(model: model)
        
        // Properties used in the ForLoop for storing temporary data.
        var dayIndexes = [Int]()
        var dayTemps = [Int]()
        var weekDay = [String]()
        var weatherDescriptions = [String]()
        
        for day in uniqueDays {
            
            // Get the indexes of forecasts for a day at a time
            dayIndexes.removeAll()
            for (index, date) in datesArray.enumerated() {
                if day == date {
                    dayIndexes.append(index)
                }
            }
            
            dayTemps.removeAll()
            weekDay.removeAll()
            weatherDescriptions.removeAll()
            for dayIndex in dayIndexes {
                if model.list[dayIndex].sys.partOfTheDay == "d" {
                    
                    // Append he maximum temperature for day time
                    dayTemps.append(Int(model.list[dayIndex].main.tempMax.celsiusFromKelvinValue))
                    
                    // Append only one weekDay name (its gonna be the same for all forecasts for a particular day)
                    if weekDay.count == 0 {
                        let currentWeekDay = model.list[dayIndex].weekDay
                        weekDay.append(currentWeekDay)
                    }
                    
                    // Append the weather descriptions for all forecasts of the day
                    weatherDescriptions.append(model.list[dayIndex].weather[0].description)
                    
                }
            }
            
            // After collecting data from the forecasts for a day, only the max temperature, the unduplicated week name and one icon name will be added to the arrays that will be returned.

            if dayTemps.count >= 1 {
                daysMaxTemp.append(dayTemps.max() ?? 0)
            }
            
            if weekDay.count == 1 {
                weekDaysForDayTimeForecasts.append(weekDay[0])
            }
            
            if weatherDescriptions.count >= 1 {
                let iconName = determineWeatherIconsNames(description: weatherDescriptions[0], isDayTime: true)
                iconNamesForDayTimeForecasts.append(iconName)
            }
        }
        
        return PartOfTheDayDescription(
            temperatures: daysMaxTemp,
            weekDays: weekDaysForDayTimeForecasts,
            iconNames: iconNamesForDayTimeForecasts)
    }
    
    /// Creates a tuple with arrays used for day descriptions and night descriptions for populating weekly forecast graph.
    ///
    /// - Parameters:
    ///  - model: the model used for decoding data from Weather Forecast endpoint
    /// - Returns:
    /// Returns a tuple  ([Int], [Int]), where:
    /// - First element is the datesArray with repetitions for each day, the repetitions represents the forecasts received for a specific day (up to 8 forecasts a day);
    /// - Second element is the uniqueDays - an array with dates without repetitions, maintaining the order from datesArray.
    private func createsForecastsDatesAndUniqueDaysArrays(model: WeatherForecastModel) -> ([Int], [Int]) {
        let datesArray = model.list.map { element in
            let restoredDate = Date(timeIntervalSince1970: TimeInterval(element.unixTimeStamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            let dayString = dateFormatter.string(from: restoredDate)
            return Int(dayString) ?? 0
        }
        
        let uniqueDays = OrderedSet(datesArray).elements
        
        return (datesArray, uniqueDays)
    }
    
    private func determineWeatherIconsNames(description: String, isDayTime: Bool) -> String {
        if description.contains("clouds") {
            if description.contains("few clouds") {
                return isDayTime ? WeatherIconsString.dayFewClouds : WeatherIconsString.nightFewClouds
            } else {
                return WeatherIconsString.clouds
            }
        } else if description.contains("clear sky") {
            return isDayTime ? WeatherIconsString.dayClearSky : WeatherIconsString.nightClearSky
        } else if description.contains("rain") {
            if description.contains("shower") {
                return WeatherIconsString.showerRain
            } else {
                return isDayTime ? WeatherIconsString.dayRain : WeatherIconsString.nightRain
            }
        } else if description.contains("thunderstorm") {
            return WeatherIconsString.thunderstorm
        } else if description.contains("snow") {
            return WeatherIconsString.snow
        } else if description.contains("drizzle") {
            return WeatherIconsString.drizzle
        } else if description.contains("smoke") || description.contains("mist") || description.contains("haze") || description.contains("ash") || description.contains("dust") || description.contains("tornado") || description.contains("squalls") || description.contains("sleet") {
            return isDayTime ? WeatherIconsString.daysmoke : WeatherIconsString.nightSmoke
        }
        
        return isDayTime ? WeatherIconsString.dayClearSky : WeatherIconsString.nightClearSky
    }
    
    private func createForecastedWeekDays(weekDaysForDayTime: [String], weekDaysForNightTime: [String]) -> [String] {
        // Populating forecastedWeekDays so we could use it later for constructing models with nil values for temp, day, icon arrays if there are no forecasts for that specific part of the day : day/night
        
        var forecastedWeekDays = [String]()
        
        if weekDaysForDayTime[0] == weekDaysForNightTime[0] {
            if weekDaysForDayTime.count > weekDaysForNightTime.count ||
                weekDaysForDayTime.count == weekDaysForNightTime.count {
                forecastedWeekDays = weekDaysForDayTime
            } else if weekDaysForDayTime.count < weekDaysForNightTime.count {
                forecastedWeekDays = weekDaysForNightTime
            }
        } else if weekDaysForDayTime[0] == weekDaysForNightTime[1] {
            forecastedWeekDays.append(weekDaysForNightTime[0])
            for day in weekDaysForDayTime {
                forecastedWeekDays.append(day)
            }
        } else if weekDaysForDayTime[1] == weekDaysForNightTime[0] {
            forecastedWeekDays.append(weekDaysForDayTime[0])
            for day in weekDaysForNightTime {
                forecastedWeekDays.append(day)
            }
            print("Error: weekDaysForDayTimeForecasts[1] == weekDaysForNightTimeForecasts[0] ")
        }
        
        return forecastedWeekDays
    }
}

struct DailyForecast: Identifiable {
    var id = UUID()
    var dayTimeWeekDay: String?
    var dayTimeTemp: Int?
    var dayTimeIcon: String?
    var nightTimeWeekDay: String?
    var nightTimeTemp: Int?
    var nightTimeIcon: String?
}

struct PartOfTheDayDescription {
    var temperatures: [Int]
    var weekDays: [String]
    var iconNames: [String]
}
