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

            robotEntity.scale = SIMD3<Float>(0.05, 0.05, 0.05)
            
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
    
    func createRoom() -> AnchorEntity {
            let roomAnchor = AnchorEntity(world: [0, 0, 0])
            
            // Dimensões da sala
            let width: Float = 6.0
            let depth: Float = 6.0
            let height: Float = 4.0
            let floorLevel: Float = -1.0
            
            // --- 1. Material do CHÃO ---
            var floorMaterial = SimpleMaterial()
            if let floorTexture = try? TextureResource.load(named: "chaoMadeira.avif") {
                floorMaterial.color = .init(texture: .init(floorTexture))
                floorMaterial.roughness = .float(0.4)
                floorMaterial.metallic = .float(0.0)
            } else { floorMaterial.color = .init(tint: .brown) }

            // --- 2. Material das Paredes COMUNS (Liso) ---
            var genericWallMaterial = SimpleMaterial()
            if let wallTexture = try? TextureResource.load(named: "paredeConcreto.jpeg") {
                genericWallMaterial.color = .init(texture: .init(wallTexture))
                genericWallMaterial.roughness = .float(0.9)
                genericWallMaterial.metallic = .float(0.0)
            } else { genericWallMaterial.color = .init(tint: .gray) }
            

            var frontWallMaterial = SimpleMaterial()
            if let doorTexture = try? TextureResource.load(named: "paredePorta.jpeg") {
                frontWallMaterial.color = .init(texture: .init(doorTexture))
                frontWallMaterial.roughness = .float(0.6)
                frontWallMaterial.metallic = .float(0.1)
            } else {

                frontWallMaterial.color = .init(tint: .red)
            }
        
            let wallMesh = MeshResource.generatePlane(width: width, depth: height)
            let sideWallMesh = MeshResource.generatePlane(width: height, depth: depth)
            
            // 1. Chão
            let floorMesh = MeshResource.generatePlane(width: width, depth: depth)
            let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
            floorEntity.position = [0, floorLevel, 0]
            roomAnchor.addChild(floorEntity)
            
            // 2. Teto
            let ceilingMesh = MeshResource.generatePlane(width: width, depth: depth)
            var ceilingMat = SimpleMaterial(color: .black, isMetallic: false)
            let ceiling = ModelEntity(mesh: ceilingMesh, materials: [ceilingMat])
            ceiling.position = [0, floorLevel + height, 0]
            ceiling.orientation = simd_quatf(angle: .pi, axis: [1, 0, 0])
            roomAnchor.addChild(ceiling)
            
            // A) Parede da FRENTE (Única que usa o material da porta)
            let frontWall = ModelEntity(mesh: wallMesh, materials: [frontWallMaterial])
            frontWall.position = [0, floorLevel + (height/2), -depth/2]
            frontWall.orientation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
            roomAnchor.addChild(frontWall)
            
            // B) Outras Paredes (Usam o material genérico no loop)
            let otherWallsData: [(MeshResource, SIMD3<Float>, SIMD3<Float>, Float)] = [
                (wallMesh, [0, floorLevel + (height/2), depth/2], [1, 0, 0], -.pi/2),   // Trás
                (sideWallMesh, [-width/2, floorLevel + (height/2), 0], [0, 0, 1], -.pi/2), // Esquerda
                (sideWallMesh, [width/2, floorLevel + (height/2), 0], [0, 0, 1], .pi/2)   // Direita
            ]
            
            for (mesh, pos, axis, angle) in otherWallsData {
                let wall = ModelEntity(mesh: mesh, materials: [genericWallMaterial])
                wall.position = pos
                wall.orientation = simd_quatf(angle: angle, axis: axis)
                roomAnchor.addChild(wall)
            }
            
            return roomAnchor
        }
}

