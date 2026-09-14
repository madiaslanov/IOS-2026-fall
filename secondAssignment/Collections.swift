import Foundation


var fruits = ["apple", "banana", "mango", "orange", "kiwi"]
print(fruits[2])

var favoriteNumbers: Set<Int> = [7, 13, 21, 42]
favoriteNumbers.insert(99)
print(favoriteNumbers)

let programmingLanguages: [String: Int] = [
    "Python": 1991,
    "Java": 1995,
    "Swift": 2014
]
print(programmingLanguages["Swift"]!)

var colors = ["red", "blue", "green", "yellow"]
colors[1] = "purple"
print(colors)


let firstNumbers: Set<Int> = [1, 2, 3, 4]
let secondNumbers: Set<Int> = [3, 4, 5, 6]
print(firstNumbers.intersection(secondNumbers))

var studentScores = [
    "Madi": 90,
    "Aida": 85,
    "Alikhan": 88
]
studentScores.updateValue(95, forKey: "Madi")
print(studentScores)

var firstFruits = ["apple", "banana"]
let secondFruits = ["cherry", "date"]
firstFruits.append(contentsOf: secondFruits)
print(firstFruits)


var countryPopulations = [
    "Kazakhstan": 20_000_000,
    "Japan": 125_000_000,
    "Canada": 40_000_000
]
countryPopulations.updateValue(68_000_000, forKey: "France")
print(countryPopulations)

let firstAnimals: Set<String> = ["cat", "dog"]
let secondAnimals: Set<String> = ["dog", "mouse"]
let unitedAnimals = firstAnimals.union(secondAnimals)
let finalAnimals = unitedAnimals.subtracting(secondAnimals)
print(finalAnimals)

let studentGrades = [
    "Madi": [90, 85, 92],
    "Aida": [88, 79, 95]
]
print(studentGrades["Madi"]![1])
