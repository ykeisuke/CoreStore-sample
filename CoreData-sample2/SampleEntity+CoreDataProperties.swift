//
//  SampleEntity+CoreDataProperties.swift
//  
//
//  Created by Keisuke Yamaguchi on 2018/05/24.
//
//

import Foundation
import CoreData


extension SampleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SampleEntity> {
        return NSFetchRequest<SampleEntity>(entityName: "SampleEntity")
    }

    @NSManaged public var attribute: String?
    @NSManaged public var relationship: SampleThreadEntity?

}
