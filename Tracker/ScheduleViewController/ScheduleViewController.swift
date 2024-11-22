//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Mac on 20.11.2024.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject{
    func didSelectSchedule(_ selectedDays: [Weekday])
}


final class ScheduleViewController: UIViewController{
    
    let daysOfWeek = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true  
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .zero
        tableView.separatorColor = .lightGray
        return tableView
    }()
    
    private let scheduleLabel: UILabel = {
        let scheduleLabel = UILabel()
        scheduleLabel.text = "Расписание"
        scheduleLabel.font = UIFont.systemFont(ofSize: 16)
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        return scheduleLabel
        
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .blackDayYp
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedDays = Set<Weekday>()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpConstrains()
    }
    
    func setUpConstrains() {
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(scheduleLabel)
        view.addSubview(doneButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scheduleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scheduleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheduleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            tableView.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),

            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didTapDoneButton() {
        delegate?.didSelectSchedule(Array(selectedDays))
        dismiss(animated: true, completion: nil)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? SwitchTableViewCell else {
            return UITableViewCell()
        }
        
        let weekdayIndex = (indexPath.row + 1) % 7 + 1
        guard let weekday = Weekday(rawValue: weekdayIndex) else { return UITableViewCell() }
        
        cell.textLabel?.text = daysOfWeek[indexPath.row]
        
        cell.switchControl.tag = weekday.rawValue
        cell.switchControl.addTarget(self, action: #selector(didChangeSwitch(_:)), for: .valueChanged)
        
        cell.switchControl.isOn = selectedDays.contains(weekday)
        
        return cell
    }

    @objc private func didChangeSwitch(_ sender: UISwitch) {
        guard let day = Weekday(rawValue: sender.tag) else {
            return
        }
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            
            selectedDays.remove(day)
        }
    }
}
