//
//  BiometricAuthService.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation
import LocalAuthentication

class BiometricAuthService {
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    static func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                 default:
                    return .none
                }
            } else {
                return .touchID
            }
        }
        
        return .none
    }
    
    static func isBiometricAvailable() -> (Bool, String?) {
        let context = LAContext()
        var error: NSError?
        
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let errorMessage = error?.localizedDescription
        
        return (available, errorMessage)
    }
    
    static func authenticate(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your medical data"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        completion(false, "Authentication failed")
                    }
                }
            }
        } else if let error = error {
            completion(false, error.localizedDescription)
        } else {
            completion(false, "Biometric authentication not available")
        }
    }
}
