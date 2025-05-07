//
//  ViewController.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    
    
    private var viewModel: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = HomeViewModel()
        title = "Focus & Productivity App"
    }

    @IBAction func focusButtonTapped(_ sender: Any) {
        guard let title = (sender as? UIButton)?.titleLabel?.text,
              let mode = FocusMode(rawValue: title) else { return }
                viewModel.startFocusMode(mode)
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        
    }
    
}

