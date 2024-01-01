//
//  WheatherEndpoint.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import UIKit

enum WeatherEndpoint {
    case weatherForecast
    
    var endPoint: URL? {
        switch self {
        case .weatherForecast:
            let baseURL = WeatherAPIConfig.baseURL
            let accessKey = WeatherAPIConfig.accessKey
            let urlString = "\(baseURL)/data/2.5/forecast?lat=47.0105&lon=28.8638&appid=\(accessKey)"
            return URL(string: urlString)
        }
    }
}
