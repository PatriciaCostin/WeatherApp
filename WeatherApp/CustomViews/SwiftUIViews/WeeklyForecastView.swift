//
//  ChartsSwiftUI.swift
//  WeatherApp
//
//  Created by Patricia Costin on 23.01.2024.
//

import SwiftUI
import Charts

struct WeeklyForecastView: View {
    @StateObject private var viewModel = WeeklyForecastViewModel()
    @State private var tapStates: [Bool] = Array(repeating: false, count: 6)
    
    @available(iOS 15.0, *)
    var body: some View {
        VStack(alignment: .leading ) {
            Spacer(minLength: 10)
            WeeklyForecastTitleView()
                .alignmentGuide(.leading) { context in
                    context[.leading] - 20 }
            ZStack() {
                if #available(iOS 16.0, *) {
                    Chart(viewModel.weatherModels) { data in
                        if let dayTemp = data.dayTimeTemp,
                           let dayWeek = data.dayTimeWeekDay,
                           let alteredDayTemp = data.alteredDayTimeTemp,
                           let dayTimeIcon = data.dayTimeIcon
                        {
                             Plot {
                            LineMark(x: .value("hours", dayWeek),
                                     y: .value("temp", alteredDayTemp))
                            .foregroundStyle(.day)
                            .foregroundStyle(by: .value("PartOfDay", "day"))
                            PointMark(x: .value("hours", dayWeek),
                                      y: .value("temp", alteredDayTemp))
                            .foregroundStyle(by: .value("PartOfDay", "day"))
                            
                            .annotation(position: .overlay,
                                        alignment: .center,
                                        spacing: 0) {
                                TemperatureViewSwiftUI(
                                    temperature: dayTemp,
                                    iconName: dayTimeIcon,
                                    isDayTime: true
                                )
                                .background(.secondaryViewBackground)
                            }
                        }
                             .interpolationMethod(.catmullRom)
                        }
                        
                        if let nightTemp = data.nightTimeTemp,
                           let dayWeek = data.nightTimeWeekDay,
                           let alteredNightTemp = data.alteredNightTimeTemp,
                           let nightTimeIcon = data.nightTimeIcon
                        {
                            LineMark(x: .value("hours", dayWeek),
                                     y: .value("temp", alteredNightTemp - 10))
                            .foregroundStyle(.night)
                            .foregroundStyle(by: .value("PartOfDay", "night"))
                            PointMark(x: .value("hours", dayWeek),
                                      y: .value("temp", alteredNightTemp - 10)
                            )
                            .foregroundStyle(by: .value("PartOfDay", "night"))
                            .annotation(position: .overlay,
                                        alignment: .center,
                                        spacing: 0) {
                                TemperatureViewSwiftUI(
                                    temperature: nightTemp,
                                    iconName: nightTimeIcon,
                                    isDayTime: false
                                )
                                .background(.secondaryViewBackground)
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks {
                            AxisValueLabel()
                                .font(.system(size: FontSizes.subtitle, weight: .semibold))
                                .foregroundStyle(.gray.opacity(0.8))
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                        }
                    }
                    .chartYAxis(.hidden)
                    .chartLegend(.hidden)
                    .padding(.horizontal, 5)
                } else {
                    Text("Chart is only available on iOS 16.0 or later.")
                }
                
                HStack(spacing: 0) {
                    ForEach(viewModel.weatherModels.indices, id:\.self) { index in
                        Rectangle()
                            .fill(viewModel.index == index
                                  ? Color.deepBlue.opacity(0.1)
                                  : Color.blue.opacity(0.0000001)
                            )
                            .cornerRadius(5)
                            .onTapGesture {
                                viewModel.index = index
                            }
                    }
                    .padding(.horizontal, 5)
                }
            }
            
            HStack() {
                VStack(alignment: .leading, spacing: 25) {
                    ForecastElementView(elementName: "Humidity",
                                        elementInfo: String(viewModel.firstWeatherModel?.humidity ?? 0))
                    ForecastElementView(elementName: "Wind speed",
                                        elementInfo: String(format: "%.2f", viewModel.firstWeatherModel?.windSpeed ?? 0))
                    ForecastElementView(elementName: "Visibility",
                                        elementInfo: String(viewModel.firstWeatherModel?.visibility ?? 0))
                }
                .padding(.leading, 10)
                Spacer()
                VStack(alignment: .leading, spacing: 25) {
                    ForecastElementView(elementName: "Pressure",
                                        elementInfo: String(viewModel.firstWeatherModel?.pressure ?? 0))
                    ForecastElementView(elementName: "Cloudiness",
                                        elementInfo: String(viewModel.firstWeatherModel?.cloudiness ?? 0))
                    ForecastElementView(elementName: "Precipitation",
                                        elementInfo: String(format: "%.0f", (viewModel.firstWeatherModel?.posibilityOfPrecipitation ?? 0) * 100))
                }
                .padding(.trailing, 10)
            }
            .padding()
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.getWeeklyForecastForUserLocation()
                } catch {
                    print("Error fetching hourly forecast: \(error)")
                }
            }
        }
    }
}

#Preview {
    WeeklyForecastView()
}
