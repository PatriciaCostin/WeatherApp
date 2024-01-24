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


@MainActor
class TrialViewModel: ObservableObject {
    struct DataPoint: Identifiable {
        var id = UUID()
        var temp: Int
        var hour: String
    }
    
    @Published var models: [DataPoint] = []
    @Published var daysArray: [Int] = []
    
    @Published var weatherModels: [WeekDayForecast] = []
    private let currentWeather = WeatherServiceImp()
    
    private let hoursArray = ["11", "12", "13", "14", "15", "16"]
    
    private let temperatureArray = ["-5", "-4", "-3", "-3", "-3", "-5"]
    
    func loadModel() {
        models = createModel(hoursArray: hoursArray, temperatureArray: temperatureArray)
    }
    
    func createModel(hoursArray: [String], temperatureArray: [String]) -> [DataPoint] {
        for index in 0..<hoursArray.count {
            let tempInt = Int(temperatureArray[index]) ?? 0
            models.append(DataPoint(temp: tempInt, hour: hoursArray[index]))
        }
        
        return models
    }
    
    func getHourlyForecastForUserLocation() async throws {
        //  let locationResult = await LocationService.shared.getLocation()
        let locationResult = LocationService.LocationResult.authorized(CLLocation(latitude: 47.0105, longitude: 28.8638))
        switch locationResult {
        case .authorized(let cLLocation):
            let lat = String(cLLocation.coordinate.latitude)
            let lon = String(cLLocation.coordinate.longitude)
            let model = try await self.currentWeather.fetchWeatherForecast(lat: lat, lon: lon)
            //            daysArray = createDatesArray(model: model)
            //            print(daysArray)
            print("Day \(createDayDescriptionsArrays(model: model))")
            print("Night \(createNightDescriptionsArrays(model: model))")
            
            let day = createDayDescriptionsArrays(model: model)
            let night = createNightDescriptionsArrays(model: model)
            
            weatherModels = createWeekDayForecastsModels(dayDescriptions: day, nightDescriptions: night)
            //            print(createWeekDayForecastsModels(dayDescriptions: day, nightDescriptions: night))
        case .userDenied:
            throw "User denied"
        case .osRestricted:
            throw "Restricted"
        case .failed(let error):
            throw "Failed \(error)"
        }
    }
    
