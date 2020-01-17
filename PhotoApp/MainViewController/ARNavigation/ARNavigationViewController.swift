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


protocol ARNavigationViewControllerDelegate: AnyObject {
   func update()
}

class ARNavigationViewController: UIViewController, ARSCNViewDelegate, ARNavigationViewControllerDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    var destination2D: CLLocationCoordinate2D?
    var route: MKRoute?
    
     var engine: ARKitCoreLocationEngine!
    
    private var userLocationAnnotation: MKPointAnnotation = MKPointAnnotation()
    
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
        
        var a = AdvancedLocationEstimatesHolder()
        a.delegate = self
        
        engine = ARKitCoreLocationEngineClass(
            view: self.sceneView,
            locationManager: NativeLocationManager(),
            locationEstimatesHolder: a
        )
       
        //self.update()
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           // Create a session configuration
           let configuration = ARWorldTrackingConfiguration()
           configuration.worldAlignment = .gravityAndHeading

           // Run the view's session
           sceneView.session.run(configuration)
        self.update()
       }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    @IBAction func backBtnTaped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
            
            let routee = geoRoute
                .map { engine.convert(coordinate: $0) }
                .compactMap { $0 }
                .map { CGPoint(position: $0) }
            
            guard routee.count == geoRoute.count else {
                     return
                 }
            guard let routeFinishPoint = routee.last else { return }
            routeFinishNode = SCNNode()
            routeFinishNode?.position = routeFinishPoint.positionIn3D
            
            routeFinishHint = makeFinishNodeHint()
            routeFinishView = makeFinishNodeView()
            routeDistanceLabel = makeDistanceLabel()
            
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let routeFinishNode = routeFinishNode else { return }
        guard let parent = routeFinishNode.parent else { return }
        guard let pointOfView = renderer.pointOfView else { return }
        
        let bounds = UIScreen.main.bounds

        let positionInWorld = routeFinishNode.worldPosition
        let positionInPOV = parent.convertPosition(routeFinishNode.position, to: pointOfView)
        let projection = sceneView.projectPoint(positionInWorld)
        let projectionPoint = CGPoint(x: CGFloat(projection.x), y: CGFloat(projection.y))
        
        let annotationPositionInRFN = SCNVector3Make(0.0, 1.0, 0.0) // in Route finish node coord. system
               let annotationPositionInWorld = routeFinishNode.convertPosition(annotationPositionInRFN, to: nil)
               let annotationProjection = sceneView.projectPoint(annotationPositionInWorld)
               let annotationProjectionPoint = CGPoint(x: CGFloat(annotationProjection.x), y: CGFloat(annotationProjection.y))
               let rotationAngle = Vector2.y.angle(with: (Vector2(annotationProjectionPoint) - Vector2(projectionPoint)))

               let screenMidToProjectionLine = CGLine(point1: bounds.mid, point2: projectionPoint)
               let intersection = screenMidToProjectionLine.intersection(withRect: bounds)

               let povWorldPosition: Vector3 = Vector3(pointOfView.worldPosition)
               let routeFinishWorldPosition: Vector3 = Vector3(positionInWorld)
               let distanceToFinishNode = (povWorldPosition - routeFinishWorldPosition).length
        
        DispatchQueue.main.async { [weak self] in
            guard let slf = self else { return }
            guard let routeFinishHint = slf.routeFinishHint else { return }
            guard let routeFinishView = slf.routeFinishView else { return }
            guard let routeDistanceLabel = slf.routeDistanceLabel else { return }
            let placemarkSize = ARNavigationViewController.finishPlacemarkSize(
                forDistance: CGFloat(distanceToFinishNode),
                closeDistance: 10.0,
                farDistance: 25.0,
                closeDistanceSize: 100.0,
                farDistanceSize: 50.0
            )

            let distance = floor(distanceToFinishNode)

            let point: CGPoint = intersection ?? projectionPoint
            let isInFront = positionInPOV.z < 0
            let isProjectionInScreenBounds: Bool = intersection == nil

           
            if isInFront {
                routeFinishHint.center = point
            } else {
                if isProjectionInScreenBounds {
                    routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: bounds.height
                    )
                } else {
                    routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: reflect(point.y, of: bounds.mid.y)
                    )
                }
            }

            routeFinishView.center = projectionPoint
            routeFinishView.bounds.size = CGSize(width: placemarkSize, height: placemarkSize)
            routeFinishView.layer.cornerRadius = placemarkSize / 2

            let distanceString = "\(distance) м"
            let distanceAttrStr = ARNavigationViewController.distanceText(forString: distanceString)
            routeDistanceLabel.attributedText = distanceAttrStr
            routeDistanceLabel.center = projectionPoint
            let size = distanceAttrStr.boundingSize(width: .greatestFiniteMagnitude)
            routeDistanceLabel.bounds.size = size
            routeDistanceLabel.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle - .pi))
        }
       }
    @IBAction func updateTapped(_ sender: Any) {
        self.update()
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

// Extention to make label etc
extension ARNavigationViewController {

    static func distanceText(forString string: String) -> NSAttributedString {
        return NSMutableAttributedString(string: string, attributes: [
            .strokeColor : UIColor.black,
            .foregroundColor : UIColor.white,
            .strokeWidth : -1.0,
            .font : UIFont.boldSystemFont(ofSize: 32.0)
            ])
    }

    func makeFinishNodeView() -> UIView {
        let nodeView = UIView()
        nodeView.backgroundColor = UIColor.green
        return nodeView
    }

    func makeFinishNodeHint() -> UIView {
        let hintView = UIView()
        hintView.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        hintView.layer.cornerRadius = 25.0
        hintView.backgroundColor = UIColor.red
        return hintView
    }

    func makeDistanceLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32.0, weight: .bold)
        label.numberOfLines = 1
        label.layer.shadowRadius = 2.0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize.zero
        return label
    }

    /// RouteFinishPlacemark size driven by design requirements
    ///
    /// - Parameters:
    ///   - distance: distance to route finish
    static func finishPlacemarkSize(forDistance distance: CGFloat, closeDistance: CGFloat, farDistance: CGFloat,
                             closeDistanceSize: CGFloat, farDistanceSize: CGFloat) -> CGFloat
    {
        guard closeDistance >= 0 else { assert(false); return 0.0 }
        guard closeDistance >= 0, farDistance >= 0, closeDistance <= farDistance else { assert(false); return 0.0 }

        if distance > farDistance {
            return farDistanceSize
        } else if distance < closeDistance{
            return closeDistanceSize
        } else {
            let delta = farDistanceSize - closeDistanceSize
            let percent: CGFloat = ((distance - closeDistance) / (farDistance - closeDistance))
            let size = closeDistanceSize + delta * percent
            return size
        }
    }

    func findProjection(ofNode node: SCNNode, inSceneOfView scnView: SCNView) -> CGPoint {
        let nodeWorldPosition = node.worldPosition
        let projection = scnView.projectPoint(nodeWorldPosition)
        return CGPoint(x: CGFloat(projection.x), y: CGFloat(projection.y))
    }

    func isNodeInFrontOfCamera(_ node: SCNNode, scnView: SCNView) -> Bool {
        guard let pointOfView = scnView.pointOfView else { return false }
        guard let parent = node.parent else { return false }
        let positionInPOV = parent.convertPosition(node.position, to: pointOfView)
        return positionInPOV.z < 0
    }
}
extension ARNavigationViewController: LocationManagerListener {

    func onLocationUpdate(_ location: CLLocation) {
        updateUserLocationAnnotation(withCoordinate: location.coordinate)

    }

    func onAuthorizationStatusUpdate(_ authorizationStatus: CLAuthorizationStatus) {
    }

    func updateUserLocationAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
        userLocationAnnotation.coordinate = coordinate
    }

}
