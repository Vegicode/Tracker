//
//  Trackers.swift
//  Tracker
//
//  Created by Mac on 29.10.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private lazy var addTrackerButton: UIButton = {
        
        let addView = UIButton.systemButton(
            with: UIImage(named: "plus") ?? UIImage(),
            target: nil,
            action: nil
        )
        addView.tintColor = .blackDayYp
        addView.translatesAutoresizingMaskIntoConstraints = false
        addView.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return addView
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.text = "Трекеры"
        label1.font = UIFont.boldSystemFont(ofSize: 34)
        
        return label1
        
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let date = UIDatePicker()
        date.datePickerMode = .date
        date.locale = Locale(identifier: "ru_RU")
        date.preferredDatePickerStyle = .compact
        date.tintColor = .blueYp
        date.backgroundColor = .backgroundDayYp
        date.layer.cornerRadius = 8
        date.layer.masksToBounds = true
        date.translatesAutoresizingMaskIntoConstraints = false
        date.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        date.maximumDate = Date()
        return date
    }()
    
    private lazy var trackerSearchBar: UISearchTextField = {
        let searchBar = UISearchTextField()
        searchBar.backgroundColor = .backgroundDayYp
        searchBar.textColor = .blackDayYp
        searchBar.layer.cornerRadius = 8
        searchBar.layer.masksToBounds = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: attributes
        )
        searchBar.attributedPlaceholder = attributedPlaceholder
        searchBar.delegate = self
      
        return searchBar
    }()
    
    private lazy var emptyPlaceholderImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "1"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false

        return image
        
    }()
    
    private lazy var emptyPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font =
            .systemFont(ofSize: 12)
        label.textColor = .black
        label.sizeToFit()
        
        return label
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        
        return collectionView
        
    }()
    
    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Обязательно", trackers: [
            Tracker(id: UUID(), title: "Поесть курицу", color: .colorSelection1, emoji: "🍔", schedule: [.monday], type: .habbit),
            Tracker(id: UUID(), title: "Попить воду", color: .colorSelection2, emoji: "😺", schedule: [.monday], type: .habbit),
            Tracker(id: UUID(), title: "Поспать", color: .colorSelection5, emoji: "🌸", schedule: [.monday], type: .habbit),
            
            Tracker(id: UUID(), title: "Не забыть сьездить на пары", color: .colorSelection8, emoji: "❤️", schedule: [.tuesday], type: .habbit),
        ]),
        TrackerCategory(title: "Невероятно", trackers: [
            Tracker(id: UUID(), title: "Поцеловать собаку и кота перед выходом", color: .colorSelection12, emoji: "🐶", schedule: [.monday, .wednesday, .tuesday], type: .habbit)
        ])
    ]
    
    private var filteredCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewTrackerNotification(_ :)), name: .didCreateNewTracker, object: nil)
        setupTrackerView()
        updateUI()
        setupCollectionView()
    }
    
    private func setupTrackerView() {
        view.addSubview(addTrackerButton)
        view.addSubview(trackerLabel)
        view.addSubview(datePicker)
        view.addSubview(trackerSearchBar)

        view.addSubview(emptyPlaceholderImageView)
        view.addSubview(emptyPlaceholderLabel)
        view.addSubview(collectionView)

        setupConstraints()
    }
    
    private func setupConstraints() {
        
        
        addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        addTrackerButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addTrackerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        trackerLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor).isActive = true
        trackerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        trackerLabel.heightAnchor.constraint(equalToConstant: 41).isActive = true

        datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor).isActive = true
        
        trackerSearchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7).isActive = true
        trackerSearchBar.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor).isActive = true
        trackerSearchBar.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor).isActive = true
        trackerSearchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        emptyPlaceholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        emptyPlaceholderImageView.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor,constant: 220).isActive = true
        emptyPlaceholderImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        emptyPlaceholderImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        emptyPlaceholderLabel.topAnchor.constraint(equalTo: emptyPlaceholderImageView.bottomAnchor, constant: 8).isActive = true
        emptyPlaceholderLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor, constant: 20).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    @objc private func didReceiveNewTrackerNotification(_ notification: Notification){
        guard let newTracker = notification.object as? Tracker else { return }
        
        var updatedCategories: [TrackerCategory] = []
        
        var trackerAdded = false
        
        for category in categories {
            if category.title == "Нужная категория" {
                var updatedTrackers = category.trackers
                updatedTrackers.append(newTracker)
                
                let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
                updatedCategories.append(updatedCategory)
                trackerAdded = true
            } else {
                updatedCategories.append(category)
            }
        }
        
        if !trackerAdded {
            let newCategory = TrackerCategory(title: "Новая категория", trackers: [newTracker])
            updatedCategories.append(newCategory)
        }
        
        categories = updatedCategories
        updateUI()
    }
    
    private func updateUI() {
        collectionView.reloadData()
        datePickerValueChanged()
    }
    
    @objc private func datePickerValueChanged(){
        reloadFilteredCategories()
    }
 

    
    @objc
    private func didTapButton() {
        let trackerCreateVC = TrackerCreateViewController()
        if let navigationController = self.navigationController{
            navigationController.pushViewController(trackerCreateVC, animated: true)
        }else{
            trackerCreateVC.modalPresentationStyle = .pageSheet
            present(trackerCreateVC, animated:true, completion: nil)
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(TrackerCategoryHeaderView.self,forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,withReuseIdentifier: TrackerCategoryHeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    private func reloadFilteredCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = (trackerSearchBar.text ?? "").lowercased()
        print("Search filter: \(filterText)")
        
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                    tracker.title.lowercased().contains(filterText)
                print("Checking tracker title: \(tracker.title), condition: \(textCondition)")

                let dateCondition = tracker.schedule.contains { weekDay in
                    print("Checking weekday: \(weekDay.rawValue), filter weekday: \(filterWeekday)")
                    return weekDay.rawValue == filterWeekday
                }
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                    title: category.title,
                    trackers: trackers
            )
        }
        collectionView.reloadData()
        reloadPlaceholder()
        
    }
    
    private func reloadPlaceholder() {
        let isEmpty = filteredCategories.isEmpty
        emptyPlaceholderImageView.isHidden = !isEmpty
        emptyPlaceholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        if let tracker = filteredCategories
            .flatMap({ $0.trackers })
            .first(where: { $0.id == id }),
           tracker.type == .event {
            return completedTrackers.contains { $0.trackerID == id }
        }

        return completedTrackers.contains {
            $0.trackerID == id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date)
        }
    }
}


extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
  

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays: Int
        
        if tracker.type == .event {
            completedDays = completedTrackers.contains { $0.trackerID == tracker.id } ? 1 : 0 
        } else {
            completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
        }
        
        cell.configure(with: tracker,
                       isCompletedToday: isCompletedToday,
                       indexPath: indexPath,
                       completedDays: completedDays)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeaderView.identifier, for: indexPath) as? TrackerCategoryHeaderView else { return UICollectionReusableView() }
            let category = filteredCategories[indexPath.section]
            header.configure(with: category.title)
            return header
        }
        return UICollectionReusableView()
    }
    
}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        guard let tracker = filteredCategories
                .flatMap({ $0.trackers })
                .first(where: { $0.id == id }) else { return }

        // Привычка: Добавляем запись за текущий день
        if tracker.type == .habbit {
            let isAlreadyCompleted = completedTrackers.contains {
                $0.trackerID == id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date)
            }
            guard !isAlreadyCompleted else { return }

            let trackerRecord = TrackerRecord(trackerID: id, date: datePicker.date)
            completedTrackers.append(trackerRecord)
        }

       
        else if tracker.type == .event {
            if completedTrackers.contains(where: { $0.trackerID == id }) {
                uncompleteTracker(id: id, at: indexPath)
                return
            } else {
                completedTrackers.append(TrackerRecord(trackerID: id, date: Date.distantPast))
            }
        }

        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        guard let tracker = filteredCategories
                .flatMap({ $0.trackers })
                .first(where: { $0.id == id }) else { return }

       
        if tracker.type == .habbit {
            completedTrackers.removeAll { trackerRecord in
                trackerRecord.trackerID == id &&
                Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            }
        }

       
        else if tracker.type == .event {
            completedTrackers.removeAll { $0.trackerID == id }
        }

        collectionView.reloadItems(at: [indexPath])
    }
    
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 + 9 // Отступы между ячейками и краями экрана
        let availableWidth = collectionView.bounds.width - padding
        let cellWidth = availableWidth / 2 - 8 // 8 пикселей для отступа между ячейками
        
        return CGSize(width: cellWidth, height: 120)
    }

   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40) // Высота заголовка секции
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
    }
    
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension Notification.Name {
    static let didCreateNewTracker = Notification.Name("didCreateNewTracker")
}


