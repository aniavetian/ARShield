//
//  ContentView.swift
//  ARShieldObject
//
//  Created by Ani Avetian on 2/29/24.
//
// This application loads the 3D objects and allows you to move them
// This can be used to create more testing scenarios for clickjacking vs non clickjacking
// There is no other functionality

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}


struct ARViewContainer: UIViewRepresentable {
   
   
   func makeUIView(context: Context) -> ARView {
      
      // Create AR View
      let arView = ARView(frame: .zero)
      
      
      // Create bottom cube and add to AR env
      let bottomCube = createCube(color: UIColor.blue.withAlphaComponent(0.9))
      arView.installGestures([.translation, .rotation, .scale], for: bottomCube as! HasCollision)
      let bottomAnchor = AnchorEntity(world: [0.0, 0.0, 0])
      bottomAnchor.addChild(bottomCube)
      arView.scene.anchors.append(bottomAnchor)
      
      // Create top cube and add to AR env
      let topCube = createCube(color: UIColor.red.withAlphaComponent(0.9))
      arView.installGestures([.translation, .rotation, .scale], for: topCube as! HasCollision)
      let topAnchor = AnchorEntity(world: [0, 0.0, 0])
      topAnchor.addChild(topCube)
      arView.scene.anchors.append(topAnchor)
      
      print("INFO: RETURNED VIEW")
      
      
      return arView
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
   
   
   func updateUIView(_ uiView: ARView, context: Context) {}
}

#Preview {
    ContentView()
}
