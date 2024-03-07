//
//  ContentView.swift
//  ARShield
//
//  Created by Ani Avetian on 2/12/24.
//  Using Image Recognition this application will allow a user to detect clickjacking
//  attacks in ARKit and RealityKit
//

import SwiftUI
import RealityKit
import ARKit
import Vision
import CoreML


// Main Rendered View for App
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
   
   // Create UI View for AR objects
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
   
   // Update AR view - no functionality needed
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
   @State private var count = 0
   
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
       do {
          let imageRecognitionModel = try ClickjackingImageClassifier_V5()
          if let pixelBuffer = pixelBuffer(from: image) {
             do {
                // Detect object
                let recognitionResult = try imageRecognitionModel.prediction(image: pixelBuffer)
                
                // DEBUGGING PRINT STATEMENTS - Accuracy
                print(String(count) + " " + recognitionResult.target)
                print(recognitionResult.targetProbability)
                print("---------------------------------------------------------")
                count += 1
                
                // Update detected status based on image recon result
                if recognitionResult.target == "Clickjacking" {
                   viewModel.updateDetectionStatus(newStatus: "Detected")
                } else {
                   viewModel.updateDetectionStatus(newStatus: "Not Detected")
                }
             } catch {
                print("ERROR: NOT ABLE TO DETECT")
             }
            }
       } catch {
          print("ERROR: DID NOT LOAD MODEL")
       }
        
       
    }
   
   // Adapted from https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer
   // Converts UIImage to CVPixelBuffer needed for ML model
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

// Present View to User
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
