//
//  ProfileViewController.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//
import UIKit
import CoreData

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var badgesLabel: UILabel!
    @IBOutlet weak var recentSessionsTableView: UITableView!
    
     var managedContext: NSManagedObjectContext!
    
    var viewModel: ProfileViewModel!
    var user: User?
    var sessions: [Session] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ProfileViewModel(delegate: self)
        setupUI()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        recentSessionsTableView.dataSource = self
        recentSessionsTableView.delegate = self
        recentSessionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SessionCell")
        
        // Set default values.  These will be updated in loadData.
        userNameLabel.text = "Loading..."
        totalPointsLabel.text = "Total Points: 0"
        badgesLabel.text = "Badges: "
    }
    
     // MARK: - Data Loading
    private func loadData() {
        guard let context = managedContext else {
            // Handle the error appropriately, e.g., show an alert.
            let alert = UIAlertController(title: "Error", message: "Could not get Core Data context.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        user = viewModel.getUser(context: context)
        sessions = viewModel.fetchRecentSessions(context: context)
        let totalPoints = viewModel.getTotalPoints(context: context)
        let badges = viewModel.getAllBadges(context: context)
        print("Badges array: \(badges)")
        
        updateUI(user: user, totalPoints: totalPoints, badges: badges)
        
        recentSessionsTableView.reloadData()
    }
    
    // MARK: - Update UI
    private func updateUI(user: User?, totalPoints: Int, badges: [String]) {
        if let user = user {
            userNameLabel.text = user.name ?? "No Name"
            if let imageData = user.image, let image = UIImage(data: imageData) {
                userImageView.image = image
            } else {
                userImageView.image = UIImage(named: "profile_placeholder") // Use placeholder
            }
        } else {
            userNameLabel.text = "No User"
            userImageView.image = UIImage(named: "profile_placeholder")
        }
        
        totalPointsLabel.text = "Total Points: \(totalPoints)"
        
        if badges.isEmpty {
            badgesLabel.text = "No Badges"
        } else {
            badgesLabel.text = "Badges: \(badges.joined(separator: ", "))"
        }
    }
    
}

// MARK: - Profile View Delegate Extension
extension ProfileViewController: ProfileViewDelegate {
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Delegate and Data Source
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath)
        
        let session = sessions[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startTimeString = dateFormatter.string(from: session.startTime ?? Date())
        
        cell.textLabel?.text = "Mode: \(session.mode ?? "Unknown"), Duration: \(session.duration) seconds, Points: \(session.points), Start: \(startTimeString)"
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}
