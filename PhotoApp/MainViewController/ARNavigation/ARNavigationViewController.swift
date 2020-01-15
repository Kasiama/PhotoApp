//
//  ARNavigationViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 12/27/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import ARKit
import MapKit

class ARNavigationViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    var destination2D: CLLocationCoordinate2D?
    var route: MKRoute?
    
     var engine: ARKitCoreLocationEngine!
    
    var routeFinishNode: SCNNode? = nil {
        didSet {
            oldValue?.removeFromParentNode()
            if let node = routeFinishNode {
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }
    var routeFinishView: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let routeFinishView = routeFinishView {
                view.addSubview(routeFinishView)
                
            }
        }
    }

    var routeDistanceLabel: UILabel? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let label = routeDistanceLabel {
                view.addSubview(label)
            }
        }
    }

    var routeFinishHint: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let hintView = routeFinishHint {
                view.addSubview(hintView)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
            sceneView.delegate = self
               
               // Show statistics such as fps and timing information
               sceneView.showsStatistics = true
               
               // Create a new scene
               let scene = SCNScene()
               
               // Set the scene to the view
               sceneView.scene = scene
               sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
        
        
        engine = ARKitCoreLocationEngineClass(
            view: sceneView,
            locationManager: NativeLocationManager(),
            locationEstimatesHolder: AdvancedLocationEstimatesHolder()
        )
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           // Create a session configuration
           let configuration = ARWorldTrackingConfiguration()
           configuration.worldAlignment = .gravityAndHeading

           // Run the view's session
           sceneView.session.run(configuration)
       }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    @IBAction func backBtnTaped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
           guard let routeFinishNode = routeFinishNode else { return }
        let positionInWorld = routeFinishNode.worldPosition
    }
    
    func update(){
        if let route = self.route{
            let routePointsCount = route.polyline.pointCount
            let routePoints = route.polyline.points()
            var geoRoute: [CLLocationCoordinate2D] = []
            for pointIndex in 0..<routePointsCount {
                let point: MKMapPoint = routePoints[pointIndex]
                geoRoute.append(point.coordinate)
            }
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
