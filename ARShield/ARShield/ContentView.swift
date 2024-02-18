//
//  ContentView.swift
//  ARShield
//
//  Created by Ani Avetian on 2/12/24.
//

import SwiftUI
import RealityKit
import ARKit


struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}


struct ARViewContainer: UIViewRepresentable {
    
   func makeUIView(context: Context) -> ARView {
       
       let arView = ARView(frame: .zero)
      
      let bottomCube = createCube(color: UIColor.blue.withAlphaComponent(0.8))
      let bottomAnchor = AnchorEntity(world: [0.0, 0.0, 0])
       bottomAnchor.addChild(bottomCube)
       arView.scene.anchors.append(bottomAnchor)
   
      let topCube = createCube(color: UIColor.red.withAlphaComponent(1.0))
      let topAnchor = AnchorEntity(world: [0, 0.05, 0])
       topAnchor.addChild(topCube)
       arView.scene.anchors.append(topAnchor)

       return arView
  }

  // Create a cube model
  func createCube(color: UIColor) -> Entity {
      let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
      let material = SimpleMaterial(color: color, roughness: 0.15, isMetallic: true)
      let model = ModelEntity(mesh: mesh, materials: [material])
      return model
  }

    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
