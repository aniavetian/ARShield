////
////  ContentView.swift
////  ARShield
////
////  Created by Ani Avetian on 2/12/24.
////  WORKING VERSION
////  This version loads the objects needed in AR and Reality Kit
//// This Version breaks my phone
//
//import SwiftUI
//import RealityKit
//import ARKit
//import Vision
//import CoreML
//
//
//
//
//struct ContentView : View {
//    var body: some View {
//       VStack {
//          ARViewContainer()
//          DetectionResultView()
//       }.edgesIgnoringSafeArea(.all)
//    }
//}
//
//
//struct ARViewContainer: UIViewRepresentable {
//   
//   
//   func makeUIView(context: Context) -> ARView {
//      
//      // Create AR View
//      let arView = ARView(frame: .zero)
//      
//      // Create AR config
//      let configuration = ARWorldTrackingConfiguration()
//      arView.session.run(configuration)
//      
//      // Create bottom cube and add to AR env
//      let bottomCube = createCube(color: UIColor.blue.withAlphaComponent(0.8))
//      arView.installGestures([.translation, .rotation, .scale], for: bottomCube as! HasCollision)
//      let bottomAnchor = AnchorEntity(world: [0.0, 0.0, 0])
//      bottomAnchor.addChild(bottomCube)
//      arView.scene.anchors.append(bottomAnchor)
//      
//      // Create top cube and add to AR env
//      let topCube = createCube(color: UIColor.red.withAlphaComponent(1.0))
//      arView.installGestures([.translation, .rotation, .scale], for: topCube as! HasCollision)
//      let topAnchor = AnchorEntity(world: [0, 0.0, 0])
//      topAnchor.addChild(topCube)
//      arView.scene.anchors.append(topAnchor)
//      
//      print("INFO: RETURNED VIEW")
//      
//      // Load Model
//      guard let model = try? VNCoreMLModel(for: ClickjackingImageClassifier_2().model) else {
//          fatalError("Failed to load Core ML model.")
//      }
//      
//      print("INFO: LOADED MODEL")
//      
//      // Perform object detection on every frame
//      //.session.delegate = context.coordinator
//      
//      
//      return arView
//   }
//   
//   // Create a cube model
//   func createCube(color: UIColor) -> Entity {
//      let boxSize = SIMD3<Float>(0.1, 0.05, 0.05) // Width, Height, Depth
//      let mesh = MeshResource.generateBox(size: boxSize, cornerRadius: 0.005)
//      let material = SimpleMaterial(color: color, roughness: 0.15, isMetallic: true)
//      let model = ModelEntity(mesh: mesh, materials: [material])
//      model.generateCollisionShapes(recursive: true)
//      return model
//   }
//   
//   
//   func updateUIView(_ uiView: ARView, context: Context) {}
//   
//   func makeCoordinator() -> Coordinator {
//       return Coordinator()
//   }
//   
//   class Coordinator: NSObject, ARSessionDelegate {
//           func session(_ session: ARSession, didUpdate frame: ARFrame) {
//               guard let model = try? VNCoreMLModel(for: ClickjackingImageClassifier_2().model) else {
//                   fatalError("Failed to load Core ML model.")
//               }
//               
//               let request = VNCoreMLRequest(model: model) { request, error in
//                   guard let results = request.results as? [VNRecognizedObjectObservation] else {
//                       return
//                   }
//                   
//                   for result in results {
//                       if result.labels.first?.identifier == "Clickjacking" {
//                           DispatchQueue.main.async {
//                               DetectedObjectState.shared.updateDetectedObject(true)
//                           }
//                           return
//                       }
//                   }
//                   
//                   DispatchQueue.main.async {
//                       DetectedObjectState.shared.updateDetectedObject(false)
//                   }
//               }
//               
//               let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
//               try? handler.perform([request])
//           }
//      }
//}
//
//struct DetectionResultView: View {
//    var body: some View {
//        Text("Detection: \(DetectedObjectState.shared.detected ? "Detected" : "Not Detected")")
//            .foregroundColor(DetectedObjectState.shared.detected ? .green : .red)
//            .padding()
//            .background(Color.white.opacity(0.5))
//            .cornerRadius(10)
//            .padding()
//    }
//}
//
//class DetectedObjectState: ObservableObject {
//    static let shared = DetectedObjectState()
//    
//    @Published var detected: Bool = false
//    
//    func updateDetectedObject(_ detected: Bool) {
//        self.detected = detected
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}



 // Image Detection Version


