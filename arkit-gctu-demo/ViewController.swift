//
//  ViewController.swift
//  arkit-gctu-demo
//
//  Created by Douglas Gandle on 6/13/18.
//  Copyright © 2018 Douglas Gandle. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Uncomment to show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        // Uncomment to show feature points
//        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create an empty scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    // MARK: - Plane Detection
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Unwrap the anchor as an ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Get the dimensions of the plane anchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        
        // Create a new SCNPlane with those dimensions
        let plane = SCNPlane(width: width, height: height)
        
        // Give the plane a transparent blue color
        plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.4)
        
        // Create a new SCNNode from the plane
        let planeNode = SCNNode(geometry: plane)
        
        // Set the position of the plane node to the anchor
        let x = planeAnchor.center.x
        let y = planeAnchor.center.y
        let z = planeAnchor.center.z
        planeNode.position = SCNVector3Make(x, y, z)
        
        // Rotate the plane node so it lies flat
        planeNode.eulerAngles.x = -.pi / 2
        
        // Add the plane node to scene
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // Unwrap the anchor, node, and node geometry
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Update the plane's dimensions with the new dimensions from
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // Re-position the plane at the anchor
        let x = planeAnchor.center.x
        let y = planeAnchor.center.y
        let z = planeAnchor.center.z
        planeNode.position = SCNVector3Make(x, y, z)
    }
    
    
    // MARK: - Hit Detection
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Unwrap the touch location
        guard let touchLocation = touches.first?.location(in: sceneView) else { return }
        
        // Perform a hit test on the scene view at the touch location
        let hitTestResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        guard let result = hitTestResults.first else { return }
        
        // Create a transformation to turn the coordinates of the touch location into a position in our scene
        let transformation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        
        // Create a SCNNode from our custom 3D model
        guard let ballparkScene = SCNScene(named: "art.scnassets/Ballpark.dae") else { return }
        let ballparkNode = ballparkScene.rootNode
        
        // Set the node's position to the hit test transformation
        ballparkNode.position = transformation
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(ballparkNode)
        
    }
    
}