    func createWeekDayForecastsModels(
        dayDescriptions: PartOfTheDayDescription,
        nightDescriptions: PartOfTheDayDescription
    ) -> [WeekDayForecast] {
            var weekDaysForecasts = [WeekDayForecast]()
            var forecastedWeekDays = [String]()
            
            let nightMinTemp = nightDescriptions.tempArray
            let weekDaysForNightTimeForecasts = nightDescriptions.weekDays
            let iconNamesForNightTimeForecasts = nightDescriptions.iconNames
            let alteratedNightTempArray = nightDescriptions.alteratedTempArray
            
            let daysMaxTemp = dayDescriptions.tempArray
            let weekDaysForDayTimeForecasts = dayDescriptions.weekDays
            let iconNamesForDayTimeForecasts = dayDescriptions.iconNames
            
        // Populating forecastedWeekDays so we could use it later for constructing models with nil values for temp, day, icon arrays if there are no forecasts for that specific part of the day : day/night
            if weekDaysForDayTimeForecasts[0] == weekDaysForNightTimeForecasts[0] {
                if weekDaysForDayTimeForecasts.count > weekDaysForNightTimeForecasts.count ||
                    weekDaysForDayTimeForecasts.count == weekDaysForNightTimeForecasts.count {
                    forecastedWeekDays = weekDaysForDayTimeForecasts
                } else if weekDaysForDayTimeForecasts.count < weekDaysForNightTimeForecasts.count {
                    forecastedWeekDays = weekDaysForNightTimeForecasts
                }
            } else if weekDaysForDayTimeForecasts[0] == weekDaysForNightTimeForecasts[1] {
                forecastedWeekDays.append(weekDaysForNightTimeForecasts[0])
                for day in weekDaysForDayTimeForecasts {
                    forecastedWeekDays.append(day)
                }
            } else if weekDaysForDayTimeForecasts[1] == weekDaysForNightTimeForecasts[0] {
                print("Error: weekDaysForDayTimeForecasts[1] == weekDaysForNightTimeForecasts[0] ")
            }
            
            for (index, weekDay) in forecastedWeekDays.enumerated() {
                let dayIndex = weekDaysForDayTimeForecasts.firstIndex(of: weekDay) ?? 0
                let nightIndex = weekDaysForNightTimeForecasts.firstIndex(of: weekDay) ?? 0
                
                if weekDaysForDayTimeForecasts.contains(forecastedWeekDays[index]) &&
                    weekDaysForNightTimeForecasts.contains(forecastedWeekDays[index]) {
                    let model = WeekDayForecast(
                        dayTimeWeekDay: weekDaysForDayTimeForecasts[dayIndex],
                        dayTimeTemp: daysMaxTemp[dayIndex],
                        dayTimeIncon: iconNamesForDayTimeForecasts[dayIndex],
                        nightTimeWeekDat: weekDaysForNightTimeForecasts[nightIndex],
                        nightTimeTemp: nightMinTemp[nightIndex],
                        nightTimeIcon: iconNamesForNightTimeForecasts[nightIndex],
                        ateratedNightTimeTemp: alteratedNightTempArray![nightIndex]
                    )
                    weekDaysForecasts.append(model)
                } else if !weekDaysForDayTimeForecasts.contains(forecastedWeekDays[index]) &&
                            weekDaysForNightTimeForecasts.contains(forecastedWeekDays[index]) {
                    let model = WeekDayForecast(
                        dayTimeWeekDay: nil,
                        dayTimeTemp: nil,
                        dayTimeIncon: nil,
                        nightTimeWeekDat: weekDaysForNightTimeForecasts[nightIndex],
                        nightTimeTemp: nightMinTemp[nightIndex],
                        nightTimeIcon: iconNamesForNightTimeForecasts[nightIndex],
                        ateratedNightTimeTemp: alteratedNightTempArray![nightIndex]
                    )
                    weekDaysForecasts.append(model)
                } else if weekDaysForDayTimeForecasts.contains(forecastedWeekDays[index]) &&
                            !weekDaysForNightTimeForecasts.contains(forecastedWeekDays[index]) {
                    let model = WeekDayForecast(
                        dayTimeWeekDay: weekDaysForDayTimeForecasts[dayIndex],
                        dayTimeTemp: daysMaxTemp[dayIndex],
                        dayTimeIncon: iconNamesForDayTimeForecasts[dayIndex],
                        nightTimeWeekDat: nil,
                        nightTimeTemp: nil,
                        nightTimeIcon: nil,
                        ateratedNightTimeTemp: nil
                    )
                    weekDaysForecasts.append(model)
                }
            }
            return weekDaysForecasts
        }
    
    func createNightDescriptionsArrays(model: WeatherForecastModel) -> PartOfTheDayDescription {
        // Properties to be returned
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
                        let currentWeekDay = extractWeekDayFromTimestamp(model: model.list, index: dayIndex)
                        weekDay.append(currentWeekDay)
                    }
                    
