//
//  File.swift
//  
//
//  Created by Apiphoom Chuenchompoo on 24/2/2567 BE.
//

import AVFoundation

class CameraManager {
    static func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completion(true)
            
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            
            default:
                completion(false)
        }
    }
}
