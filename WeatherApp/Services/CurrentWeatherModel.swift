//
//  CurrentWeatherModel.swift
//  WeatherApp
//
//  Created by Patricia Costin on 01.01.2024.
//


struct CurrentWeatherModel: Codable {
    var coord: Coordinates
    var weather: [WeatherDescriptors]
    var base: String
    var main: WeatherForHourDetails
    var visibility: Int
    var wind: WindDetails
    var rain: RainProbability?
    var clouds: CloudsDetails
    var dt: Int
    var sys: InternalParameters
    var timezone: Int
    var id: Int
    var name: String
    var cod: Int
}

struct RainProbability: Codable {
    var oneHour: Double
    
    enum CodingKeys: String, CodingKey, Codable {
        case oneHour = "1h"
    }
}

struct InternalParameters: Codable {
    var type: Int
    var id: Int
    var country: String
    var sunrise: Int
    var sunset: Int
}
