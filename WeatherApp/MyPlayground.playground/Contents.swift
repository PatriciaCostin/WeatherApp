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

let values: [Double] = [6, 6, 5, 7, 9, 8, 8, 7]
let controlVector: [Double] = vDSP.ramp(in: 0 ... Double(values.count) - 1,
                                       count: 24)
let result = vDSP.linearInterpolate(elementsOf: values,
                                    using: controlVector).map{ceil($0)}



print(result)

//static func linearInterpolate<T, U>(elementsOf: T, using: U) -> [Double]
//Returns the interpolation between the neighboring elements of a double-precision vector.
