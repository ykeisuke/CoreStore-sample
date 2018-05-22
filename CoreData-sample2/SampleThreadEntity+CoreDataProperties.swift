//
//  SampleThreadEntity+CoreDataProperties.swift
//  
//
//  Created by Keisuke Yamaguchi on 2018/05/22.
//
//

import Foundation
import CoreData


extension SampleThreadEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SampleThreadEntity> {
        return NSFetchRequest<SampleThreadEntity>(entityName: "SampleThreadEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var attribute: String?
    @NSManaged public var relationship: SampleEntity?

}
