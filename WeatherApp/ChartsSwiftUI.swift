//
//  ChartsSwiftUI.swift
//  WeatherApp
//
//  Created by Patricia Costin on 23.01.2024.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var viewModel = TrialViewModel()
    
    
    @available(iOS 15.0, *)
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart(viewModel.weatherModels) { data in
                if let dayTemp = data.dayTimeTemp, let dayWeek = data.dayTimeWeekDay {
                    LineMark(x: .value("hours", dayWeek),
                             y: .value("temp", dayTemp))
                    .foregroundStyle(by: .value("PartOfDay", "day"))
                    PointMark(x: .value("hours", dayWeek),
                              y: .value("temp", dayTemp)
                    )
                    .foregroundStyle(by: .value("PartOfDay", "day"))
                    
                    .annotation(position: .overlay,
                                alignment: .center,
                                spacing: 0) {
                        VStack(spacing: 0) {
                            Text("\(dayTemp)")
                                .font(.caption)
                                .foregroundColor(.black)
                            
                            Image(systemName: "cloud.rain.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.brown)
                        }
                        .background(Color.white)
                    }
                }
                
                if let nightTemp = data.nightTimeTemp, 
                    let dayWeek = data.nightTimeWeekDat,
                   let alteratedTemp = data.ateratedNightTimeTemp
                {
                    LineMark(x: .value("hours", dayWeek),
                             y: .value("temp", alteratedTemp))
                    .foregroundStyle(by: .value("PartOfDay", "night"))
                    PointMark(x: .value("hours", dayWeek),
                              y: .value("temp", alteratedTemp)
                    )
                    .foregroundStyle(by: .value("PartOfDay", "night"))
                    
                    .annotation(position: .overlay,
                                alignment: .center,
                                spacing: 0) {
                        VStack(spacing: 0) {
                            Text("\(nightTemp)")
                                .font(.caption)
                                .foregroundColor(.black)
                            
                            Image(systemName: "cloud.rain.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.brown)
                        }
                        .background(Color.white)
                    }
                }
            }
            .onAppear {
                viewModel.loadModel()
                Task {
                    do {
                        try await viewModel.getHourlyForecastForUserLocation()
                    } catch {
                        // Handle the error appropriately, e.g., show an alert or log the error
                        print("Error fetching hourly forecast: \(error)")
                    }
                }
            }
        } else {
            Text("Chart is only available on iOS 16.0 or later.")
        }
    }
}

#Preview {
    ContentView()
}
