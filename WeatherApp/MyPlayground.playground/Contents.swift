import UIKit

var description = "scatered clouds"

let words = description.components(separatedBy: " ")
let capitalizedWords = words.map {$0.capitalized}
var newDescription = ""

for (index, word) in capitalizedWords.enumerated() {
    if index < (capitalizedWords.count - 1) {
        newDescription.append(word + " ")
    } else {
        newDescription.append(word)
    }
}
print(newDescription)
