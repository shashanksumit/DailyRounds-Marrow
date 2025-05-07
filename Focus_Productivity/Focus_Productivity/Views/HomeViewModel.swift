//
//  HomeViewModel.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//

import Foundation

final class HomeViewModel {
    private let focusService: FocusServiceProtocol

    init(focusService: FocusServiceProtocol = FocusService.shared) {
        self.focusService = focusService
    }

    func startFocusMode(_ mode: FocusMode) {
        focusService.startSession(mode: mode)
    }

    func getFocusModes() -> [FocusMode] {
        return FocusMode.allCases
    }
}
