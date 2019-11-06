import UIKit
import ARKit

class ViewController: UIViewController {
    
    let trackingView = ARSCNView()
    let mouthPositionLabel = UILabel()
    let counterLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("ARKit is not supported on this device")
        }
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                DispatchQueue.main.sync {
                    self.setupMouthTracker()
                }
            } else {
                fatalError("This app needs Camera Access to function. You can grant access in Settings.")
            }
        }
    }
    
    func setupMouthTracker() {
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        trackingView.session.run(configuration)
        trackingView.delegate = self
        
        view.addSubview(trackingView)
        
        buildMouthLabel()
        buildCounterLabel()
    }
    
    func buildMouthLabel() {
        mouthPositionLabel.text = "😐"
        mouthPositionLabel.font = UIFont.systemFont(ofSize: 180)
        
        view.addSubview(mouthPositionLabel)
        
        mouthPositionLabel.translatesAutoresizingMaskIntoConstraints = false
        mouthPositionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mouthPositionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func buildCounterLabel() {
        counterLabel.text = "0"
        
        view.addSubview(counterLabel)
        
//        counterLabel.translatesAutoresizingMaskIntoConstraints = false;
//        counterLabel.centerXAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        counterLabel.centerYAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        
        counterLabel.frame.origin.y = 0
        counterLabel.frame.origin.x = self.view.frame.width - counterLabel.frame.width
    }
    
    func handleMouth(mouthValue: CGFloat) {
        var counter = 0
//        if let counterText = counterLabel.text {
//            let counterInt:Int? = Int(counterText)
//            if let counterNum = counterInt {
//                counter += 1
//            }
//        }
        switch mouthValue {
        case _ where mouthValue > 0.3:
            mouthPositionLabel.text = "😮"
            if let counterText = counterLabel.text {
                let counterInt:Int? = Int(counterText)
                if let counterNum = counterInt {
                    counter = counterNum+1
                }
                else {
                    counter+=1
                }
            }
            counterLabel.text = "\(counter)"
        default:
            mouthPositionLabel.text = "😐"
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Pull left/right smile coefficents from blendShapes
        //        let leftMouthSmileValue = faceAnchor.blendShapes[.jawOpen] as! CGFloat
        //        let rightMouthSmileValue = faceAnchor.blendShapes[.jawOpen] as! CGFloat
        
        let jawOpenValue = faceAnchor.blendShapes[.jawOpen] as! CGFloat
        
        
        //        let jawOpen = ARFaceAnchor.BlendShapeLocation  as! CGFloat
        
        DispatchQueue.main.async {
            // Update label for new smile value
            //            self.handleMouth(mouthValue: (leftMouthSmileValue + rightMouthSmileValue)/2.0)
            self.handleMouth(mouthValue: jawOpenValue)
            
        }
    }
    
}
