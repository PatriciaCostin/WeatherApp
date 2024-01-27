//
//  WeatherForecastModel.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import Foundation

struct WeatherForecastModel: Codable {
    var cod: String
    var message: Int
    var cnt: Int
    var list: [WeatherForHour]
    var city: CityDetails
}

struct WeatherForHour: Codable {
    var unixTimeStamp: Int
    var main: WeatherForHourDetails
    var weather: [WeatherDescriptors]
    var clouds: CloudsDetails
    var wind: WindDetails
    var visibility: Int
    var precipitations: Double
    var rain: Rain?
    var sys: PartOfTheDay
    var timeOfDataForecasted: String
    
    enum CodingKeys: String, CodingKey, Codable {
        case unixTimeStamp = "dt"
        case main
        case weather
        case clouds
        case wind
        case visibility
        case precipitations = "pop"
        case rain
        case sys
        case timeOfDataForecasted = "dt_txt"
    }
    
    var weekDay: String {
        let restoredDate = Date(timeIntervalSince1970: TimeInterval(unixTimeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: restoredDate)
    }
    
    var isDay: Bool {
        sys.partOfTheDay == "d"
    }
    
    var isNight: Bool {
        sys.partOfTheDay == "n"
    }
}

struct WeatherForHourDetails: Codable {
    var temp: Double
    var feelsLike: Double
    var tempMin: Double
    var tempMax: Double
    var pressure: Int
    var seaLevel: Int?
    var groundLevel: Int?
    var humidity: Int
    var tempKF: Double?
    
    enum CodingKeys: String, CodingKey, Codable {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
        case humidity
        case tempKF = "temp_kf"
    }
}

struct WeatherDescriptors: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct CloudsDetails: Codable {
    var all: Int
}

struct WindDetails: Codable {
    var speed: Double
    var degreesDirection: Int
    var gust: Double?
    
    enum CodingKeys: String, CodingKey, Codable {
        case speed
        case degreesDirection = "deg"
        case gust
    }
}

struct PartOfTheDay: Codable {
    var partOfTheDay: String
    
    enum CodingKeys: String, CodingKey, Codable {
        case partOfTheDay = "pod"
    }
}

struct CityDetails: Codable {
    var id: Int
    var name: String
    var coord: Coordinates
    var country: String
    var population: Int
    var timezone: Int
    var sunrise: Int
    var sunset: Int
}

struct Coordinates: Codable {
    var lat: Double
    var lon: Double
}

struct Rain: Codable {
    var rain: Double
    
    enum CodingKeys: String, CodingKey, Codable {
        case rain = "3h"
    }
}
