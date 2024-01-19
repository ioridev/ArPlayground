import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        
        // Setup tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        arView.session.run(ARWorldTrackingConfiguration())
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARSCNView else { return }
            let location = sender.location(in: arView)
            let hitTestResult = arView.hitTest(location, types: .featurePoint)
            if let firstResult = hitTestResult.first {
                // Create a new bounding box and add it to the scene
                let boxNode = createBoundingBox(at: firstResult.worldTransform)
                arView.scene.rootNode.addChildNode(boxNode)
            }
        }
        
        func createBoundingBox(at transform: matrix_float4x4) -> SCNNode {
            let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.simdPosition = transform.translation
            // Optionally, you might want to add some transparency or color to the box.
            boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
            return boxNode
        }
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Tap on the screen to place a box")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding()
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

@main
struct ARApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


extension matrix_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}
