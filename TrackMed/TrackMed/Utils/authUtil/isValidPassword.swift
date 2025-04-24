//
//  isValidPassword.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-24.
//

import Foundation

func isValidPassword(_ password: String) -> Bool {
    // Example: at least 6 characters (Firebase minimum), at least one number
    let passwordRegEx = "^(?=.*[0-9]).{6,}$"
    let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordPred.evaluate(with: password)
}
