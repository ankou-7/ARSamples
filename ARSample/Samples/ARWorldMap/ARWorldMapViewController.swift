//
//  ARWorldMapViewController.swift
//  ARSample
//
//  Created by yasue kouki on 2021/04/30.
//

import UIKit
import SceneKit
import ARKit

class ARWorldMapViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let scene = SCNScene()

    var ObjectAnchor: ARAnchor?
    let ObjectAnchorName = "ObjectAnchor"
    
    @IBOutlet weak var save_button: UIButton!
    @IBOutlet weak var load_button: UIButton!
    
    var mapSaveURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL")
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        sceneView.automaticallyUpdatesLighting = true
        
        load_button.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //水平面，垂直面の検出
        configuration.planeDetection = [.horizontal, .vertical]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //アンカー追加時
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //追加されたアンカーがObjectAnchor以外はreturn
        guard anchor.name == ObjectAnchorName else { return }
        
        //保存したWorldMapを読み込んだ際にObjectAnchorがnilなためAnchorを格納
        if ObjectAnchor == nil {
            ObjectAnchor = anchor
        }
        
        let object_node = make_object()
        node.addChildNode(object_node)
    }
    
    //タップした位置にアンカー追加
    @IBAction func Button_tapped(_ sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)

        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            //すでにアンカーがあれば削除
            if let existingAnchor = ObjectAnchor {
                sceneView.session.remove(anchor: existingAnchor)
            }
            ObjectAnchor = ARAnchor(name: ObjectAnchorName, transform: hitTest.first!.worldTransform)
            sceneView.session.add(anchor: ObjectAnchor!)
        }
    }
    
    func make_object() -> SCNNode {
        let url = Bundle.main.url(forResource: "art.scnassets/toy_biplane", withExtension: "usdz")!
        let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
        let node = scene.rootNode.childNode(withName: "toy_biplane", recursively: false)!
        node.scale = SCNVector3(0.005, 0.005, 0.005)
        return node
    }
    
    @IBAction func save_worldmap(_ sender: UIButton) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else { return }
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try data.write(to: self.mapSaveURL, options: [.atomic])
                DispatchQueue.main.async {
                    self.save_button.isHidden = true
                    self.load_button.isHidden = false
                }
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func load_worldmap(_ sender: UIButton) {
        guard let data = try? Data(contentsOf: mapSaveURL)
        else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
        do {
            guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
            else { fatalError("No ARWorldMap in archive.") }
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
        } catch {
            fatalError("Can't unarchive ARWorldMap from file data: \(error)")
        }
        
        save_button.isHidden = false
        load_button.isHidden = true
        ObjectAnchor = nil
    }
    
    @IBAction func reset(_ sender: UIButton) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        ObjectAnchor = nil
    }
    
}
