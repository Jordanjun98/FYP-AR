//
//  ViewController.swift
//  furnitureApp
//
//  Created by Jordan on 21/10/2019.
//  Copyright © 2019 Jordan. All rights reserved.
//

import UIKit
import ARKit
import FirebaseDatabase


class ViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate{

    @IBOutlet weak var planeDetected: UILabel!
    
    private var localTranslatePosition : CGPoint!
    
    
    let itemsArr : [String] = ["boxing","cup","table","vase"]
        
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var ItemCollectionView: UICollectionView!
    
    @IBOutlet weak var userNameField: UIView!
    
    //got some problem in image preview
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func reset(_ sender: UIButton) {
         self.restartSesssion()
    }
    
    func restartSesssion(){
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
    @IBAction func didTakeSnapshot(_ sender: UIButton) {

        //imageView.alpha = 1.0
        //imageView.isHidden = false
        UIView.animate(withDuration: 1.0, animations: {
           // self.imageView.alpha = 0.0
        }){ (finished) in
            //self.imageView.isHidden = true
            UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
        }

    }
    
    let configuration = ARWorldTrackingConfiguration()
    
    var selectedItem: String?
   
   override func viewDidLoad() {
       super.viewDidLoad()
    
//    let ref = Database.database().reference()
//    ref.child("soemid/name").setValue("jordan")
    
       self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
       self.configuration.planeDetection = .horizontal
       self.sceneView.session.run(configuration)
    
    
       self.ItemCollectionView.dataSource = self
       self.ItemCollectionView.delegate = self
       self.sceneView.delegate = self
       self.registerGestureRecognizer()
       // Do any additional setup after loading the view.
   }
    
    
    func registerGestureRecognizer(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(longPressed))
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    var previousLoc: CGPoint?
    var touchCount: Int?

    @objc func longPressed(recognizer :UIPanGestureRecognizer){
       
        
        let loc = recognizer.location(in: self.view)
        var delta = recognizer.translation(in: self.view)
        
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitResult = sceneView.hitTest(tapLocation, types: .existingPlane)
        if !hitResult.isEmpty{
//            guard let hitResult = hitResult.last else { return }
//            .position = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            print("tapped")
        }
        
        
        
//        guard let sceneView = recognizer.view as? ARSCNView else{
//            return
//        }
//        let touch = recognizer.location(in: sceneView)
//        let hitTestResults = self.sceneView.hitTest(touch, options: nil)
//        if let hitTest = hitTestResults.first{
//            if let parentNode = hitTest.node.parent{
//                if recognizer.state == .began{
//                    localTranslatePosition = touch
//                }else if recognizer.state == .changed{
//                    let deltaX = Float(touch.x - self.localTranslatePosition.x)/700
//                    let deltaY = Float(touch.y - self.localTranslatePosition.y)/700
//
//                    parentNode.localTranslate(by: SCNVector3(deltaX,0.0, deltaY))
//
//                    //parentNode.localTranslate(by: <#T##SCNVector3#>(100,0,100))
//                    self.localTranslatePosition = touch
//
//                }
//
//            }
//        }
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty{
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            print(sender.scale)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
        
    @objc func tapped(sender: UITapGestureRecognizer){
       
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty{
            //print("touched a horizontal surface")
            self.addItem(hitTestResult: hitTest.first!)
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult){
        if let selectedItem = self.selectedItem{
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x,thirdColumn.y ,thirdColumn.z)
            self.sceneView.scene.rootNode.addChildNode(node)
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return itemsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        cell.itemLabel.text = self.itemsArr[indexPath.row]
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemsArr[indexPath.row]
        cell?.backgroundColor = UIColor.green
        
    }
   
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
         cell?.backgroundColor = UIColor.orange
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetected.isHidden = true
            }
        }
    }
    
}
