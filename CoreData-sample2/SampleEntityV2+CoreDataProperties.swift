//
//  SampleEntity+CoreDataProperties.swift
//  
//
//  Created by Keisuke Yamaguchi on 2018/05/24.
//
//

import Foundation
import CoreData


extension SampleEntityV2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SampleEntityV2> {
        return NSFetchRequest<SampleEntityV2>(entityName: "SampleEntity")
    }

    @NSManaged public var attribute: String?
    @NSManaged public var memo: String?
    @NSManaged public var relationship: SampleThreadEntityV2?

}
