import UIKit

class ViewController: UIViewController {

    // MARK: - Background

    private let gradientLayer = CAGradientLayer()
    private var timer: Timer?
    private var lastGradientHour: Int = -1
    private var isTimerActive: Bool = false

    // MARK: - Cached formatters (DateFormatter is expensive to create)

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日 EEEE"
        return f
    }()

    // MARK: - Header

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Logo")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 22
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "BlankApp"
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Built on GitHub Actions"
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Clock (Feature 2)

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 56, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Device info card (Feature 1)

    private let deviceStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let deviceCardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let deviceTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "设备信息"
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Cached static device info (machine identifier never changes at runtime)
    private lazy var machineIdentifier: String = currentMachine()

    // Reference to the battery value label so it can be refreshed without rebuilding the whole stack
    private var batteryValueLabel: UILabel?
    private var hasBuiltDeviceInfo: Bool = false

    // MARK: - Counter (Feature 3)

    private let counterLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let counterHintLabel: UILabel = {
        let l = UILabel()
        l.text = "点击按钮 +1,有触感反馈"
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var tapButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "+1"
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.95)
        config.baseForegroundColor = UIColor(red: 0.20, green: 0.13, blue: 0.45, alpha: 1.0)
        config.cornerStyle = .capsule
        config.buttonSize = .large
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return b
    }()

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var count: Int = 0

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
        l.textColor = UIColor.white.withAlphaComponent(0.5)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable battery monitoring BEFORE populating device info, otherwise the
        // first render reports batteryState=.unknown / batteryLevel=-1.0.
        UIDevice.current.batteryMonitoringEnabled = true

        setupBackground()
        setupLayout()
        updateClock()
        populateDeviceInfo()
        loadCount()
        updateVersionLabel()

        feedbackGenerator.prepare()

        startTimer()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleAppWillResignActive),
                       name: UIApplication.willResignActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleAppDidBecomeActive),
                       name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateClock()
        refreshBatteryInfo()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupBackground() {
        view.layer.addSublayer(gradientLayer)
        applyGradientForCurrentHour()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
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
        // 让按钮横向铺满
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
        card.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        let inner = content()
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    // MARK: - Feature 2: Clock

    private func updateClock() {
        let now = Date()
        timeLabel.text = timeFormatter.string(from: now)
        dateLabel.text = dateFormatter.string(from: now)

        let hour = Calendar.current.component(.hour, from: now)
        greetingLabel.text = greeting(for: hour)

        applyGradientForCurrentHour(hour: hour)
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

    private func applyGradientForCurrentHour(hour: Int? = nil) {
        let h = hour ?? Calendar.current.component(.hour, from: Date())
        // The gradient only depends on the hour, so skip the work when it hasn't changed.
        guard h != lastGradientHour else { return }
        lastGradientHour = h

        let (c1, c2): (UIColor, UIColor)
        switch h {
        case 5..<11:  // 早晨 - 蓝紫
            c1 = UIColor(red: 0.18, green: 0.34, blue: 0.62, alpha: 1.0)
            c2 = UIColor(red: 0.32, green: 0.18, blue: 0.55, alpha: 1.0)
        case 11..<17: // 中午 - 蓝绿
            c1 = UIColor(red: 0.13, green: 0.30, blue: 0.55, alpha: 1.0)
            c2 = UIColor(red: 0.15, green: 0.40, blue: 0.55, alpha: 1.0)
        case 17..<20: // 黄昏 - 橙紫
            c1 = UIColor(red: 0.42, green: 0.18, blue: 0.42, alpha: 1.0)
            c2 = UIColor(red: 0.55, green: 0.25, blue: 0.30, alpha: 1.0)
        default:      // 夜晚 - 深紫
            c1 = UIColor(red: 0.08, green: 0.08, blue: 0.22, alpha: 1.0)
            c2 = UIColor(red: 0.20, green: 0.10, blue: 0.40, alpha: 1.0)
        }
        gradientLayer.colors = [c1.cgColor, c2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }

    // MARK: - Timer lifecycle

    private func startTimer() {
        guard timer == nil, !isTimerActive else { return }
        // Create the timer unscheduled and add it to .common so it keeps firing
        // while the scroll view is being tracked (default mode pauses for tracking).
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
        isTimerActive = true
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }

    @objc private func handleAppWillResignActive() {
        stopTimer()
    }

    @objc private func handleAppDidBecomeActive() {
        // Refresh immediately so the clock isn't stale after returning from background.
        updateClock()
        refreshBatteryInfo()
        startTimer()
    }

    // MARK: - Feature 1: Device info

    private func populateDeviceInfo() {
        // Static device info is built once; battery is refreshed separately via refreshBatteryInfo().
        guard !hasBuiltDeviceInfo else {
            refreshBatteryInfo()
            return
        }
        deviceStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let screen = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let memoryGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0
        let machine = machineIdentifier

        let rows: [(String, String)] = [
            ("型号", "\(model) (\(machine))"),
            ("系统", "iOS \(systemVersion)"),
            ("屏幕", "\(Int(screen.width))×\(Int(screen.height)) @\(Int(scale))x"),
            ("运行内存", String(format: "%.1f GB", memoryGB))
        ]

        for (key, value) in rows {
            let row = makeInfoRow(key: key, value: value)
            deviceStack.addArrangedSubview(row)
        }

        // Battery row is appended last and its value label stored for live updates.
        let batteryRow = makeInfoRow(key: "电量", value: batteryDisplayString())
        batteryValueLabel = batteryRow.subviews.compactMap { $0 as? UILabel }.first { $0.textAlignment == .right }
        deviceStack.addArrangedSubview(batteryRow)

        hasBuiltDeviceInfo = true
    }

    private func refreshBatteryInfo() {
        guard hasBuiltDeviceInfo else {
            populateDeviceInfo()
            return
        }
        batteryValueLabel?.text = batteryDisplayString()
    }

    private func batteryDisplayString() -> String {
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState

        let batteryText: String
        switch batteryState {
        case .charging: batteryText = "充电中"
        case .full:     batteryText = "已充满"
        case .unplugged:
            batteryText = batteryLevel >= 0 ? "未充电" : "未知"
        default:        batteryText = "未知"
        }
        let batteryPercent = batteryLevel >= 0 ? "\(Int(batteryLevel * 100))%" : "--"
        return "\(batteryPercent) (\(batteryText))"
    }

    private func makeInfoRow(key: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let k = UILabel()
        k.text = key
        k.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        k.textColor = UIColor.white.withAlphaComponent(0.65)
        k.translatesAutoresizingMaskIntoConstraints = false

        let v = UILabel()
        v.text = value
        v.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        v.textColor = .white
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

    // MARK: - Feature 3: Haptic counter

    @objc private func handleTap() {
        feedbackGenerator.impactOccurred()
        count += 1
        counterLabel.text = "\(count)"
        UserDefaults.standard.set(count, forKey: "tapCount")
    }

    private func loadCount() {
        count = UserDefaults.standard.integer(forKey: "tapCount")
        counterLabel.text = "\(count)"
    }

    // MARK: - Version

    private func updateVersionLabel() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        versionLabel.text = "v\(version) (\(build))"
    }
}
