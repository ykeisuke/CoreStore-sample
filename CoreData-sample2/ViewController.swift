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




    typealias ModelMetadata = (label: String, entityType: NSManagedObject.Type, schemaHistory: SchemaHistory)
    static let models: [ModelMetadata] = [
        (
            label: "Model V1",
            entityType: SampleEntity.self,
            schemaHistory: SchemaHistory(
                XcodeDataModelSchema.from(
                    modelName: "CoreData_sample2",
                    migrationChain: ["CoreData_sample2v2", "CoreData_sample2"]
                ),
                migrationChain: ["CoreData_sample2v2", "CoreData_sample2"]
            )
        ),
        (
            label: "Model V2",
            entityType: SampleEntityV2.self,
            schemaHistory: SchemaHistory(
                XcodeDataModelSchema.from(
                    modelName: "CoreData_sample2",
                    migrationChain: [
                        "CoreData_sample2": "CoreData_sample2v2"
                    ]
                ),
                migrationChain: [
                    "CoreData_sample2": "CoreData_sample2v2",
                ]
            )
        )
    ]


    static let twitterStackV2: DataStack = {

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

                let ent = transaction.create(Into<SampleEntityV2>()) //これか？
                ent.attribute = "あたたたたたた"
                ent.memo = "よ"

                let account2 = transaction.create(Into<SampleThreadEntityV2>())
                account2.relationship = ent
                account2.memo = "YO"


            }
        )

        return dataStack
    }()

}


class ViewController: UIViewController, ListObserver {

    //typealias ListEntityType =
    func listMonitorWillChange(_ monitor: ListMonitor<NSManagedObject>) {
        debugPrint("Will change")
    }

    func listMonitorDidChange(_ monitor: ListMonitor<NSManagedObject>) {
        debugPrint("Did change")
    }

    func listMonitorDidRefetch(_ monitor: ListMonitor<NSManagedObject>) {
        debugPrint("Did refetch")
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //  ❗ [CoreStore: Fatal Error] BaseDataTransaction.swift:108 create
        // ↪︎ Attempted to create an entity of type 'SampleEntity' into the configuration "Default", which it doesn't belong to.

        //debugPrint(Static.facebookStack)

        /*
        let d = Static.facebookStack.fetchAll(From(SampleEntity.self))
        debugPrint(d?.count)

        for c in d! {
            debugPrint(c.attribute)
        }
*/

        //fetchOld()

        // MigrationSample
        mig()

        //fetchNewVersion()

    }

    func fetchOld() {
        let a = Static.twitterStack.fetchAll(From(SampleThreadEntity.self))
        debugPrint(a?.count)

        for aa in a! {
            debugPrint(aa.relationship?.attribute)
        }

    }

    func fetchNewVersion() {

        let a = Static.twitterStackV2.fetchAll(From(SampleThreadEntityV2.self))
        for aa in a! {
            debugPrint(aa.attribute)
            debugPrint(aa.memo)
            debugPrint(aa.relationship?.attribute)
            debugPrint(aa.relationship?.memo)
        }



    }


    private var _dataStack: DataStack?
    private var dataStack: DataStack? {
        return self._dataStack
    }
    private var _listMonitor: ListMonitor<NSManagedObject>?
    private var listMonitor: ListMonitor<NSManagedObject>? {
        return self._listMonitor
    }

