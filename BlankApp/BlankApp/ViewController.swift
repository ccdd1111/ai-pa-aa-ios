import UIKit
import Darwin

final class ViewController: UIViewController {
    private let gradientLayer = CAGradientLayer()
    private var timer: Timer?
    private var count = 0

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private func makeLabel(font: UIFont, color: UIColor = .white, alignment: NSTextAlignment = .center) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private lazy var titleLabel: UILabel = {
        let label = makeLabel(font: .systemFont(ofSize: 28, weight: .bold))
        label.text = "BlankApp"
        return label
    }()
    private lazy var subtitleLabel: UILabel = {
        let label = makeLabel(font: .systemFont(ofSize: 13, weight: .medium), color: UIColor.white.withAlphaComponent(0.75))
        label.text = "Built on GitHub Actions"
        return label
    }()
    private lazy var timeLabel = makeLabel(font: .monospacedDigitSystemFont(ofSize: 56, weight: .bold))
    private lazy var dateLabel = makeLabel(font: .systemFont(ofSize: 15, weight: .medium), color: UIColor.white.withAlphaComponent(0.85))
    private lazy var greetingLabel = makeLabel(font: .systemFont(ofSize: 17, weight: .semibold))
    private lazy var counterLabel = makeLabel(font: .monospacedDigitSystemFont(ofSize: 48, weight: .bold))
    private lazy var counterHintLabel: UILabel = {
        let label = makeLabel(font: .systemFont(ofSize: 13), color: UIColor.white.withAlphaComponent(0.7))
        label.text = "点击按钮 +1,有触感反馈"
        return label
    }()
    private lazy var versionLabel: UILabel = makeLabel(font: .monospacedDigitSystemFont(ofSize: 12, weight: .regular), color: UIColor.white.withAlphaComponent(0.5))

    private let deviceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceVertical = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    private lazy var tapButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "+1"
        configuration.baseBackgroundColor = UIColor.white.withAlphaComponent(0.95)
        configuration.baseForegroundColor = UIColor(red: 0.20, green: 0.13, blue: 0.45, alpha: 1)
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLayout()
        updateClock()
        populateDeviceInfo()
        count = UserDefaults.standard.integer(forKey: "tapCount")
        counterLabel.text = "\(count)"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        versionLabel.text = "v\(version) (\(build))"
        UIDevice.current.isBatteryMonitoringEnabled = true
        feedbackGenerator.prepare()

        let clockTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
        timer = clockTimer
        RunLoop.main.add(clockTimer, forMode: .common)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateClock()
        populateDeviceInfo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    deinit { timer?.invalidate() }