//
//  ContentView.swift
//  ARShield
//
//  Created by Ani Avetian on 2/12/24.
//  WORKING VERSION - Using Image Recon
//

import SwiftUI
import RealityKit
import ARKit
import Vision
import CoreML



struct ContentView : View {
    var body: some View {
       VStack {
          ARViewContainer()
          HStack {
             DetectionResultView()
             CapturePhotoButton()
          }
       }.edgesIgnoringSafeArea(.all)
    }
}


struct ARViewContainer: UIViewRepresentable {
   
   
   func makeUIView(context: Context) -> ARView {
      
      // Create AR View
      let arView = ARView(frame: .zero)
      
      // Create AR config
      let configuration = ARWorldTrackingConfiguration()
      arView.session.run(configuration)
      
      // Create bottom cube and add to AR env
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
   
   // Update AR view
   func updateUIView(_ uiView: ARView, context: Context) {}
}
   
// Detection Status model to allow updates to current state of detection
class DetectionStatusViewModel: ObservableObject {
    static let shared = DetectionStatusViewModel()
    
    @Published var detectionStatus: String = "Not Detected"
    
    func updateDetectionStatus(newStatus: String) {
        detectionStatus = newStatus
    }
}

// View of the Detection Status on the application.
struct DetectionResultView: View {
    @ObservedObject var viewModel = DetectionStatusViewModel.shared
    
    var body: some View {
        Text("Detection: \(viewModel.detectionStatus)")
            .foregroundColor(viewModel.detectionStatus == "Detected" ? .green : .red)
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(10)
            .padding()
    }
}

struct CapturePhotoButton: View {
   
   // Button to capture photo of AR objects loaded in
    var body: some View {
        Button(action: {
            self.capturePhoto()
        }) {
            Text("Take Photo")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
   // Functionality to capture a photo of the AR objects
    func capturePhoto() {
       let viewModel = DetectionStatusViewModel.shared
       
        let window = UIApplication.shared.windows.first!
        
        UIGraphicsBeginImageContextWithOptions(window.frame.size, false, UIScreen.main.scale)
        window.drawHierarchy(in: window.frame, afterScreenUpdates: true)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            print("ERROR: FAILED TO CAPTURE IMAGE")
            return
        }
        
        UIGraphicsEndImageContext()
        
        // Pass the captured image to your image recognition model for detection
        let imageRecognitionModel = ClickjackingImageClassifier_2()
       if let pixelBuffer = pixelBuffer(from: image) {
          do {
             // Detect object
             let recognitionResult = try imageRecognitionModel.prediction(image: pixelBuffer)
             print(recognitionResult.target)
             
             // Update detected status based on image recon result
             if recognitionResult.target == "Clickjacking" {
                viewModel.updateDetectionStatus(newStatus: "Detected")
                print("here")
             } else {
                viewModel.updateDetectionStatus(newStatus: "Not Detected")
                print("here2")
             }
          } catch {
             print("ERROR: NOT ABLE TO DETECT")
          }
         }
       
    }
   
   // Adapted from https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer
   func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
       let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
       var pixelBuffer: CVPixelBuffer?
       let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs as CFDictionary, &pixelBuffer)
       guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
           return nil
       }
       CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
       let pixelData = CVPixelBufferGetBaseAddress(buffer)
       let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
       guard let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
           return nil
       }
       context.translateBy(x: 0, y: image.size.height)
       context.scaleBy(x: 1.0, y: -1.0)
       UIGraphicsPushContext(context)
       image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
       UIGraphicsPopContext()
       CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
       return buffer
   }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
