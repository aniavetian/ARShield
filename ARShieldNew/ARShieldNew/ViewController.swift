//
//  ViewController.swift
//  ARShieldNew
//
//  Created by Ani Avetian on 2/23/24.
//

import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController, ARSCNViewDelegate {

   
   @IBOutlet var arView: ARView!
      
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.

      
      // Create ARSCNView
     arView = ARView(frame: view.bounds)
     
     // Create a new AR session configuration
     let configuration = ARWorldTrackingConfiguration()
     
     // Run the AR session with the configuration
     arView.session.run(configuration)
      
      let bottomCube = createCube(color: UIColor.blue.withAlphaComponent(0.8))
      arView.installGestures([.translation, .rotation, .scale], for: bottomCube as! HasCollision)
      let bottomAnchor = AnchorEntity(world: [0.0, 0.0, 0])
      bottomAnchor.addChild(bottomCube)
      arView.scene.anchors.append(bottomAnchor)
      
      // Create top cube and add to AR env
      let topCube = createCube(color: UIColor.red.withAlphaComponent(1.0))
      arView.installGestures([.translation, .rotation, .scale], for: topCube as! HasCollision)
      let topAnchor = AnchorEntity(world: [0, 0.0, 0])
      topAnchor.addChild(topCube)
      arView.scene.anchors.append(topAnchor)
      
      view.addSubview(arView)
      

   }
   
   
      // Create a cube model
      func createCube(color: UIColor) -> Entity {
         let boxSize = SIMD3<Float>(0.1, 0.05, 0.05) // Width, Height, Depth
         let mesh = MeshResource.generateBox(size: boxSize, cornerRadius: 0.005)
         let material = SimpleMaterial(color: color, roughness: 0.15, isMetallic: true)
         let model = ModelEntity(mesh: mesh, materials: [material])
         model.generateCollisionShapes(recursive: true)
         return model
      }


}