    private func set(dataStack: DataStack?, model: Static.ModelMetadata?, scrollToSelection: Bool) {

        if let dataStack = dataStack, let model = model {
            self._dataStack = dataStack
            let listMonitor = dataStack.monitorList(
                From(model.entityType),
                OrderBy<NSManagedObject>(.descending(#keyPath(SampleEntity.attribute)))
            )
            listMonitor.addObserver(self)
            self._listMonitor = listMonitor
        }
        else {
            self._dataStack = nil
        }
    }


    private func selectModelVersion(_ model: Static.ModelMetadata) {

        // ここはアプリ内のDBと、現在のModelのバージョンを比較してる
        if self.dataStack?.modelVersion == model.schemaHistory.currentModelVersion {
            return
        }

        // ここは？？
        // 明示的に、Cleanアップする
        // なにを？
        // NSPersistentStoreを.
        // NSPersistentStore ってなに?
        // このクラスは、全てのCore Data永続ストアのための抽象基本クラスです。
        // http://secondflush2.blog.fc2.com/blog-entry-1015.html
        //self.set(dataStack: nil, model: nil, scrollToSelection: false) // explicitly trigger NSPersistentStore cleanup by deallocating the stack


        // model.schemaHistory で----?
        // 履歴を元に作られたDataStackオブジェクトを用意するため。
        let dataStack = DataStack(schemaHistory: model.schemaHistory)

        // マイグレーション中は操作させないようにする処理
//        self.setEnabled(false)


        // マイグレーション処理の中核。
        // 非同期で、stackにLocalStorageのやつを追加する。`default` で初期化される
        // defaultって難だよ
        let progress = dataStack.addStorage(

            // SQLiteのストレージを用意する
            SQLiteStore(
                // ファイル名を定義する
                fileName: "AccountsDemo_FB_Male2.sqlite",

                // : an array of `SchemaMappingProviders` that provides the complete mapping models for custom migrations. All lightweight inferred mappings and/or migration mappings provided by *xcmappingmodel files are automatically used as fallback (as `InferredSchemaMappingProvider`) and may be omitted from the array.
                // とのことで、xcmappingmodel は引数から除外されるとのこと。
                // つまり、ココに書いていないから、きちんと書く必要がある？
                migrationMappingProviders: [
                    CustomSchemaMappingProvider(
                        from: "CoreData_sample2",
                        to: "CoreData_sample2v2",
                        entityMappings: [
                                .transformEntity(
                                    sourceEntity: "SampleEntity", // SimpleEntity と SampleEntityか....
                                    destinationEntity: "SampleEntityV2",
                                    transformer: { (source, createDestination) in

                                        let destination = createDestination()
                                        destination.enumerateAttributes { (attribute, sourceAttribute) in

                                            if let sourceAttribute = sourceAttribute {

                                                destination[attribute] = source[sourceAttribute]
                                            }
                                        }
                                        //destination["numberOfFlippers"] = source["numberOfLimbs"]
                                        destination["memo"] = "MigrationSample"
                                    }
                                ),
                                .transformEntity(
                                    sourceEntity: "SampleThreadEntity",
                                    destinationEntity: "SampleThreadEntityV2",
                                    transformer: { (source, createDestination) in

                                        let destination = createDestination()
                                        destination.enumerateAttributes { (attribute, sourceAttribute) in

                                            if let sourceAttribute = sourceAttribute {

                                                destination[attribute] = source[sourceAttribute]
                                            }
                                        }
                                        destination["memo"] = "MigrationSample"
                                    }
                                )
                        ]
                    )
                ]
            ),
            completion: { [weak self] (result) -> Void in

                guard let `self` = self else {

                    return
                }

                guard case .success = result else {
                    debugPrint("fail")
                    return
                }
                debugPrint("Success")
                //self.self.fetchNewVersion()
                
                let a2 = dataStack.fetchAll(From(SampleThreadEntityV2.self))
                
                for aa in a2! {
                    debugPrint(aa.attribute)
                    debugPrint(aa.memo)
                    debugPrint(aa.relationship?.attribute)
                    debugPrint(aa.relationship?.memo)
                }
                
                let a3 = dataStack.fetchAll(From(SampleEntityV2.self))
                
                for aa in a3! {
                    debugPrint(aa.attribute)
                    debugPrint(aa.memo)
                }

/*
                self.set(dataStack: dataStack, model: model, scrollToSelection: true)

                let oo = self.listMonitor?[0]

                //debug self.listMonitor[0]
                var lines = [String]()
                for aa in (oo?.entity.properties)! {
                    let value = aa.value(forKey: aa.name) ?? NSNull()
                    lines.append("\(aa.name): \(value)")
                }
                debugPrint(lines.joined(separator: "\n"))

*/
                //self.fetchNewVersion()
            }
        )

        if let progress = progress {
            progress.setProgressHandler { [weak self] (progress) -> Void in
                debugPrint("progress\(progress)")
            }
        }
    }


    func mig() {
        debugPrint("Migration:")
        /*
         Migration に失敗する。
         なぜ失敗するんだ？
         modelVersionが実際と違うから？
         先に新しいバージョンのデータが入ってしまってるのがだめ？
         　→ 可能性有る。
            → Uninstallして古いバージョンにして試すと良い。 -> NO だめだった
         
        
         ❗ [CoreStore: Assertion Failure]
         CustomSchemaMappingProvider.swift:634
         resolveEntityMappings(sourceModel:destinationModel:)
         
         Value:  'transformEntity(sourceEntity: "SimpleEntity", destinationEntity: "SimpleEntity", transformer: (Function))'
         
         ↪︎ A 'CustomMapping' with Value passed to 'CustomSchemaMappingProvider' could not be mapped to any 'NSEntityDescription' from the source 'NSManagedObjectModel'.
         -> SampleとSimpleをtypoしててだめたった。くそが。
         
         */
        // When index is 1, version 2.

        var _dataStack: DataStack? = nil

        self.set(dataStack: nil, model: nil, scrollToSelection: false)

        let modelMetadata = withExtendedLifetime(DataStack(xcodeModelName: "CoreData_sample2")) { (dataStack: DataStack) -> Static.ModelMetadata in

            let models = Static.models
            let migrations = try! dataStack.requiredMigrationsForStorage(
                SQLiteStore(fileName: "AccountsDemo_FB_Male2.sqlite")
            )

            guard let storeVersion = migrations.first?.sourceVersion else {
                return models.first!
            }
            for model in models {

                if model.schemaHistory.currentModelVersion == storeVersion {

                    return model
                }
            }

            return models.first!
        }

        self.selectModelVersion(modelMetadata)

    }



    /*
        // MigrationがErrorでるのは、元データの作り方が違うからか？？？

        //self.set(dataStack: nil, model: nil, scrollToSelection: false) // explicitly trigger NSPersistentStore cleanup by deallocating the stack

        let dataStack = DataStack(schemaHistory: modelMetadata.schemaHistory)
        let _ = dataStack.addStorage(
            SQLiteStore(
                fileName: "AccountsDemo_FB_Male2v2.sqlite",
                migrationMappingProviders: [
                    CustomSchemaMappingProvider(
                        from: "CoreData_sample2",
                        to: "CoreData_sample2v2",
                        entityMappings: [
                                .transformEntity(
                                    sourceEntity: "SimpleEntity",
                                    destinationEntity: "SimpleEntityV2", // これか？
                                    transformer: { (source, createDestination) in

                                        let destination = createDestination()
                                        destination.enumerateAttributes { (attribute, sourceAttribute) in

                                            if let sourceAttribute = sourceAttribute {

                                                destination[attribute] = source[sourceAttribute]
                                            }
                                        }
                                        //destination["numberOfFlippers"] = source["numberOfLimbs"]
                                        destination["memo"] = "MigrationSample"
                                    }
                                ),
                                .transformEntity(
                                    sourceEntity: "SimpleThreadEntity",
                                    destinationEntity: "SimpleThreadEntityV2", // これか？
                                    transformer: { (source, createDestination) in

                                        let destination = createDestination()
                                        destination.enumerateAttributes { (attribute, sourceAttribute) in

                                            if let sourceAttribute = sourceAttribute {

                                                destination[attribute] = source[sourceAttribute]
                                            }
                                        }
                                        destination["memo"] = "MigrationSample"
                                    }
                                )
                        ]
                    )
                ]
            ),
            completion: { [weak self] (result) -> Void in

                guard case .success = result else {

                    debugPrint("Migrate FAIL!!")

                    return
                }
                debugPrint("Migrate SUCCESS!")

                self?.fetchNewVersion()
     }

*/
    //}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

