//
//  isValidPassword.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-24.
//

import Foundation

func isValidPassword(_ password: String) -> Bool {
    let passwordRegEx = "^(?=.*[0-9]).{6,}$"
    let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordPred.evaluate(with: password)
}
