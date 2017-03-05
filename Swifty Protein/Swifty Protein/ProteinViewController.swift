//
//  ProteinViewController.swift
//  Swifty Protein
//
//  Copyright © 2017 chtison. All rights reserved.
//

import UIKit
import Alamofire
import SceneKit

class ProteinViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!

    lazy var ligandId: String? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(sceneView.scene!.rootNode.childNodes.count)
        guard let ligandId = ligandId else {
            return
        }
        navigationItem.title = ligandId
        func handleError(message: String) {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { [unowned self] (alert) in
                self.navigationController!.popViewController(animated: true)
                
            })
            OperationQueue.main.addOperation { [unowned self] in
                self.present(alertController, animated: true)
            }
        }
        let url = "https://files.rcsb.org/ligands/view/\(ligandId)_model.pdb"
        Alamofire.request(url).response { (response: DefaultDataResponse) in
            if response.response != nil && response.response!.statusCode != 200 {
                handleError(message: "HTTP status code: \(response.response!.statusCode)")
                return
            }
            guard let data = response.data else {
                handleError(message: "GET \(url) returned no data.")
                return
            }
            guard let pdbStr = String(data: data, encoding: .utf8) else {
                handleError(message: "GET \(url) returned data not in UTF8")
                return
            }
            let pdb = pdbStr.components(separatedBy: "\n").map { $0.components(separatedBy: " ").filter { !$0.isEmpty } }
            let materials = [
                "H":  UIColor(white: 0.95, alpha: 1),
                "D":  UIColor(red:1.00, green:1.00, blue:0.75, alpha:1.0),
                "T":  UIColor(red:1.00, green:1.00, blue:0.63, alpha:1.0),
                "He": UIColor(red:0.85, green:1.00, blue:1.00, alpha:1.0),
                "Li": UIColor(red:0.80, green:0.50, blue:1.00, alpha:1.0),
                "Be": UIColor(red:0.76, green:1.00, blue:0.00, alpha:1.0),
                "B":  UIColor(red:1.00, green:0.71, blue:0.71, alpha:1.0),
                "C":  UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.0),
                "N":  UIColor(red:0.19, green:0.31, blue:0.97, alpha:1.0),
                "O":  UIColor(red:1.00, green:0.05, blue:0.05, alpha:1.0),
                "F":  UIColor(red:0.56, green:0.88, blue:0.31, alpha:1.0),
                "Ne": UIColor(red:0.70, green:0.89, blue:0.96, alpha:1.0),
                "Na": UIColor(red:0.67, green:0.36, blue:0.95, alpha:1.0),
                "Mg": UIColor(red:0.54, green:1.00, blue:0.00, alpha:1.0),
                "Al": UIColor(red:0.75, green:0.65, blue:0.65, alpha:1.0),
                "Si": UIColor(red:0.94, green:0.78, blue:0.63, alpha:1.0),
                "P":  UIColor(red:1.00, green:0.50, blue:0.00, alpha:1.0),
                "S":  UIColor(red:1.00, green:1.00, blue:0.19, alpha:1.0),
                "Cl": UIColor(red:0.12, green:0.94, blue:0.12, alpha:1.0),
                "Ar": UIColor(red:0.50, green:0.82, blue:0.89, alpha:1.0),
                "K":  UIColor(red:0.56, green:0.25, blue:0.83, alpha:1.0),
                "Ca": UIColor(red:0.24, green:1.00, blue:0.00, alpha:1.0),
                "Sc": UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0),
            ]
            var nodes: [String: SCNNode] = [:]
            var links: [String: [String: SCNNode]] = [:]
            let normalizedVectorStartingPosition = GLKVector3Make(0, 1, 0)
            for line in pdb {
                if line.isEmpty {
                    continue
                }
                if line[0] == "ATOM" {
                    print(line[1])
                    if line.count < 12 {
                        handleError(message: "GET \(url) returned malformed pdb formatted data.")
                        return
                    }
                    let sphere = SCNSphere(radius: 0.4)
                    if let color = materials[line[11]] {
                        sphere.firstMaterial!.diffuse.contents = color
                    }
                    let node = SCNNode(geometry: sphere)
                    guard let x = Double(line[6]), let y = Double(line[7]), let z = Double(line[8]) else {
                        handleError(message: "GET \(url) returned malformed pdb formatted data.")
                        return
                    }
                    node.position = SCNVector3(x, y, z)
                    nodes[line[1]] = node
                } else if line[0] == "CONECT" {
                    if line.count < 3 {
                        handleError(message: "GET \(url) returned malformed pdb formatted data.")
                        return
                    }
                    guard let startNode = nodes[line[1]] else {
                        continue
                    }
                    if links[line[1]] == nil {
                        links[line[1]] = [:]
                    }
                    let start = startNode.position
                    let magicStartVector = GLKVector3Make(start.x/2, start.y/2, start.z/2)
                    for id in line[2..<line.endIndex] {
                        if links[id]?[line[1]] != nil || links[line[1]]![id] != nil {
                            continue
                        }
                        guard let end = nodes[id]?.position else {
                            continue
                        }
                        let height = abs(sqrt(pow(start.x-end.x, 2)+pow(start.y-end.y, 2)+pow(start.z-end.z, 2)))
                        let cylinder = SCNNode(geometry: SCNCylinder(radius: 0.1, height: CGFloat(height)))
                        cylinder.position = SCNVector3((start.x + end.x) / 2, (start.y + end.y) / 2, (start.z + end.z) / 2)
                        cylinder.geometry!.firstMaterial!.diffuse.contents = UIColor.lightGray
                        let magicAxis = GLKVector3Normalize(GLKVector3Subtract(magicStartVector, GLKVector3Make(end.x/2, end.y/2, end.z/2)))
                        let rotationAxis = GLKVector3CrossProduct(normalizedVectorStartingPosition, magicAxis)
                        let rotationAngle = GLKVector3DotProduct(normalizedVectorStartingPosition, magicAxis)
                        let rotation = GLKVector4MakeWithVector3(rotationAxis, acos(rotationAngle))
                        cylinder.rotation = SCNVector4FromGLKVector4(rotation)
                        links[line[1]]![id] = cylinder
                    }
                }
            }
            var mid = SCNVector3()
            for (_, node) in nodes {
                mid.x = (mid.x + node.position.x) / 2
                mid.y = (mid.y + node.position.y) / 2
                mid.z = (mid.z + node.position.z) / 2
            }
            let camera = SCNNode()
            camera.camera = SCNCamera()
            camera.position = SCNVector3(mid.x, mid.y, mid.z + 50)
            OperationQueue.main.addOperation { [unowned self] in
                self.sceneView.scene!.rootNode.addChildNode(camera)
                for (_, node) in nodes {
                    self.sceneView.scene!.rootNode.addChildNode(node)
                }
                for (_, v1) in links {
                    for (_, v2) in v1 {
                        self.sceneView.scene!.rootNode.addChildNode(v2)
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        dismiss(animated: true, completion: nil)
    }
}
