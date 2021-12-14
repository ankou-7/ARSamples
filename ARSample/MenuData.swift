//
//  MenuData.swift
//  ARSample
//
//  Created by 安江洸希 on 2021/04/26.
//

import UIKit

struct MenuItem {
    let title: String
    let description: String
    let prefix: String
    
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: prefix, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        vc.title = title

        return vc
    }
}

class MenuViewModel {
    private let dataSource = [
        MenuItem (
            title: "飛行機",
            description: "飛行機の表示",
            prefix: "Ship"
        ),
        MenuItem (
            title: "Hittest",
            description: "タップした場所にオブジェクトを配置",
            prefix: "Hittest"
        ),
        MenuItem (
            title: "ARWorldMap",
            description: "ARWorldMapの保存と復元",
            prefix: "ARWorldMap"
        ),
        MenuItem (
            title: "CoreML",
            description: "リアルタイムでのオブジェクト検出",
            prefix: "CoreML"
        ),
    ]
    
    var count: Int {
        dataSource.count
    }
    
    func item(row: Int) -> MenuItem {
        dataSource[row]
    }
    
    func viewController(row: Int) -> UIViewController {
        dataSource[row].viewController()
    }
}
