//
//  EventItem.swift
//  MainIgrisv2
//
//  Created by Joey Russell on 2/22/25.
//

import Foundation
import FirebaseFirestoreSwift

// Event model
struct EventItem: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var userId: String
    var name: String
    var description: String
    var startDate: Date
    var repeatInterval: String?
    var uid: String?

    // Custom initializer matching your desired argument labels
    init(id: String? = nil,
         userId: String,
         name: String,
         description: String,
         startDate: Date,
         repeatInterval: String?,
         uid: String? = nil) {
      self.id = id
      self.userId = userId
      self.name = name
      self.description = description
      self.startDate = startDate
      self.repeatInterval = repeatInterval
      self.uid = uid
    }

}