    private func setupBackground() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        applyGradientForCurrentHour()
    }

    private func makeCard(content: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func makeVerticalStack(_ views: [UIView], spacing: CGFloat = 6) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = spacing
        return stack
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        let header = makeVerticalStack([iconImageView, titleLabel, subtitleLabel], spacing: 8)
        header.alignment = .center
        header.isLayoutMarginsRelativeArrangement = true
        header.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)

        let clockCard = makeCard(content: makeVerticalStack([timeLabel, dateLabel, greetingLabel]))
        let deviceCard = UIView()
        deviceCard.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        deviceCard.layer.cornerRadius = 16
        deviceCard.layer.borderWidth = 1
        deviceCard.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        deviceCard.translatesAutoresizingMaskIntoConstraints = false
        let deviceTitle = makeLabel(font: .systemFont(ofSize: 14, weight: .semibold), color: UIColor.white.withAlphaComponent(0.7), alignment: .left)
        deviceTitle.text = "设备信息"
        deviceTitle.translatesAutoresizingMaskIntoConstraints = false
        deviceCard.addSubview(deviceTitle)
        deviceCard.addSubview(deviceStack)
        NSLayoutConstraint.activate([
            deviceTitle.topAnchor.constraint(equalTo: deviceCard.topAnchor, constant: 14),
            deviceTitle.leadingAnchor.constraint(equalTo: deviceCard.leadingAnchor, constant: 16),
            deviceTitle.trailingAnchor.constraint(equalTo: deviceCard.trailingAnchor, constant: -16),
            deviceStack.topAnchor.constraint(equalTo: deviceTitle.bottomAnchor, constant: 12),
            deviceStack.leadingAnchor.constraint(equalTo: deviceCard.leadingAnchor, constant: 16),
            deviceStack.trailingAnchor.constraint(equalTo: deviceCard.trailingAnchor, constant: -16),
            deviceStack.bottomAnchor.constraint(equalTo: deviceCard.bottomAnchor, constant: -14)
        ])
        let counterCard = makeCard(content: makeVerticalStack([counterLabel, counterHintLabel, tapButton], spacing: 10))

        contentStack.addArrangedSubview(header)
        contentStack.addArrangedSubview(clockCard)
        contentStack.addArrangedSubview(deviceCard)
        contentStack.addArrangedSubview(counterCard)
        contentStack.addArrangedSubview(versionLabel)

        let margins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: margins.top),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: margins.left),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -margins.right),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -margins.bottom),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -(margins.left + margins.right)),
            iconImageView.widthAnchor.constraint(equalToConstant: 88),
            iconImageView.heightAnchor.constraint(equalToConstant: 88)
        ])
    }

    private func updateClock() {
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeLabel.text = timeFormatter.string(from: now)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = "M月d日 EEEE"
        dateLabel.text = dateFormatter.string(from: now)

        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 5..<11: greetingLabel.text = "☀ 早上好"
        case 11..<13: greetingLabel.text = "🌤 中午好"
        case 13..<18: greetingLabel.text = "🌤 下午好"
        case 18..<23: greetingLabel.text = "🌙 晚上好"
        default: greetingLabel.text = "🌌 夜深了"
        }
        applyGradient(for: hour)
    }

    private func applyGradientForCurrentHour() {
        applyGradient(for: Calendar.current.component(.hour, from: Date()))
    }

    private func applyGradient(for hour: Int) {
        let colors: [UIColor]
        switch hour {
        case 5..<11: colors = [UIColor(red: 0.18, green: 0.34, blue: 0.62, alpha: 1), UIColor(red: 0.32, green: 0.18, blue: 0.55, alpha: 1)]
        case 11..<17: colors = [UIColor(red: 0.13, green: 0.30, blue: 0.55, alpha: 1), UIColor(red: 0.15, green: 0.40, blue: 0.55, alpha: 1)]
        case 17..<20: colors = [UIColor(red: 0.42, green: 0.18, blue: 0.42, alpha: 1), UIColor(red: 0.55, green: 0.25, blue: 0.30, alpha: 1)]
        default: colors = [UIColor(red: 0.08, green: 0.08, blue: 0.22, alpha: 1), UIColor(red: 0.20, green: 0.10, blue: 0.40, alpha: 1)]
        }
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }

    private func populateDeviceInfo() {
        deviceStack.arrangedSubviews.forEach { view in
            deviceStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let device = UIDevice.current
        var systemInfo = utsname()
        let machine: String
        if uname(&systemInfo) == 0 {
            machine = Mirror(reflecting: systemInfo.machine).children.compactMap { child -> String? in
                guard let value = child.value as? Int8, value != 0 else { return nil }
                return String(UnicodeScalar(UInt8(value)))
            }.joined()
        } else {
            machine = "unknown"
        }
        let screen = UIScreen.main
        let battery = device.batteryLevel
        let batteryState: String
        switch device.batteryState {
        case .charging: batteryState = "充电中"
        case .full: batteryState = "已充满"
        case .unplugged: batteryState = battery >= 0 ? "未充电" : "未知"
        default: batteryState = "未知"
        }
        let rows = [
            ("型号", "\(device.model) (\(machine))"),
            ("系统", "iOS \(device.systemVersion)"),
            ("屏幕", "\(Int(screen.bounds.width))×\(Int(screen.bounds.height)) @\(Int(screen.scale))x"),
            ("电量", "\(battery >= 0 ? "\(Int(battery * 100))%" : "--") (\(batteryState))"),
            ("运行内存", String(format: "%.1f GB", Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824))
        ]
        rows.forEach { key, value in
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12
            let keyLabel = makeLabel(font: .systemFont(ofSize: 13), color: UIColor.white.withAlphaComponent(0.65), alignment: .left)
            keyLabel.text = key
            let valueLabel = makeLabel(font: .monospacedDigitSystemFont(ofSize: 14, weight: .medium), alignment: .right)
            valueLabel.text = value
            valueLabel.lineBreakMode = .byTruncatingTail
            valueLabel.adjustsFontSizeToFitWidth = true
            valueLabel.minimumScaleFactor = 0.7
            row.addArrangedSubview(keyLabel)
            row.addArrangedSubview(valueLabel)
            keyLabel.setContentHuggingPriority(.required, for: .horizontal)
            deviceStack.addArrangedSubview(row)
        }
    }

    @objc private func handleTap() {
        feedbackGenerator.impactOccurred()
        count += 1
        counterLabel.text = "\(count)"
        UserDefaults.standard.set(count, forKey: "tapCount")
        feedbackGenerator.prepare()
    }
}
