//
//  TrialViewModel.swift
//  WeatherApp
//
//  Created by Patricia Costin on 23.01.2024.
//

import Foundation
import SwiftUI
import CoreLocation
import Collections


@MainActor
class WeeklyForecastViewModel: ObservableObject {
    @Published var weatherModels: [DailyForecast] = []
    @Published var firstWeatherModel: DailyForecast?
    private let weatherService = WeatherServiceImp()
    var index = 0 {
        didSet {
            if index < weatherModels.count {
                firstWeatherModel = weatherModels[index]
            } else {
                firstWeatherModel = nil
            }
        }
    }
    
    func getWeeklyForecastForUserLocation() async throws {
        let locationResult = await LocationService.shared.getLocation()
        //let locationResult = LocationService.LocationResult.authorized(CLLocation(latitude: 47.0105, longitude: 28.8638))
        switch locationResult {
        case .authorized(let cLLocation):
            let lat = String(cLLocation.coordinate.latitude)
            let lon = String(cLLocation.coordinate.longitude)
            let model = try await self.weatherService.fetchWeatherForecast(lat: lat, lon: lon)
            let day = createDayDescriptions(model: model)
            let night = createNightDescriptions(model: model)
            weatherModels = createDailyForecasts(dayDescriptions: day, nightDescriptions: night)
            firstWeatherModel = weatherModels.first
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
        var alteredNightTemperatures = [Int]()
        let nightHumidityForecasts = nightDescriptions.humidity
        let nightPressureForecasts = nightDescriptions.pressure
        let nightWindSpeedForecasts = nightDescriptions.windSpeed
        let nightVisibilityForecasts = nightDescriptions.visibility
        let nightCloudinessForecasts = nightDescriptions.cloudiness
        let nightPosibilityOfPrecipitationForecast = nightDescriptions.posibilityOfPrecipitation
        
        let daysMaxTemperatures = dayDescriptions.temperatures
        let weekDaysForDayTimeForecasts = dayDescriptions.weekDays
        let iconNamesForDayTimeForecasts = dayDescriptions.iconNames
        var alteredDayTemperatures = [Int]()
        let dayHumidityForecasts = dayDescriptions.humidity
        let dayPressureForecasts = dayDescriptions.pressure
        let dayWindSpeedForecasts = dayDescriptions.windSpeed
        let dayVisibilityForecasts = dayDescriptions.visibility
        let dayCloudinessForecasts = dayDescriptions.cloudiness
        let dayPosibilityOfPrecipitationForecast = dayDescriptions.posibilityOfPrecipitation
        
        //If dayTime and nightTime temperatures are all above 0, we should alter the values by extracting from each values the lowest temperature so our graph could have the lowest temperatures at the bottom. If we don't do so, the views for each forecast will be displayed at some distance from the bottom, because they are greater than 0.
        let allTemperatures = daysMaxTemperatures + nightMinTemperatures
        
        if allTemperatures.count == allTemperatures.filter({ $0 > 0}).count {
            alteredDayTemperatures = daysMaxTemperatures.map { $0 - (allTemperatures.min() ?? 0)}
            alteredNightTemperatures = nightMinTemperatures.map { $0 - (allTemperatures.min() ?? 0)}
        } else {
            alteredDayTemperatures = daysMaxTemperatures
            alteredNightTemperatures = nightMinTemperatures
        }
        
        let forecastedWeekDays = createForecastedWeekDays(
            weekDaysForDayTime: weekDaysForDayTimeForecasts,
            weekDaysForNightTime: weekDaysForNightTimeForecasts
        )
        
        return forecastedWeekDays.map { weekDay in
            let dayIndex = weekDaysForDayTimeForecasts.firstIndex(of: weekDay) ?? 0
            let nightIndex = weekDaysForNightTimeForecasts.firstIndex(of: weekDay) ?? 0
            
            if weekDaysForDayTimeForecasts.contains(weekDay) &&
                weekDaysForNightTimeForecasts.contains(weekDay) {
                return DailyForecast(
                    dayTimeWeekDay: weekDaysForDayTimeForecasts[dayIndex],
                    dayTimeTemp: daysMaxTemperatures[dayIndex],
                    dayTimeIcon: iconNamesForDayTimeForecasts[dayIndex],
                    alteredDayTimeTemp: alteredDayTemperatures[dayIndex],
                    nightTimeWeekDay: weekDaysForNightTimeForecasts[nightIndex],
                    nightTimeTemp: nightMinTemperatures[nightIndex],
                    nightTimeIcon: iconNamesForNightTimeForecasts[nightIndex],
                    alteredNightTimeTemp: alteredNightTemperatures[nightIndex],
                    humidity: dayHumidityForecasts[dayIndex],
                    pressure: dayPressureForecasts[dayIndex],
                    windSpeed: dayWindSpeedForecasts[dayIndex],
                    visibility: dayVisibilityForecasts[dayIndex],
                    cloudiness: dayCloudinessForecasts[dayIndex],
                    posibilityOfPrecipitation: dayPosibilityOfPrecipitationForecast[dayIndex]
                )
            } else if !weekDaysForDayTimeForecasts.contains(weekDay) &&
                        weekDaysForNightTimeForecasts.contains(weekDay) {
                return DailyForecast(
                    dayTimeWeekDay: nil,
                    dayTimeTemp: nil,
                    dayTimeIcon: nil,
                    alteredDayTimeTemp: nil,
                    nightTimeWeekDay: weekDaysForNightTimeForecasts[nightIndex],
                    nightTimeTemp: nightMinTemperatures[nightIndex],
                    nightTimeIcon: iconNamesForNightTimeForecasts[nightIndex],
                    alteredNightTimeTemp: alteredNightTemperatures[nightIndex],
                    humidity: nightHumidityForecasts[nightIndex],
                    pressure: nightPressureForecasts[nightIndex],
                    windSpeed: nightWindSpeedForecasts[nightIndex],
                    visibility: nightVisibilityForecasts[nightIndex],
                    cloudiness: nightCloudinessForecasts[nightIndex],
                    posibilityOfPrecipitation: nightPosibilityOfPrecipitationForecast[nightIndex]
                )
            } else if weekDaysForDayTimeForecasts.contains(weekDay) &&
                        !weekDaysForNightTimeForecasts.contains(weekDay) {
                return DailyForecast(
                    dayTimeWeekDay: weekDaysForDayTimeForecasts[dayIndex],
                    dayTimeTemp: daysMaxTemperatures[dayIndex],
                    dayTimeIcon: iconNamesForDayTimeForecasts[dayIndex],
                    alteredDayTimeTemp: alteredDayTemperatures[dayIndex],
                    nightTimeWeekDay: nil,
                    nightTimeTemp: nil,
                    nightTimeIcon: nil,
                    alteredNightTimeTemp: nil,
                    humidity: dayHumidityForecasts[dayIndex],
                    pressure: dayPressureForecasts[dayIndex],
                    windSpeed: dayWindSpeedForecasts[dayIndex],
                    visibility: dayVisibilityForecasts[dayIndex],
                    cloudiness: dayCloudinessForecasts[dayIndex],
                    posibilityOfPrecipitation: dayPosibilityOfPrecipitationForecast[dayIndex]
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
        var humidityForecasts = [Int]()
        var windSpeedForecasts = [Double]()
        var visibilityForecasts = [Int]()
        var pressureForecasts = [Int]()
        var cloudinessForecasts = [Int]()
        var posibilityOfPrecipitationForecasts = [Double]()
        
        let (datesArray, uniqueDays) = createsForecastsDatesAndUniqueDaysArrays(model: model)
        
        for day in uniqueDays {
            // Get the indices of forecasts for a day at a time
            let dayIndices = datesArray.indices(matching: day)
            
            // Properties used in the ForLoop for storing temporary data.
            var dayTemps = [Int]()
            var weekDays = [String]()
            var weatherDescriptions = [String]()
            var humidity = [Int]()
            var windSpeed = [Double]()
            var visibility = [Int]()
            var pressure = [Int]()
            var cloudiness = [Int]()
            var posibilityOfPrecipitation = [Double]()
            
            for dayIndex in dayIndices {
                if model.list[dayIndex].isNight {
                    // Append the minimum temperature for night time
                    dayTemps.append(Int(model.list[dayIndex].main.tempMin.celsiusFromKelvinValue))

                    // Append only one weekDay name (its gonna be the same for all forecasts for a particular night)
                    if weekDays.count == 0 {
                        let currentWeekDay = model.list[dayIndex].weekDay
                        weekDays.append(currentWeekDay)
                    }
                    
                    // Append the weather descriptions for all forecasts of the night
                    weatherDescriptions.append(model.list[dayIndex].weather[0].description)
                    
                    humidity.append(model.list[dayIndex].main.humidity)
                    windSpeed.append(model.list[dayIndex].wind.speed)
                    visibility.append(model.list[dayIndex].visibility)
                    pressure.append(model.list[dayIndex].main.pressure)
                    cloudiness.append(model.list[dayIndex].clouds.all)
                    posibilityOfPrecipitation.append(model.list[dayIndex].rain?.rain ?? 0.0)
                }
            }
            
            if   weatherDescriptions.count >= 1 {
                let iconName = determineWeatherIconsNames(description: weatherDescriptions[0], isDayTime: false)
                iconNamesForNightTimeForecasts.append(iconName)
                
                nightMinTemp.append(dayTemps.min() ?? 0)
                humidityForecasts.append(humidity.average())
                windSpeedForecasts.append(windSpeed.average())
                visibilityForecasts.append(visibility.average())
                pressureForecasts.append(pressure.average())
                cloudinessForecasts.append(cloudiness.max() ?? 0)
                posibilityOfPrecipitationForecasts.append(posibilityOfPrecipitation.max() ?? 0)
                
                if weekDays.count == 1 {
                    weekDaysForNightTimeForecasts.append(weekDays[0])
                }
            }
        }
        
        return PartOfTheDayDescription(
            temperatures: nightMinTemp,
            weekDays: weekDaysForNightTimeForecasts,
            iconNames: iconNamesForNightTimeForecasts,
            humidity: humidityForecasts,
            pressure: pressureForecasts,
            windSpeed: windSpeedForecasts,
            visibility: visibilityForecasts,
            cloudiness: cloudinessForecasts,
            posibilityOfPrecipitation: posibilityOfPrecipitationForecasts
        )
    }
    
    private func createDayDescriptions(model: WeatherForecastModel) -> PartOfTheDayDescription {
        // Properties used to build PartOfTheDayDescription
        var daysMaxTemp = [Int]()
        var weekDaysForDayTimeForecasts = [String]()
        var iconNamesForDayTimeForecasts = [String]()
        var humidityForecasts = [Int]()
        var windSpeedForecasts = [Double]()
        var visibilityForecasts = [Int]()
        var pressureForecasts = [Int]()
        var cloudinessForecasts = [Int]()
        var posibilityOfPrecipitationForecasts = [Double]()
        
        let (datesArray, uniqueDays) = createsForecastsDatesAndUniqueDaysArrays(model: model)
        
        // Properties used in the ForLoop for storing temporary data.
       
        
        for day in uniqueDays {
            // Get the indices of forecasts for a day at a time
            let dayIndices = datesArray.indices(matching: day)
            
            var dayTemps = [Int]()
            var weekDay = [String]()
            var weatherDescriptions = [String]()
            var humidity = [Int]()
            var windSpeed = [Double]()
            var visibility = [Int]()
            var pressure = [Int]()
            var cloudiness = [Int]()
            var posibilityOfPrecipitation = [Double]()
    
            for dayIndex in dayIndices {
                if model.list[dayIndex].sys.partOfTheDay == "d" {
                    
                    // Append the maximum temperature for day time
                    dayTemps.append(Int(model.list[dayIndex].main.tempMax.celsiusFromKelvinValue))
                    
                    // Append only one weekDay name (its gonna be the same for all forecasts for a particular day)
                    if weekDay.count == 0 {
                        let currentWeekDay = model.list[dayIndex].weekDay
                        weekDay.append(currentWeekDay)
                    }
                    
                    // Append the weather descriptions for all forecasts of the day
                    weatherDescriptions.append(model.list[dayIndex].weather[0].description)
                    
                    humidity.append(model.list[dayIndex].main.humidity)
                    windSpeed.append(model.list[dayIndex].wind.speed)
                    visibility.append(model.list[dayIndex].visibility)
                    pressure.append(model.list[dayIndex].main.pressure)
                    cloudiness.append(model.list[dayIndex].clouds.all)
                    posibilityOfPrecipitation.append(model.list[dayIndex].rain?.rain ?? 0.0)
                    
                }
            }
          
            if weatherDescriptions.count >= 1 {
                
                let iconName = determineWeatherIconsNames(description: weatherDescriptions[0], isDayTime: true)
                iconNamesForDayTimeForecasts.append(iconName)
                
                daysMaxTemp.append(dayTemps.max() ?? 0)
                humidityForecasts.append(humidity.average())
                windSpeedForecasts.append(windSpeed.average())
                visibilityForecasts.append(visibility.average())
                pressureForecasts.append(pressure.average())
                cloudinessForecasts.append(cloudiness.max() ?? 0)
                posibilityOfPrecipitationForecasts.append(posibilityOfPrecipitation.max() ?? 0)
            }
            
            if weekDay.count == 1 {
                weekDaysForDayTimeForecasts.append(weekDay[0])
            }
        }
        
        return PartOfTheDayDescription(
            temperatures: daysMaxTemp,
            weekDays: weekDaysForDayTimeForecasts,
            iconNames: iconNamesForDayTimeForecasts,
            humidity: humidityForecasts,
            pressure: pressureForecasts,
            windSpeed: windSpeedForecasts,
            visibility: visibilityForecasts,
            cloudiness: cloudinessForecasts,
            posibilityOfPrecipitation: posibilityOfPrecipitationForecasts
        )
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
        }
        
        return forecastedWeekDays
    }
}

struct DailyForecast: Identifiable {
    var id = UUID()
    var dayTimeWeekDay: String?
    var dayTimeTemp: Int?
    var dayTimeIcon: String?
    var alteredDayTimeTemp: Int?
    var nightTimeWeekDay: String?
    var nightTimeTemp: Int?
    var nightTimeIcon: String?
    var alteredNightTimeTemp: Int?
    var humidity: Int?
    var pressure: Int?
    var windSpeed: Double?
    var visibility: Int?
    var cloudiness: Int?
    var posibilityOfPrecipitation: Double?
}

struct PartOfTheDayDescription {
    var temperatures: [Int]
    var weekDays: [String]
    var iconNames: [String]
    var humidity: [Int]
    var pressure: [Int]
    var windSpeed: [Double]
    var visibility: [Int]
    var cloudiness: [Int]
    var posibilityOfPrecipitation: [Double]
}

