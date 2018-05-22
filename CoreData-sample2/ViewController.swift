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

    static let facebookStack: DataStack = {

        let dataStack = DataStack(xcodeModelName: "CoreData_sample2")
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "AccountsDemo_FB_Male.sqlite",
                configuration: maleConfiguration,
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )

        _ = try? dataStack.perform(
            synchronous: { (transaction) in

                transaction.deleteAll(From<SampleEntity>())
                let account2 = transaction.create(Into<SampleEntity>(maleConfiguration))

            }
        )

        return dataStack
    }()
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //  ❗ [CoreStore: Fatal Error] BaseDataTransaction.swift:108 create
        // ↪︎ Attempted to create an entity of type 'SampleEntity' into the configuration "Default", which it doesn't belong to.

        debugPrint(Static.facebookStack)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

