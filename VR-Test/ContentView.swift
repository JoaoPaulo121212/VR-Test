import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}
struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {

        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.environment.background = .color(.black)
        
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let mesh = MeshResource.generateBox(size: 0.15)
        
        let cubo = ModelEntity(mesh: mesh, materials: [material])
        
        cubo.orientation = simd_quatf(angle: .pi / 4, axis: [1, 1, 0])
        
        let anchor = AnchorEntity(world: [0, 0, -0.5])
        anchor.addChild(cubo)
        
        arView.scene.anchors.append(anchor)
        
        let light = PointLight()
        light.light.intensity = 2000
        let lightAnchor = AnchorEntity(world: [0, 0.5, 0.5])
        lightAnchor.addChild(light)
        arView.scene.anchors.append(lightAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