                    // Append the weather descriptions for all forecasts of the night
                    weatherDescriptions.append(model.list[dayIndex].weather[0].description)
                    
                }
            }
            
            // After collecting data from the forecasts for a night, only the min temperature, the unduplicated week name and one icon name will be added to the arrays that will be returned.
            
            nightMinTemp.append(dayTemps.min() ?? 0)
            
            if weekDay.count == 1 {
                weekDaysForNightTimeForecasts.append(weekDay[0])
            }
            
            if weatherDescriptions.count >= 1 {
                let iconName = determineWeatherIconsNames(description: weatherDescriptions[0], isDayTime: true)
                iconNamesForNightTimeForecasts.append(iconName)
            }
        }
        
        let alteratedTempArray = nightMinTemp.map { $0 - 6 }
        
        return PartOfTheDayDescription(
            tempArray: nightMinTemp,
            weekDays: weekDaysForNightTimeForecasts, 
            iconNames: iconNamesForNightTimeForecasts,
            alteratedTempArray: alteratedTempArray
        )
    }
    
    func createDayDescriptionsArrays(model: WeatherForecastModel) -> PartOfTheDayDescription {
        // Properties to be returned
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
                        let currentWeekDay = extractWeekDayFromTimestamp(model: model.list, index: dayIndex)
                        weekDay.append(currentWeekDay)
                    }
                    
                    // Append the weather descriptions for all forecasts of the day
                    weatherDescriptions.append(model.list[dayIndex].weather[0].description)
                    
                }
            }
            
            // After collecting data from the forecasts for a day, only the max temperature, the unduplicated week name and one icon name will be added to the arrays that will be returned.
            
            daysMaxTemp.append(dayTemps.max() ?? 0)
            
            if weekDay.count == 1 {
                weekDaysForDayTimeForecasts.append(weekDay[0])
            }
            
            if weatherDescriptions.count >= 1 {
                let iconName = determineWeatherIconsNames(description: weatherDescriptions[0], isDayTime: true)
                iconNamesForDayTimeForecasts.append(iconName)
            }
        }
        return PartOfTheDayDescription(
            tempArray: daysMaxTemp,
            weekDays: weekDaysForDayTimeForecasts,
            iconNames: iconNamesForDayTimeForecasts)
     
    }
    
    func createsForecastsDatesAndUniqueDaysArrays(model: WeatherForecastModel) -> ([Int], [Int]) {
        // There are up to 8 forecasts for a day and the repeating number in the datesArray tells how many forecasts do we have for a day
        var datesArray = [Int]()
        for element in model.list {
            let restoredDate = Date(timeIntervalSince1970: TimeInterval(element.unixTimeStamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            let dayString = dateFormatter.string(from: restoredDate)
            let dayInt = Int(dayString) ?? 0
            datesArray.append(dayInt)
        }
        
        // uniqueDays is an array with excluded repetitions from datesArray with mentained order.
        var uniqueDays = [Int]()
        var datesSet = Set<Int>()
        
        for date in datesArray {
            if !datesSet.contains(date) {
                uniqueDays.append(date)
                datesSet.insert(date)
            }
        }
        return (datesArray, uniqueDays)
    }
    
    func extractWeekDayFromTimestamp(model: [WeatherForHour], index: Int) -> String {
        let restoredDate = Date(timeIntervalSince1970: TimeInterval(model[index].unixTimeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: restoredDate)
        
    }
    
    private func determineWeatherIconsNames(description: String, isDayTime: Bool) -> String {
        if description.contains("clouds") {
            if description.contains("few clouds") {
                if isDayTime {
                    return WeatherIconsString.dayFewClouds
                } else {
                    return WeatherIconsString.nightFewClouds
                }
            } else {
                return WeatherIconsString.clouds
            }
        } else if description.contains("clear sky") {
            if isDayTime {
                return WeatherIconsString.dayClearSky
            } else {
                return WeatherIconsString.nightClearSky
            }
        } else if description.contains("rain") {
            if description.contains("shower") {
                return WeatherIconsString.showerRain
            } else {
                if isDayTime {
                    return WeatherIconsString.dayRain
                } else {
                    return WeatherIconsString.nightRain
                }
            }
        }
        else if description.contains("thunderstorm") {
            return WeatherIconsString.thunderstorm
        } else if description.contains("snow") {
            return WeatherIconsString.snow
        } else if description.contains("drizzle") {
            return WeatherIconsString.drizzle
        } else if description.contains("smoke")
                    || description.contains("mist")
                    || description.contains("haze")
                    || description.contains("ash")
                    || description.contains("dust")
                    || description.contains("tornado")
                    || description.contains("squalls")
                    || description.contains("sleet") {
            if isDayTime {
                return WeatherIconsString.daysmoke
            } else {
                return WeatherIconsString.nightSmoke
            }
        }
        if isDayTime {
            return WeatherIconsString.dayClearSky
        } else {
            return WeatherIconsString.nightClearSky
        }
    }
}

struct WeekDayForecast: Identifiable {
    var id = UUID()
    var dayTimeWeekDay: String?
    var dayTimeTemp: Int?
    var dayTimeIncon: String?
    var nightTimeWeekDat: String?
    var nightTimeTemp: Int?
    var nightTimeIcon: String?
    var ateratedNightTimeTemp: Int?
}

struct PartOfTheDayDescription {
    var tempArray: [Int]
    var weekDays: [String]
    var iconNames: [String]
    var alteratedTempArray: [Int]?
}
