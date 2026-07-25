import UIKit

class ViewController: UIViewController {

    private let gradientLayer = CAGradientLayer()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Logo")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 24
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 0.35
        iv.layer.shadowRadius = 16
        iv.layer.shadowOffset = CGSize(width: 0, height: 8)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "BlankApp"
        l.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Built on GitHub Actions"
        l.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let versionLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupContent()
        updateVersionLabel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.10, green: 0.16, blue: 0.45, alpha: 1.0).cgColor,
            UIColor(red: 0.30, green: 0.10, blue: 0.55, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
    }

    private func setupContent() {
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func updateVersionLabel() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        versionLabel.text = "v\(version) (\(build))"
    }
}
