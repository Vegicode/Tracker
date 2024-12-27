import UIKit

protocol TrackerHabbitViewControllerDelegate: AnyObject {
    func didTapCreateButton(categoryTitle: String, trackerToAdd: Tracker)
    func didTapCancelButton()
}

final class TrackerHabbitViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var optionsTableViewTopConstraint: NSLayoutConstraint?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedSchedule = [Weekday]()
    weak var scheduleDelegate: ScheduleViewControllerDelegate?
    weak var trackerHabbitDelegate: TrackerHabbitViewControllerDelegate?
    
    var onTrackerCreated: ((Tracker) -> Void)?
    
    // MARK: - UI Elements
    private lazy var habbitTitle: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16)
        label.tintColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = PaddedTextField()
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Введите название трекера"
        textField.borderStyle = .none
        textField.backgroundColor = .backgroundDayYp
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    // Метка для отображения максимального количества символов
    private lazy var maxLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .redYp
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true  // Закругление углов таблицы
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero  // Убираем внутренние отступы для разделителей
        tableView.separatorColor = .lightGray  // Цвет разделителей
        return tableView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
        
    }()
    
    private lazy var colorLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Цвет"
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
        
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerHabbitViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerHabbitViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Кнопка "Создать"
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    // Кнопка "Отменить"
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        return tapGesture
    }()
    
    private var categoryTitle: String? = "Важное"
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addGestureRecognizer(tapGesture)
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        optionsTableView.tableFooterView = UIView()
        
        setupViews()
        
        emojiCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        colorCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        updateCollectionViewHeights()
        
    }
    
    @objc
    private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        guard let text = titleTextField.text else { return }
        
        if !text.isEmpty && selectedEmoji != nil && selectedColor != nil && text.count <= 38 {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackDayYp
            
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .grayYp
        }
        
        if text.count > 38 {
            maxLengthLabel.isHidden = false
        } else {
            maxLengthLabel.isHidden = true
           
        }
    }
    
    @objc private func tapCancelButton() {
        dismiss(animated: true)
        trackerHabbitDelegate?.didTapCancelButton()
    }
    
    @objc private func didTapCreateButton() {
        guard
            let categoryTitle,
            let title = titleTextField.text, !title.isEmpty,
            let color = selectedColor,
            let emoji = selectedEmoji,
            !selectedSchedule.isEmpty else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: selectedSchedule,
            type: .habbit
        )
        if trackerHabbitDelegate == nil {
            print("⚠️ Делегат delegate2 не установлен")
        }
        
        trackerHabbitDelegate?.didTapCreateButton(categoryTitle: categoryTitle, trackerToAdd: newTracker)
        print("Создан новый трекер: \(newTracker)")
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func updateCollectionViewHeights() {
        let itemHeight: CGFloat = 52
        let itemsPerRow: CGFloat = 6
        let interItemSpacing: CGFloat = 5
        
        let emojiRows = ceil(CGFloat(Constants.emojis.count) / itemsPerRow)
        let colorRows = ceil(CGFloat(Constants.colors.count) / itemsPerRow)
        
        let emojiHeight = emojiRows * itemHeight + max(emojiRows - 1, 0) * interItemSpacing
        let colorHeight = colorRows * itemHeight + max(colorRows - 1, 0) * interItemSpacing
        
        emojiCollectionView.heightAnchor.constraint(equalToConstant: emojiHeight).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: colorHeight).isActive = true
    }
    
    private func presentScheduleViewController() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        present(scheduleVC, animated: true, completion: nil)
    }
    
    private func selectedScheduleString() -> String {
        guard !selectedSchedule.isEmpty else { return "" }
        
        let weekdayShortNames: [Weekday: String] = [
            .monday: "Пн",
            .tuesday: "Вт",
            .wednesday: "Ср",
            .thursday: "Чт",
            .friday: "Пт",
            .saturday: "Сб",
            .sunday: "Вс"
        ]
        
        let shortNames = selectedSchedule.compactMap { weekdayShortNames[$0] }
        return shortNames.joined(separator: ", ")
    }
    
    private func setupViews() {
        // Добавляем фиксированные элементы на основной view
        view.addSubview(habbitTitle)
        view.addSubview(titleTextField)
        view.addSubview(maxLengthLabel)
        view.addSubview(optionsTableView)
        
        // Настраиваем scrollView для скроллируемой части
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        // Добавляем элементы в scrollContentView (только скроллируемые части)
        scrollContentView.addSubview(emojiLabel)
        scrollContentView.addSubview(emojiCollectionView)
        scrollContentView.addSubview(colorLabel)
        scrollContentView.addSubview(colorCollectionView)
        
        // Добавляем кнопки на основной view
        view.addSubview(buttonContainerView)
        buttonContainerView.addSubview(cancelButton)
        buttonContainerView.addSubview(createButton)
        
        optionsTableViewTopConstraint = optionsTableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24)
        optionsTableViewTopConstraint?.isActive = true
        
        guard let constant = optionsTableViewTopConstraint else { return }
        
        // Констрейнты для фиксированных элементов
        NSLayoutConstraint.activate([
            habbitTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            habbitTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: habbitTitle.bottomAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            maxLengthLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            maxLengthLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            maxLengthLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Устанавливаем констрейнт с сохранением ссылки
            constant,
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Констрейнты для scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor)
        ])
        
        // Констрейнты для scrollContentView
        NSLayoutConstraint.activate([
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Обеспечиваем горизонтальный скроллинг
        ])
        
        // Констрейнты для скроллируемых элементов
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 0),
            emojiLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 28),
            emojiLabel.heightAnchor.constraint(equalToConstant: 52),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 28),
            colorLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -16)
        ])
        
        // Констрейнты для кнопок
        NSLayoutConstraint.activate([
            // Констрейнты для `buttonContainerView`
            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 66),
            
            cancelButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            cancelButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 16), // Отступ от верхнего края контейнера
            cancelButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            
            // Констрейнты для `createButton`
            createButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            createButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 16), // Отступ от верхнего края контейнера
            createButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
        ])
        
        // Настройка делегатов и источников данных
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        
        emojiCollectionView.allowsMultipleSelection = false
        colorCollectionView.allowsMultipleSelection = false
    }
    
    
    
    // MARK: - UITableViewDataSource
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // Категория и Расписание
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Устанавливаем высоту ячейки
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "optionCell")
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = categoryTitle
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.detailTextLabel?.textColor = .grayYp
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = selectedScheduleString()
            print("\(selectedScheduleString())")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.detailTextLabel?.textColor = .grayYp
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .backgroundDayYp
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            // Убираем разделитель для последней ячейки
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            // Восстанавливаем стандартный разделитель для остальных ячеек
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            titleTextField.resignFirstResponder()
            presentScheduleViewController()
        }
    }
    
    // Убираем отступы между секциями и ячейками
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0 // Убираем отступы перед секцией
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0 // Убираем отступы после секции
    }
    
    // Убираем отступы между ячейками
    func tableView(_ tableView: UITableView, layoutMarginsForItemAt indexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets.zero // Минимизируем отступы между ячейками
    }
    
}


