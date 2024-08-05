//
//  TaskItem+CoreDataProperties.swift
//  TodoCoreData
//
//  Created by Swayam Rustagi on 05/08/24.
//
//

import Foundation
import CoreData


extension TaskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var taskImage: String?

}

extension TaskItem : Identifiable {

}
