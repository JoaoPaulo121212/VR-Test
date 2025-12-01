//
//  VR_TestApp.swift
//  VR-Test
//
//  Created by Jota Pe on 28/11/25.
//

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
        
        let roomAnchor = createRoom()
        arView.scene.anchors.append(roomAnchor)
        
        let robotAnchor = AnchorEntity(world: [0,-1,-2] )
        do {
            let robotEntity = try Entity.load(named: "robot")

            robotEntity.scale = SIMD3<Float>(0.01, 0.01, 0.01)
            
            for anim in robotEntity.availableAnimations {
                robotEntity.playAnimation(anim.repeat())//Animação dele repetida infinitamente
            }
            
            robotAnchor.addChild(robotEntity)
            
        } catch {
            print("Erro ao carregar o modelo robo.usdz: \(error)")
            let mesh = MeshResource.generateSphere(radius: 0.2)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            robotAnchor.addChild(ModelEntity(mesh: mesh, materials: [material]))
        }
        
        arView.scene.anchors.append(robotAnchor)
        
        let light = PointLight()
        light.light.intensity = 5000 // intensidade da luz
        light.light.attenuationRadius = 10 // a luz alcança 10 metros
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func createRoom() -> AnchorEntity{
        let roomAnchor  = AnchorEntity(world: [0,0,0])
        
        let floorMaterial = SimpleMaterial(color: .darkGray, isMetallic: false)
        let wallMaterial = SimpleMaterial(color: .gray, isMetallic: false)
        let ceilingMaterial = SimpleMaterial(color: .lightGray, isMetallic: false)
        
        //Dimensões em metros
        let width: Float = 6
        let height: Float = 4
        let depth : Float = 6
        let floorLevel : Float = -1
        let ceilingLevel : Float = floorLevel + height
        
        //chão
        let floorMesh = MeshResource.generatePlane(width: width, depth: depth)
        let floor = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        floor.position = [0, floorLevel, 0]
        roomAnchor.addChild(floor)
        
        //teto
        let ceilingMesh = MeshResource.generatePlane(width: width, depth: depth)
        let ceiling = ModelEntity(mesh: ceilingMesh, materials: [ceilingMaterial])
        ceiling.position = [0, ceilingLevel, 0]
        ceiling.orientation = simd_quatf(angle: .pi, axis: [1, 0, 0])
        roomAnchor.addChild(ceiling)
        
        //parede da frente
        let wallMesh = MeshResource.generatePlane(width: width, depth: height)
        let frontWall = ModelEntity(mesh: wallMesh, materials: [wallMaterial])
        frontWall.position = [0, floorLevel + (height/2), -depth/2]
        // Rotação: Levanta a parede (90 graus em X)
        frontWall.orientation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
        roomAnchor.addChild(frontWall)
        
        //parede de tras
        let backWall = ModelEntity(mesh: wallMesh, materials: [wallMaterial])
        backWall.position = [0, floorLevel + (height/2), depth/2]
        // Rotação: Levanta e vira para dentro (-90 graus em X)
        backWall.orientation = simd_quatf(angle: -.pi/2, axis: [1, 0, 0])
        roomAnchor.addChild(backWall)
        
        //parede esquerda
        let sideWallMesh = MeshResource.generatePlane(width: height, depth: depth)
        let leftWall = ModelEntity(mesh: sideWallMesh, materials: [wallMaterial])
        leftWall.position = [-width/2, floorLevel + (height/2), 0]
        // Rotação: Vira de lado (-90 graus em Z)
        leftWall.orientation = simd_quatf(angle: -.pi/2, axis: [0, 0, 1])
        roomAnchor.addChild(leftWall)
        
        //parede direita
        let rightWall = ModelEntity(mesh: sideWallMesh, materials: [wallMaterial])
        rightWall.position = [width/2, floorLevel + (height/2), 0]
        // Rotação: Vira de lado (90 graus em Z)
        rightWall.orientation = simd_quatf(angle: .pi/2, axis: [0, 0, 1])
        roomAnchor.addChild(rightWall)
        return roomAnchor
    }
}

