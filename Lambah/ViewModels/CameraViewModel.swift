//
//  CameraViewModel.swift
//  Lambah
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var statusText = "Scanning for symbols..."
    @Published var instructionText = "Move closer to the dashboard sign"
    @Published var isDetecting = false
    @Published var detectedSymbol: DetectedSymbol?
    @Published var shouldShowPopup = false
    
    // MARK: - Detection Properties
    private var coreMLRequest: VNCoreMLRequest!
    private var coreMLModel: VNCoreMLModel!
    private var detectionCooldownTimer: Timer?
    private var detectionLockoutActive = false
    private var lastDetectionTimestamp = Date.distantPast
    private var lastDetectedClass: String?
    
    // MARK: - Configuration
    private let detectionConfidenceThreshold: Float = 0.65
    private let detectionCooldownPeriod: TimeInterval = 3.0
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupVision()
    }
    
    // MARK: - Setup Methods
    private func setupVision() {
        guard let modelURL = Bundle.main.url(forResource: "best", withExtension: "mlmodelc") ??
                            Bundle.main.url(forResource: "best", withExtension: "mlmodel") else {
            print("Could not find model file")
            return
        }
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            coreMLModel = try VNCoreMLModel(for: mlModel)
            coreMLRequest = VNCoreMLRequest(model: coreMLModel) { [weak self] request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation], error == nil else {
                    print("Vision request error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                DispatchQueue.main.async {
                    self?.processDetectionResults(results)
                }
            }
            coreMLRequest.imageCropAndScaleOption = .scaleFill
        } catch {
            print("Failed to load Vision ML model: \(error)")
        }
    }
    
    // MARK: - Detection Processing
    func processDetectionResults(_ results: [VNRecognizedObjectObservation]) {
        let highConfidenceDetections = results.filter { $0.confidence > detectionConfidenceThreshold }
        
        if highConfidenceDetections.isEmpty {
            if Date().timeIntervalSince(lastDetectionTimestamp) > detectionCooldownPeriod {
                statusText = "Scanning for symbols..."
            }
        } else {
            statusText = "Symbol detected"
            lastDetectionTimestamp = Date()
            
            if let topDetection = highConfidenceDetections.max(by: { $0.confidence < $1.confidence }),
               let topLabel = topDetection.labels.first {
                
                if topLabel.identifier != lastDetectedClass || !shouldShowPopup {
                    lastDetectedClass = topLabel.identifier
                    detectedSymbol = DetectedSymbol(
                        className: topLabel.identifier,
                        confidence: topLabel.confidence
                    )
                    shouldShowPopup = true
                }
                
                detectionCooldownTimer?.invalidate()
                detectionLockoutActive = true
            }
        }
    }
    
    // MARK: - Vision Request
    func createVisionRequest() -> VNCoreMLRequest {
        return coreMLRequest
    }
    
    // MARK: - Popup Management
    func hidePopup() {
        shouldShowPopup = false
        lastDetectedClass = nil
        detectionLockoutActive = false
        detectedSymbol = nil
    }
    
    // MARK: - Detection Frame Checking
    func isDetectionInFrame(_ observation: VNRecognizedObjectObservation,
                           detectionFrame: CGRect,
                           viewWidth: CGFloat,
                           viewHeight: CGFloat) -> Bool {
        let viewRect = VNRectToViewRect(observation.boundingBox,
                                       viewWidth: viewWidth,
                                       viewHeight: viewHeight)
        return detectionFrame.contains(viewRect)
    }
    
    // MARK: - Coordinate Conversion
    private func VNRectToViewRect(_ vnRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> CGRect {
        return CGRect(
            x: vnRect.minX * viewWidth,
            y: (1 - vnRect.maxY) * viewHeight,
            width: vnRect.width * viewWidth,
            height: vnRect.height * viewHeight
        )
    }
}
