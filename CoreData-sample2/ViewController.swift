//
//  ViewController.swift
//  CoreData-sample2
//
//  Created by Keisuke Yamaguchi on 2018/05/21.
//  Copyright © 2018年 Keisuke Yamaguchi. All rights reserved.
//

import UIKit
import CoreStore


private struct Static {

    static let maleConfiguration = "Default"
    static let maleConfiguration2 = "Default2"

    static let facebookStack: DataStack = {

        let dataStack = DataStack(xcodeModelName: "CoreData_sample2")
//        try! dataStack.addStorageAndWait(
//            SQLiteStore(
//                fileName: "AccountsDemo_FB_Male.sqlite",
//                configuration: maleConfiguration,
//                localStorageOptions: .recreateStoreOnModelMismatch
//            )
//        )
//

        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "AccountsDemo_FB_Male2.sqlite",
                configuration: maleConfiguration,
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )

        _ = try? dataStack.perform(
            synchronous: { (transaction) in

                //transaction.deleteAll(From<SampleEntity>())
//                let account2 = transaction.create(Into<SampleEntity>(maleConfiguration)) //これか？
                let account2 = transaction.create(Into<SampleEntity>()) //これか？
                //let account3 = transaction.create(Into<SampleEntity>(maleConfiguration2))
                account2.attribute = "sample"

                // 原因がなんなのかわからない。
                // Configuration ってどー影響してるのかわからない。
                // 後回しでいいかー。Defaultだけ使ってるし

            }
        )

        return dataStack
    }()



    static let twitterStack: DataStack = {

        let dataStack = DataStack(xcodeModelName: "CoreData_sample2")
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "AccountsDemo_FB_Male2.sqlite",
                configuration: maleConfiguration,
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        _ = try? dataStack.perform(
            synchronous: { (transaction) in
                
                let ent = transaction.create(Into<SampleEntity>()) //これか？
                ent.attribute = "attr for relationship"
                
                let account2 = transaction.create(Into<SampleThreadEntity>())
                account2.relationship = ent
                

            }
        )

        return dataStack
    }()
    
    
    /*
     
     let jane: MyPersonEntity = // ...
     let john: MyPersonEntity = // ...
     
     CoreStore.beginAsynchronous { (transaction) -> Void in
         // WRONG: jane.friends = [john]
         // RIGHT:
         let jane = transaction.edit(jane)
         let john = transaction.edit(john)
         jane.friends = [john]
         transaction.commit()
     }
     
     */











}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //  ❗ [CoreStore: Fatal Error] BaseDataTransaction.swift:108 create
        // ↪︎ Attempted to create an entity of type 'SampleEntity' into the configuration "Default", which it doesn't belong to.

        debugPrint(Static.facebookStack)


        let d = Static.facebookStack.fetchAll(From(SampleEntity.self))
        debugPrint(d?.count)

        for c in d! {
            debugPrint(c.attribute)
        }

        
        let a = Static.twitterStack.fetchAll(From(SampleThreadEntity.self))
        debugPrint(a)
        
        for aa in a! {
            debugPrint(aa)
            
            debugPrint(aa.relationship?.attribute)
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

