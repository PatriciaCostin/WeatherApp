//
//  ContentView.swift
//  Charts
//
//  Created by Patricia Costin on 23.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    private let hoursArray = ["11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10"]
                           
    private let temperatureArray = ["-5", "-4", "-3", "-3", "-3", "-4", "-5", "-6", "-7", "-8", "-9", "-9", "-9", "-9", "-8", "-8", "-8", "-8", "-8", "-8", "-9", "-9", "-9", "-8"]
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
