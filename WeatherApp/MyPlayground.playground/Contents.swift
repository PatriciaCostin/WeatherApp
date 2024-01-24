import UIKit
import Accelerate

//var description = "scatered clouds"
//
//let words = description.components(separatedBy: " ")
//let capitalizedWords = words.map {$0.capitalized}
//var newDescription = ""
//
//for (index, word) in capitalizedWords.enumerated() {
//    if index < (capitalizedWords.count - 1) {
//        newDescription.append(word + " ")
//    } else {
//        newDescription.append(word)
//    }
//}
//print(newDescription)

//let values: [Double] = [6, 6, 5, 7, 9, 8, 8, 7]
//let controlVector: [Double] = vDSP.ramp(in: 0 ... Double(values.count) - 1,
//                                       count: 24)
//let result = vDSP.linearInterpolate(elementsOf: values,
//                                    using: controlVector).map{ceil($0)}
//
//
//
//print(result)

//static func linearInterpolate<T, U>(elementsOf: T, using: U) -> [Double]
//Returns the interpolation between the neighboring elements of a double-precision vector.

    struct Model {
        var temp: Int
        var hour: String
    }

 var models = [Model]()

private let hoursArray = ["11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10"]

private let temperatureArray = ["-5", "-4", "-3", "-3", "-3", "-4", "-5", "-6", "-7", "-8", "-9", "-9", "-9", "-9", "-8", "-8", "-8", "-8", "-8", "-8", "-9", "-9", "-9", "-8"]

func createModel(hoursArray: [String], temperatureArray: [String]) -> [Model] {
    for index in 0..<24 {
        let tempInt = Int(temperatureArray[index]) ?? 0
        models.append(Model(temp: tempInt, hour: hoursArray[index]))
    }
    
    //print(models)
    return models
}

   createModel(hoursArray: hoursArray, temperatureArray: temperatureArray)
