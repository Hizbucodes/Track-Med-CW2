//
//  User.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var name: String
    var profileImageUrl: String?
    var language: String = "en" // Default language: English
    var useBiometricAuth: Bool = false
}
