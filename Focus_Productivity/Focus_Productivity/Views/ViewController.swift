//
//  ViewController.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopFocusButton: UIButton!
    @IBOutlet weak var focusModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    //Removed context from here
    
    var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the view model.  Use self as the delegate.
        viewModel = HomeViewModel(delegate: self)
        setupUI()
        
    }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = CoreDataHelper.shared.mainContext()
        viewModel.loadCurrentSession(context: context)
        
         if let user = viewModel.getUser(context: context) { //get user data
             //do nothing
         } else {
             //if user is nil, create new user.
             let initialImage = UIImage(named: "profile_placeholder")!
             viewModel.saveUser(name: "New User", image: initialImage, context: context)
         }
    }
    
    deinit {
        // Invalidate the timer in deinit
        viewModel.timer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        timerLabel.text = "00:00"
        stopFocusButton.setTitle("Start Focusing", for: .normal)
        
        // Setup segmented control
        for (index, mode) in HomeViewModel.FocusMode.allCases.enumerated() {
            focusModeSegmentedControl.setTitle(mode.rawValue, forSegmentAt: index)
        }
        focusModeSegmentedControl.selectedSegmentIndex = 0
        
        //Profile button
        profileButton.setTitle("Profile", for: .normal)
        profileButton.backgroundColor = .systemBlue
        profileButton.tintColor = .white
        profileButton.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    @IBAction func focusModeChanged(_ sender: UISegmentedControl) {
        //update selected mode
        viewModel.selectedMode = HomeViewModel.FocusMode.allCases[sender.selectedSegmentIndex]
        
        let context = CoreDataHelper.shared.mainContext()
        // If timer is running, stop it and restart with the new mode.
        if viewModel.timer != nil {
            viewModel.stopTimer(context: context)
            viewModel.timeInSeconds = 0 // Reset time
            timerLabel.text = "00:00"
            viewModel.startTimer(context: context)
        }
    }
    
    @IBAction func stopFocusButtonTapped(_ sender: UIButton) {
        let context = CoreDataHelper.shared.mainContext()
        if viewModel.timer != nil {
            viewModel.stopTimer(context: context)
            stopFocusButton.setTitle("Start Focusing", for: .normal)
        } else {
            viewModel.startTimer(context: context)
            stopFocusButton.setTitle("Stop Focusing", for: .normal)
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        if let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController {
            // Pass the context
            profileVC.managedContext = CoreDataHelper.shared.mainContext()
            navigationController?.pushViewController(profileVC, animated: true)
        } else {
            print("Error: Could not instantiate ProfileViewController")
        }
    }
    
}

// MARK: - Home View Delegate Extension
extension HomeViewController: HomeViewDelegate {
    func updateTimerLabel(timeString: String) {
        timerLabel.text = timeString
    }
    
    func displayBadge(badge: String) {
        badgeLabel.text = "Badge: \(badge)"
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updatePointsAndBadge() {
        let context = CoreDataHelper.shared.mainContext()
        viewModel.updatePointsAndBadge(context: context)
    }
    
    func updateUIForActiveSession() {
        stopFocusButton.setTitle("Stop Focusing", for: .normal)
        focusModeSegmentedControl.selectedSegmentIndex = HomeViewModel.FocusMode.allCases.firstIndex(of: viewModel.selectedMode) ?? 0
    }
}

