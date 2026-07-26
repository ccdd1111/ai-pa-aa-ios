import UIKit

final class SettingsViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = .label
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return b
    }()

    private lazy var themeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: AppTheme.allCases.map { $0.displayName })
        sc.selectedSegmentIndex = ThemeManager.shared.current.rawValue
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
        return sc
    }()

    private lazy var resetButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "重置计数器"
        config.baseBackgroundColor = .systemRed
        config.cornerStyle = .capsule
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .systemGroupedBackground
        title = "设置"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(makeCard(title: "外观", content: themeSegmentedControl, minHeight: 32))
        contentStack.addArrangedSubview(makeCard(title: "数据", content: resetButton, minHeight: 44))
        contentStack.addArrangedSubview(versionLabel())

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func makeCard(title: String, content: UIView, minHeight: CGFloat) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        content.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(titleLabel)
        card.addSubview(content)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            content.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            content.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        ])

        return card
    }

    private func versionLabel() -> UILabel {
        let l = UILabel()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        l.text = "BlankApp v\(version) (\(build))"
        l.font = UIFont.preferredFont(forTextStyle: .footnote)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    @objc private func themeChanged() {
        guard let theme = AppTheme(rawValue: themeSegmentedControl.selectedSegmentIndex) else { return }
        ThemeManager.shared.current = theme
    }

    @objc private func didTapReset() {
        UserDefaults.standard.set(0, forKey: "tapCount")
        NotificationCenter.default.post(name: Notification.Name("CounterDidResetNotification"), object: nil)
        let alert = UIAlertController(title: nil, message: "计数器已重置", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}
