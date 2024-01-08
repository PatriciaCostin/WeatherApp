//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Patricia Costin on 14.01.2024.
//

import XCTest
@testable import WeatherApp

@MainActor
final class WeatherAppTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInterpolation() async throws {
        let viewModel = ViewModel()
        let mockWeatherService = WeatherServiceMock()
        
        let forecast = try await mockWeatherService.fetchWeatherForecast(lat: "0", lon: "0")
        let result = try? viewModel.interpolateHourlyWeatherData(model: forecast)
        
        let expectedResult = [
            HourlyWeatherModel(hour: "11",weatherIcon: "cloud.sun.fill" , temperature: "-5"),
            HourlyWeatherModel(hour: "12", weatherIcon: "cloud.sun.fill", temperature: "-4"),
            HourlyWeatherModel(hour: "13", weatherIcon: "cloud.sun.fill", temperature: "-3"),
            HourlyWeatherModel(hour: "14", weatherIcon: "cloud.fill", temperature: "-3"),
            HourlyWeatherModel(hour: "15", weatherIcon: "cloud.fill", temperature: "-3"),
            HourlyWeatherModel(hour: "16", weatherIcon: "cloud.fill", temperature: "-4"),
            HourlyWeatherModel(hour: "17", weatherIcon: "cloud.fill", temperature: "-5"),
            HourlyWeatherModel(hour: "18", weatherIcon: "cloud.fill", temperature: "-6"),
            HourlyWeatherModel(hour: "19", weatherIcon: "cloud.fill", temperature: "-7"),
            HourlyWeatherModel(hour: "20", weatherIcon: "cloud.fill", temperature: "-8"),
            HourlyWeatherModel(hour: "21", weatherIcon: "cloud.fill", temperature: "-9"),
            HourlyWeatherModel(hour: "22", weatherIcon: "cloud.fill", temperature: "-9"),
            HourlyWeatherModel(hour: "23", weatherIcon: "cloud.moon.fill", temperature: "-9"),
            HourlyWeatherModel(hour: "00", weatherIcon: "cloud.moon.fill", temperature: "-9"),
            HourlyWeatherModel(hour: "01", weatherIcon: "cloud.moon.fill", temperature: "-8"),
            HourlyWeatherModel(hour: "02", weatherIcon: "cloud.moon.fill", temperature: "-8"),
            HourlyWeatherModel(hour: "03", weatherIcon: "cloud.moon.fill", temperature: "-8"),
            HourlyWeatherModel(hour: "04", weatherIcon: "cloud.moon.fill", temperature: "-8"),
            HourlyWeatherModel(hour: "05", weatherIcon: "cloud.fill", temperature: "-8"),
            HourlyWeatherModel(hour: "06", weatherIcon: "cloud.fill", temperature: "-8"),
            HourlyWeatherModel(hour: "07", weatherIcon: "cloud.fill", temperature: "-9"),
            HourlyWeatherModel(hour: "08", weatherIcon: "cloud.fill", temperature: "-9"),
            HourlyWeatherModel(hour: "09", weatherIcon: "cloud.fill", temperature: "-9"),
            HourlyWeatherModel(hour: "10", weatherIcon: "cloud.fill", temperature: "-8"),
        ]
        
        XCTAssertEqual(result, expectedResult)
    }
}
