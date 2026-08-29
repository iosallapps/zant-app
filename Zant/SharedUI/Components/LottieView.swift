import SwiftUI
import Lottie

/// A SwiftUI wrapper for Lottie animations loaded from a bundled JSON file.
struct LottieView: UIViewRepresentable {

    let fileName: String
    var playOnce: Bool = false
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var shouldPlay: Bool = true  // Control whether animation plays immediately
    var initialFrame: AnimationProgressTime = 0  // Starting frame when not playing

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.clipsToBounds = true
        container.backgroundColor = .clear
        container.isOpaque = false

        let animationView = LottieAnimationView(name: fileName)
        animationView.loopMode = playOnce ? .playOnce : .loop
        animationView.contentMode = contentMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .clear
        animationView.isOpaque = false

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        if shouldPlay {
            animationView.play()
        } else {
            animationView.currentProgress = initialFrame
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = uiView.subviews.first as? LottieAnimationView else { return }

        // Update play state
        if shouldPlay && !animationView.isAnimationPlaying {
            animationView.play()
        } else if !shouldPlay && animationView.isAnimationPlaying {
            animationView.stop()
            animationView.currentProgress = initialFrame
        }
    }
}