extension TrackerHabbitViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == emojiCollectionView {
            return Constants.emojis.count
        } else if collectionView == colorCollectionView {
            return Constants.colors.count
        }
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? TrackerHabbitViewCell else {
                return UICollectionViewCell()
            }
            cell.titleLabel.text = Constants.emojis[indexPath.row]
            cell.colorView.isHidden = true // Скрываем colorView для Emoji ячейки
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? TrackerHabbitViewCell else {
                return UICollectionViewCell()
            }
            cell.innerColorView.backgroundColor = Constants.colors[indexPath.row]
            cell.titleLabel.isHidden = true // Скрываем текстовую метку для Color ячейки
            cell.colorView.isHidden = false
            return cell
        }
        return UICollectionViewCell()
    }
}

extension TrackerHabbitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerHabbitViewCell else { return }
        
        cell.titleLabel.backgroundColor = .lightGrayYp
        
        if collectionView == emojiCollectionView {
            selectedEmoji = Constants.emojis[indexPath.row]
        } else if collectionView == colorCollectionView {
            selectedColor = Constants.colors[indexPath.row]
            cell.colorView.layer.borderColor = selectedColor?.withAlphaComponent(0.3).cgColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerHabbitViewCell
        cell?.titleLabel.backgroundColor = .white
        cell?.colorView.layer.borderColor = UIColor.white.cgColor
    }
}

extension TrackerHabbitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5// Отступ между столбцами
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0 // Отступ между строками
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // Отступы вокруг коллекции
    }
}

extension TrackerHabbitViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ selectedDays: [Weekday]) {
        print("Selected days: \(selectedDays)")  // Печать для проверки
        selectedSchedule = selectedDays
        optionsTableView.reloadData()
    }
}