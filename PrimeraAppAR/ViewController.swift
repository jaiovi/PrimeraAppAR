//
//  ViewController.swift
//  PrimeraAppAR
//
//  Created by Sebastián Jaiovi on 26/12/22.
//

import UIKit
import RealityKit
import ARKit

//basado en el tutorial de https://www.youtube.com/watch?v=8l3J9lwaecY&t=393s
class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(handleTap(recognizer:))
        ))
    }
    
    //setup methods
    func setupARView(){
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration) //ejecuta la config que ya definimos
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer){
        //hay que traducir la cordenada
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        //si consiguio un plano horizontal?
        if let firstResult = results.first{
            let anchor = ARAnchor(name: "ContemporaryFan", transform: firstResult.worldTransform)
            //añades el anchor a tu sesion
            arView.session.add(anchor: anchor)
        }else{
            print("No hemos puesto el objeto todavia :(")
        }
    }
    
    //creamos func para insertar
    func placeObject(named entityName: String, for anchor : ARAnchor){
        //hay que hacer un throw si que si
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        //para hacerle drag and drop el objeto
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures(for: entity)
        //arView.installGestures((.translation, .rotation),for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
        
        //PLAYBACK DE LA ANIMACION https://developer.apple.com/forums/thread/655437
        //entity.playAnimation(entity.availableAnimations.first!)
        //https://developer.apple.com/forums/thread/119773
        // Playing availableAnimations on repeat
        entity.availableAnimations.forEach { entity.playAnimation($0.repeat()) }
    }
}

extension ViewController:ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            //empezamos a colocarlo
            if let anchorName = anchor.name, anchorName=="ContemporaryFan"{
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
