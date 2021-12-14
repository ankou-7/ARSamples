//
//  HittestViewController.swift
//  ARSample
//
//  Created by yasue kouki on 2021/04/29.
//

import UIKit
import ARKit

class HittestViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    let scene = SCNScene()

    var select_object: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //水平面，垂直面の検出
        configuration.planeDetection = [.horizontal]//, .vertical]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        // タップされた位置を取得する
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)

        // タップされた位置のARアンカーを探す
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            // タップした箇所が取得できていればitemを追加
            self.addObject(hitTestResult: hitTest.first!)
        }
    }

    //配置メソッド
    func addObject(hitTestResult: ARHitTestResult) {
        if let object_name = select_object {

            // アセットより、シーンを作成
            guard let url = Bundle.main.url(forResource: "art.scnassets/\(object_name)", withExtension: "usdz") else { return }
            let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
            
            // ノード作成
            let node = scene.rootNode.childNode(withName: object_name, recursively: false)!

            // 現実世界の座標を取得
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3

            // アイテムの配置
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            node.scale = SCNVector3(0.005, 0.005, 0.005)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }


    @IBAction func tap_toy_drummer(_ sender: UIButton) {
        select_object = "toy_drummer"
    }

    @IBAction func toy_robot_vintage(_ sender: Any) {
        select_object = "toy_robot_vintage"
    }
}
