//
//  ContentView.swift
//  Test
//
//  Created by Patricia Costin on 24.01.2024.
//

import SwiftUI
import Charts

struct Model: Identifiable {
    var id = UUID()
    var weekDay: String
    var dayTemp: Int?
    var nightTemp: Int?
}

struct ContentView: View {
    var models: [Model] = [Model(weekDay: "Mon", dayTemp: nil, nightTemp: 2), Model(weekDay: "Tue", dayTemp: 10, nightTemp: 3), Model(weekDay: "Wen", dayTemp: 12, nightTemp: 4), Model(weekDay: "Thu", dayTemp: 11, nightTemp: nil)]
    
    
    var body: some View {
        
        
        if #available(iOS 16.0, *) {
            Chart(models) { data in
                
                if let dayTemp = data.dayTemp {
                    LineMark(x: .value("day", data.weekDay),
                             y: .value("temp", dayTemp))
                    .foregroundStyle(by: .value("PartOfDat", "day"))
                    PointMark(x: .value("day", data.weekDay),
                              y: .value("temp", dayTemp))
                    .foregroundStyle(by: .value("PartOfDat", "day"))
                }
                    
                
                if let nightTemp = data.nightTemp {
                    LineMark(x: .value("day", data.weekDay),
                             y: .value("temp", nightTemp))
                    .foregroundStyle(by: .value("PartOfDat", "night"))
                    PointMark(x: .value("day", data.weekDay),
                              y: .value("temp", nightTemp))
                    .foregroundStyle(by: .value("PartOfDat", "night"))
                }
                    
            }
        }
    }
}

#Preview {
    ContentView()
}
