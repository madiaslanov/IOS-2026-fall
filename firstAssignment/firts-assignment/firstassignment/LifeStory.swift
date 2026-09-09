import Foundation

func buildLifeStory() -> String {

    // MARK: - Step 1: Personal information

    let firstName: String = "Madi"
    let lastName: String = "Aslanov"
    let birthYear: Int = 2005
    let currentYear: Int = 2026
    let age: Int = currentYear - birthYear
    let isStudent: Bool = true
    let height: Double = 1.80
    let city: String = "Almaty"
    let country: String = "Kazakhstan"
    let favoriteColor: String = "blue"
    let 🌟: String = "curious and optimistic"
    let favoriteEmoji: String = "⚽️"

    // MARK: - Step 2: Hobbies and interests

    let hobby: String = "football"
    let numberOfHobbies: Int = 4
    let favoriteNumber: Int = 7
    let isHobbyCreative: Bool = false
    let secondHobby: String = "coding"
    let thirdHobby: String = "photography"
    let 🎮: String = "video games"
    let lovesMusic: Bool = true
    let favoriteFood: String = "🍕"

    // MARK: - Bonus: future goals

    let futureGoals: String = "In the future, I want to become a professional iOS developer. 📱"

    // MARK: - Step 3: Life story summary

    let studentStatus = isStudent ? "I am currently a student" : "I am not a student right now"
    let hobbyType = isHobbyCreative ? "a creative hobby" : "an active hobby"
    let musicLine = lovesMusic ? "I also love music." : "Music is not really my thing."

    let lifeStory = """
    My name is \(firstName) \(lastName) \(favoriteEmoji). I am \(age) years old, born in \(birthYear). \(studentStatus). I live in \(city), \(country), I am \(height) meters tall, and my favorite color is \(favoriteColor). People say I am \(🌟). I enjoy \(hobby), which is \(hobbyType). My other hobbies are \(secondHobby), \(thirdHobby), and \(🎮). I have \(numberOfHobbies) hobbies in total, my favorite number is \(favoriteNumber), and my favorite food is \(favoriteFood). \(musicLine) \(futureGoals)
    """

    // MARK: - Step 4: Print the life story

    print(lifeStory)
    return lifeStory
}
