import UIKit

struct Favorite {
    let title: String
    let description: String
    let imageName: String
}

class ViewController: UIViewController {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    let favorites: [Favorite] = [
        Favorite(title: "Interstellar",
                 description: "A movie about space exploration.",
                 imageName: "movie1"),

        Favorite(title: "Inception",
                 description: "A movie about dreams.",
                 imageName: "movie2"),

        Favorite(title: "The Dark Knight",
                 description: "Batman protects Gotham City.",
                 imageName: "movie3"),

        Favorite(title: "Titanic",
                 description: "A romantic story on a ship.",
                 imageName: "movie4"),

        Favorite(title: "Avatar",
                 description: "An adventure on Pandora.",
                 imageName: "movie5"),

        Favorite(title: "The Matrix",
                 description: "A story about virtual reality.",
                 imageName: "movie6"),

        Favorite(title: "Gladiator",
                 description: "A Roman general fights for freedom.",
                 imageName: "movie7"),

        Favorite(title: "The Avengers",
                 description: "Superheroes save the world.",
                 imageName: "movie8"),

        Favorite(title: "Oppenheimer",
                 description: "A story about a famous scientist.",
                 imageName: "movie9"),

        Favorite(title: "Spider-Man",
                 description: "A superhero protects his city.",
                 imageName: "movie10")
    ]

    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        movieImageView.contentMode = .scaleAspectFit
        descriptionLabel.numberOfLines = 0

        showFavorite(at: currentIndex)
    }

    func showFavorite(at index: Int) {
        guard favorites.indices.contains(index) else {
            return
        }

        let favorite = favorites[index]

        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.description
        movieImageView.image = UIImage(named: favorite.imageName)
    }

    @IBAction func randomButtonTapped(_ sender: UIButton) {
        guard favorites.count > 1 else {
            return
        }

        var newIndex: Int

        repeat {
            newIndex = Int.random(in: 0..<favorites.count)
        } while newIndex == currentIndex

        currentIndex = newIndex
        showFavorite(at: currentIndex)
    }
}
