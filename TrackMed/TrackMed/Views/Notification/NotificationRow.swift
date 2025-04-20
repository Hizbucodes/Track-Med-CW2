////
////  NotificationRow.swift
////  TrackMed
////
////  Created by Hizbullah 006 on 2025-04-20.
////
//
//import SwiftUI
//
//struct NotificationRow: View {
//    let notification: NotificationItem
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            // Icon based on notification type
//            Image(systemName: iconName)
//                .foregroundColor(iconColor)
//                .font(.title2)
//                .padding(.top, 4)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(notification.title)
//                    .font(.headline)
//                Text(notification.message)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                Text(formattedTime)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
//        .padding(.vertical, 8)
//    }
//
//    private var iconName: String {
//        switch notification.type {
//        case .medication: return "pills"
//        case .appointment: return "calendar"
//        case .refill: return "arrow.triangle.2.circlepath"
//        }
//    }
//
//    private var iconColor: Color {
//        switch notification.type {
//        case .medication: return .blue
//        case .appointment: return .green
//        case .refill: return .orange
//        }
//    }
//
//    private var formattedTime: String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        formatter.dateStyle = .none
//        return formatter.string(from: notification.time)
//    }
//}
//
