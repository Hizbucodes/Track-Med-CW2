//
//  NotificationModel.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation

enum NotificationType {
    case medication
    case appointment
    case refill
}

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let time: Date
    let type: NotificationType
}
