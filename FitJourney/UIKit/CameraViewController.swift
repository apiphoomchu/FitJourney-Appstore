import Foundation
import UIKit
import AVFoundation
import Vision
import SwiftUI

final class CameraViewController: UIViewController {
    private var cameraSession: AVCaptureSession?
     var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
     private let cameraQueue = DispatchQueue(label: "CameraOutput", qos: .userInteractive)

     override func viewDidLoad() {
         super.viewDidLoad()
         NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
     }

     override func loadView() {
         view = CameraView()
     }

     private var cameraView: CameraView { view as! CameraView }

     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         setupCameraSession()
     }

     override func viewWillDisappear(_ animated: Bool) {
         cameraSession?.stopRunning()
         super.viewWillDisappear(animated)
     }

     private func setupCameraSession() {
         do {
             if cameraSession == nil {
                 try prepareAVSession()
                 cameraView.previewLayer.session = cameraSession
                 cameraView.previewLayer.videoGravity = .resizeAspectFill
                 adjustPreviewLayerOrientation()
             }
             DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                 self?.cameraSession?.startRunning()
             }
         } catch {
             print(error.localizedDescription)
         }
     }

     @objc func orientationDidChange() {
         adjustPreviewLayerOrientation()
     }

     private func adjustPreviewLayerOrientation() {
         if let connection = cameraView.previewLayer.connection {
             let orientation = UIDevice.current.orientation
             guard connection.isVideoOrientationSupported else { return }
             connection.videoOrientation = self.videoOrientation(from: orientation)
             cameraView.previewLayer.frame = view.bounds
         }
     }

     private func videoOrientation(from deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
         switch deviceOrientation {
         case .portrait: return .portrait
         case .landscapeRight: return .landscapeLeft
         case .portraitUpsideDown: return .portraitUpsideDown
         case .landscapeLeft: return .landscapeRight
         default: return .portrait
         }
     }

    func prepareAVSession() throws {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        

        guard let videoDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                return
        }

        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice)
        else { return }
        
        guard session.canAddInput(deviceInput)
        else { return }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.setSampleBufferDelegate(delegate, queue: cameraQueue)
        } else { return }
        
        session.commitConfiguration()
        cameraSession = session
    }
}



