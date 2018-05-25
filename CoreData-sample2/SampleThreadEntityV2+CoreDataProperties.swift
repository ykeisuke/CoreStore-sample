//
//  SampleThreadEntity+CoreDataProperties.swift
//  
//
//  Created by Keisuke Yamaguchi on 2018/05/22.
//
//

import Foundation
import CoreData


extension SampleThreadEntityV2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SampleThreadEntityV2> {
        return NSFetchRequest<SampleThreadEntityV2>(entityName: "SampleThreadEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var attribute: String?
    @NSManaged public var memo: String?
    @NSManaged public var relationship: SampleEntityV2?

}
