import UIKit

class ViewController: UIViewController {

    // MARK: - Theme colors

    private struct Theme {
        static var primaryText: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? .white
                    : UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)
            }
        }

        static var secondaryText: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor.white.withAlphaComponent(0.85)
                    : UIColor.black.withAlphaComponent(0.65)
            }
        }

        static var tertiaryText: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor.white.withAlphaComponent(0.65)
                    : UIColor.black.withAlphaComponent(0.50)
            }
        }

        static var cardBackground: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor.white.withAlphaComponent(0.12)
                    : UIColor.black.withAlphaComponent(0.06)
            }
        }

        static var cardBorder: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor.white.withAlphaComponent(0.15)
                    : UIColor.black.withAlphaComponent(0.10)
            }
        }

        static var buttonBackground: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor.white.withAlphaComponent(0.95)
                    : UIColor(red: 0.35, green: 0.25, blue: 0.65, alpha: 1.0)
            }
        }

        static var buttonForeground: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.20, green: 0.13, blue: 0.45, alpha: 1.0)
                    : .white
            }
        }
    }

    // MARK: - Background

    private let gradientLayer = CAGradientLayer()
    private var timer: Timer?

    // MARK: - Header

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Logo")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 22
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = Theme.cardBorder.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "BlankApp"
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = Theme.primaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Built on GitHub Actions"
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = Theme.secondaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Clock

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 56, weight: .bold)
        l.textColor = Theme.primaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = Theme.secondaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.textColor = Theme.primaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Device info card

    private let deviceStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let deviceCardView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = Theme.cardBorder.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let deviceTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "设备信息"
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.textColor = Theme.tertiaryText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Counter

    private let counterLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        l.textColor = Theme.primaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let counterHintLabel: UILabel = {
        let l = UILabel()
        l.text = "点击按钮 +1,有触感反馈"
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = Theme.tertiaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var tapButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "+1"
        config.baseBackgroundColor = Theme.buttonBackground
        config.baseForegroundColor = Theme.buttonForeground
        config.cornerStyle = .capsule
        config.buttonSize = .large
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return b
    }()

    private lazy var settingsButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "gearshape")
        config.baseForegroundColor = Theme.primaryText
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        return b
    }()

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var count: Int = 0
    private var cards: [UIView] = []

    // MARK: - Layout containers

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.showsVerticalScrollIndicator = true
        s.alwaysBounceVertical = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.spacing = 24
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let versionLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        l.textColor = Theme.tertiaryText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLayout()
        updateClock()
        populateDeviceInfo()
        loadCount()
        updateVersionLabel()
        applyAppearance()

        UIDevice.current.batteryMonitoringEnabled = true
        feedbackGenerator.prepare()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateClock()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.didChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReset),
            name: Notification.Name("CounterDidResetNotification"),
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateClock()
        populateDeviceInfo()
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyAppearance()
    }

    // MARK: - Setup

    private func setupBackground() {
        view.layer.addSublayer(gradientLayer)
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(settingsButton)
        scrollView.addSubview(contentStack)

        let headerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 8
        headerStack.isLayoutMarginsRelativeArrangement = true
        headerStack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let clockCard = makeCard(content: {
            let s = UIStackView(arrangedSubviews: [timeLabel, dateLabel, greetingLabel])
            s.axis = .vertical
            s.alignment = .center
            s.spacing = 6
            s.translatesAutoresizingMaskIntoConstraints = false
            return s
        }())

        deviceCardView.addSubview(deviceTitleLabel)
        deviceCardView.addSubview(deviceStack)
        cards.append(deviceCardView)

        NSLayoutConstraint.activate([
            deviceTitleLabel.topAnchor.constraint(equalTo: deviceCardView.topAnchor, constant: 14),
            deviceTitleLabel.leadingAnchor.constraint(equalTo: deviceCardView.leadingAnchor, constant: 16),
            deviceTitleLabel.trailingAnchor.constraint(equalTo: deviceCardView.trailingAnchor, constant: -16),
            deviceStack.topAnchor.constraint(equalTo: deviceTitleLabel.bottomAnchor, constant: 12),
            deviceStack.leadingAnchor.constraint(equalTo: deviceCardView.leadingAnchor, constant: 16),
            deviceStack.trailingAnchor.constraint(equalTo: deviceCardView.trailingAnchor, constant: -16),
            deviceStack.bottomAnchor.constraint(equalTo: deviceCardView.bottomAnchor, constant: -14)
        ])

        let counterCard = makeCard(content: {
            let s = UIStackView(arrangedSubviews: [counterLabel, counterHintLabel, tapButton])
            s.axis = .vertical
            s.alignment = .center
            s.spacing = 10
            s.translatesAutoresizingMaskIntoConstraints = false
            return s
        }())
        tapButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(clockCard)
        contentStack.addArrangedSubview(deviceCardView)
        contentStack.addArrangedSubview(counterCard)
        contentStack.addArrangedSubview(versionLabel)

        let margins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: margins.top),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: margins.left),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -margins.right),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -margins.bottom),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -(margins.left + margins.right)),

            iconImageView.widthAnchor.constraint(equalToConstant: 88),
            iconImageView.heightAnchor.constraint(equalToConstant: 88)
        ])
    }

    private func makeCard(content: () -> UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cardBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = Theme.cardBorder.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        let inner = content()
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        cards.append(card)
        return card
    }

    // MARK: - Appearance

    private func applyAppearance() {
        gradientLayer.colors = gradientColorsForCurrentHour()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        for card in cards {
            card.backgroundColor = Theme.cardBackground
            card.layer.borderColor = Theme.cardBorder.cgColor
        }

        iconImageView.layer.borderColor = Theme.cardBorder.cgColor
        updateButtonAppearance()
        updateSettingsButtonAppearance()
    }

    private func updateButtonAppearance() {
        var config = tapButton.configuration ?? UIButton.Configuration.filled()
        config.baseBackgroundColor = Theme.buttonBackground
        config.baseForegroundColor = Theme.buttonForeground
        tapButton.configuration = config
    }

    private func updateSettingsButtonAppearance() {
        var config = settingsButton.configuration ?? UIButton.Configuration.plain()
        config.image = UIImage(systemName: "gearshape")
        config.baseForegroundColor = Theme.primaryText
        settingsButton.configuration = config
    }

    // MARK: - Clock

    private func updateClock() {
        let now = Date()
        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "HH:mm:ss"
        timeLabel.text = timeFmt.string(from: now)

        let dateFmt = DateFormatter()
        dateFmt.locale = Locale(identifier: "zh_CN")
        dateFmt.dateFormat = "M月d日 EEEE"
        dateLabel.text = dateFmt.string(from: now)

        let hour = Calendar.current.component(.hour, from: now)
        greetingLabel.text = greeting(for: hour)

        applyAppearance()
    }

    private func greeting(for hour: Int) -> String {
        switch hour {
        case 5..<11:  return "☀ 早上好"
        case 11..<13: return "🌤 中午好"
        case 13..<18: return "🌤 下午好"
        case 18..<23: return "🌙 晚上好"
        default:      return "🌌 夜深了"
        }
    }

    private func gradientColorsForCurrentHour() -> [CGColor] {
        let hour = Calendar.current.component(.hour, from: Date())
        let isDark = traitCollection.userInterfaceStyle == .dark
        let c1, c2: UIColor
        switch hour {
        case 5..<11:
            c1 = isDark ? UIColor(red: 0.18, green: 0.34, blue: 0.62, alpha: 1.0)
                        : UIColor(red: 0.55, green: 0.70, blue: 0.95, alpha: 1.0)
            c2 = isDark ? UIColor(red: 0.32, green: 0.18, blue: 0.55, alpha: 1.0)
                        : UIColor(red: 0.72, green: 0.60, blue: 0.90, alpha: 1.0)
        case 11..<17:
            c1 = isDark ? UIColor(red: 0.13, green: 0.30, blue: 0.55, alpha: 1.0)
                        : UIColor(red: 0.50, green: 0.75, blue: 0.90, alpha: 1.0)
            c2 = isDark ? UIColor(red: 0.15, green: 0.40, blue: 0.55, alpha: 1.0)
                        : UIColor(red: 0.55, green: 0.80, blue: 0.75, alpha: 1.0)
        case 17..<20:
            c1 = isDark ? UIColor(red: 0.42, green: 0.18, blue: 0.42, alpha: 1.0)
                        : UIColor(red: 0.90, green: 0.55, blue: 0.55, alpha: 1.0)
            c2 = isDark ? UIColor(red: 0.55, green: 0.25, blue: 0.30, alpha: 1.0)
                        : UIColor(red: 0.95, green: 0.70, blue: 0.50, alpha: 1.0)
        default:
            c1 = isDark ? UIColor(red: 0.08, green: 0.08, blue: 0.22, alpha: 1.0)
                        : UIColor(red: 0.20, green: 0.25, blue: 0.45, alpha: 1.0)
            c2 = isDark ? UIColor(red: 0.20, green: 0.10, blue: 0.40, alpha: 1.0)
                        : UIColor(red: 0.45, green: 0.35, blue: 0.70, alpha: 1.0)
        }
        return [c1.cgColor, c2.cgColor]
    }

    // MARK: - Device info

    private func populateDeviceInfo() {
        deviceStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let screen = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        let memoryGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0
        let machine = currentMachine()

        let batteryText: String
        switch batteryState {
        case .charging: batteryText = "充电中"
        case .full:     batteryText = "已充满"
        case .unplugged:
            batteryText = batteryLevel >= 0 ? "未充电" : "未知"
        default:        batteryText = "未知"
        }
        let batteryPercent = batteryLevel >= 0 ? "\(Int(batteryLevel * 100))%" : "--"

        let rows: [(String, String)] = [
            ("型号", "\(model) (\(machine))"),
            ("系统", "iOS \(systemVersion)"),
            ("屏幕", "\(Int(screen.width))×\(Int(screen.height)) @\(Int(scale))x"),
            ("电量", "\(batteryPercent) (\(batteryText))"),
            ("运行内存", String(format: "%.1f GB", memoryGB))
        ]

        for (key, value) in rows {
            let row = makeInfoRow(key: key, value: value)
            deviceStack.addArrangedSubview(row)
        }
    }

    private func makeInfoRow(key: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let k = UILabel()
        k.text = key
        k.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        k.textColor = Theme.tertiaryText
        k.translatesAutoresizingMaskIntoConstraints = false

        let v = UILabel()
        v.text = value
        v.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        v.textColor = Theme.primaryText
        v.textAlignment = .right
        v.lineBreakMode = .byTruncatingTail
        v.adjustsFontSizeToFitWidth = true
        v.minimumScaleFactor = 0.7
        v.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(k)
        container.addSubview(v)
        NSLayoutConstraint.activate([
            k.topAnchor.constraint(equalTo: container.topAnchor),
            k.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            k.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            v.topAnchor.constraint(equalTo: container.topAnchor),
            v.leadingAnchor.constraint(equalTo: k.trailingAnchor, constant: 12),
            v.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            v.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
        return container
    }

    private func currentMachine() -> String {
        var systemInfo = utsname()
        if uname(&systemInfo) == 0 {
            let mirror = Mirror(reflecting: systemInfo.machine)
            var identifier = ""
            for child in mirror.children {
                if let value = child.value as? Int8, value != 0 {
                    identifier.append(Character(UnicodeScalar(UInt8(value))))
                }
            }
            return identifier.isEmpty ? "unknown" : identifier
        }
        return "unknown"
    }

    // MARK: - Counter

    @objc private func handleTap() {
        feedbackGenerator.impactOccurred()
        count += 1
        counterLabel.text = "\(count)"
        UserDefaults.standard.set(count, forKey: "tapCount")
    }

    @objc private func handleReset() {
        count = 0
        counterLabel.text = "0"
    }

    private func loadCount() {
        count = UserDefaults.standard.integer(forKey: "tapCount")
        counterLabel.text = "\(count)"
    }

    // MARK: - Settings

    @objc private func didTapSettings() {
        let settingsVC = SettingsViewController()
        let nav = UINavigationController(rootViewController: settingsVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc private func themeDidChange() {
        applyAppearance()
    }

    // MARK: - Version

    private func updateVersionLabel() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        versionLabel.text = "v\(version) (\(build))"
    }
}
