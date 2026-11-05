
import UIKit
import AVFoundation

struct Song {
    let fileName: String
    let title: String
    let artist: String
}

class ViewController: UIViewController, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer?
    var songs: [Song] = [
        Song(
            fileName: "song1",
            title: "Не пускайте меня снова снею танцевать",
            artist: "Hamali & Navai"
        ),
        Song(
            fileName: "song2",
            title: "Девочка война",
            artist: "Hamali & Navai"
        )
    ]
    var currentSongIndex = 0
    var timer: Timer?
    var isSeeking = false

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        coverImageView.layer.cornerRadius = 12
        coverImageView.clipsToBounds = true

        previousButton.setTitle("⏮️", for: .normal)
        nextButton.setTitle("⏭️", for: .normal)
        playPauseButton.setTitle("▶️", for: .normal)

        progressSlider.minimumValue = 0
        progressSlider.value = 0
        progressSlider.isContinuous = true

        progressSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        currentTimeLabel.text = "0:00"
        durationLabel.text = "0:00"

        loadSong()
    }

    deinit {
        stopTimer()
    }

    func loadSong() {
        stopTimer()
        audioPlayer?.stop()
        audioPlayer?.delegate = nil

        let song = songs[currentSongIndex]

        guard let url = Bundle.main.url(
            forResource: song.fileName,
            withExtension: "mp3"
        ) else {
            print("MP3 file not found: \(song.fileName).mp3")
            titleLabel.text = song.title
            artistLabel.text = "File not found"
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            audioPlayer = player

            titleLabel.text = song.title
            artistLabel.text = song.artist

            let duration = max(player.duration, 0)

            progressSlider.minimumValue = 0
            progressSlider.maximumValue = Float(duration)
            progressSlider.value = 0

            currentTimeLabel.text = formatTime(0)
            durationLabel.text = formatTime(duration)

            playPauseButton.setTitle("▶️", for: .normal)
        } catch {
            print("Audio error: \(error)")
        }
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
            stopTimer()
            sender.setTitle("▶️", for: .normal)
        } else {
            if player.currentTime >= player.duration - 0.05 {
                player.currentTime = 0
                progressSlider.value = 0
                currentTimeLabel.text = formatTime(0)
            }

            player.play()
            sender.setTitle("⏸️", for: .normal)
            startTimer()
            updateProgress()
        }
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        currentSongIndex = (currentSongIndex + 1) % songs.count
        loadSong()
        audioPlayer?.play()
        playPauseButton.setTitle("⏸️", for: .normal)
        startTimer()
        updateProgress()
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        if let player = audioPlayer, player.currentTime > 3 {
            player.currentTime = 0
            updateProgress()
            return
        }

        currentSongIndex =
            (currentSongIndex - 1 + songs.count) % songs.count

        loadSong()
        audioPlayer?.play()
        playPauseButton.setTitle("⏸️", for: .normal)
        startTimer()
        updateProgress()
    }

    func startTimer() {
        stopTimer()

        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateProgress() {
        guard let player = audioPlayer, !isSeeking else { return }

        let duration = max(player.duration, 0)
        let current = min(max(player.currentTime, 0), duration)

        if progressSlider.maximumValue != Float(duration) {
            progressSlider.maximumValue = Float(duration)
        }

        progressSlider.value = Float(current)
        currentTimeLabel.text = formatTime(current)
        durationLabel.text = formatTime(duration)
    }

    @objc func sliderTouchDown(_ sender: UISlider) {
        isSeeking = true
    }

    @objc func sliderTouchUp(_ sender: UISlider) {
        guard let player = audioPlayer else {
            isSeeking = false
            return
        }

        let seekTime = TimeInterval(sender.value)
        player.currentTime = min(max(seekTime, 0), player.duration)
        currentTimeLabel.text = formatTime(player.currentTime)
        progressSlider.value = Float(player.currentTime)

        isSeeking = false

        if player.isPlaying {
            startTimer()
        }
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        currentTimeLabel.text = formatTime(TimeInterval(sender.value))
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        player.currentTime = 0
        progressSlider.value = 0
        currentTimeLabel.text = formatTime(0)
        durationLabel.text = formatTime(player.duration)
        playPauseButton.setTitle("▶️", for: .normal)
    }

    func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite, !time.isNaN else { return "0:00" }

        let totalSeconds = max(0, Int(time.rounded(.down)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%d:%02d", minutes, seconds)
    }
}
