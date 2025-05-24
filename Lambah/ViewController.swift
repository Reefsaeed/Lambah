//
//  ViewController.swift
//  Lambah
//
//  Created by Reef Saeed on 15/03/2025.
//


import UIKit
import AVFoundation
import Vision
import CoreML
import MapKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Outlets
    @IBOutlet private var cameraView: UIView!
    
    // MARK: - Properties
    private var statusLabel: UILabel!
    private var instructionLabel: UILabel! // New top instruction label
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated)
    private var detectionOverlay: CALayer!
    private var coreMLRequest: VNCoreMLRequest!
    private var coreMLModel: VNCoreMLModel!
    private var bufferSize: CGSize = .zero
    private var detailPopupView: UIView?
    private var detailLabel: UILabel?
    private var detailImageView: UIImageView?
    private var lastDetectedClass: String?
    
    // Detection properties
    private var detectionCooldownTimer: Timer?
    private var detectionLockoutActive = false
    private var lastDetectionTimestamp = Date.distantPast
    private var detectionConfidenceThreshold: Float = 0.65
    private var detectionCooldownPeriod: TimeInterval = 3.0
    
    // Detection frame properties
    private var detectionFrameRect: CGRect = .zero
    private var detectionFrameLayer: CALayer?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAVCapture()
        setupVision()
        setupLayers()
        setupStatusLabel()
        setupTopInstructionLabel() // New method for top instruction
        setupDetectionFrame()
        startCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayerGeometry()
        setupDetectionFrame()
    }

    // MARK: - New Top Instruction Label Setup
        private func setupTopInstructionLabel() {
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            backgroundView.layer.cornerRadius = 10
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            instructionLabel = UILabel()
            instructionLabel.text = "Move closer to the dashboard sign"
            instructionLabel.textColor = .white
            instructionLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            instructionLabel.textAlignment = .center
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            
            backgroundView.addSubview(instructionLabel)
            cameraView.addSubview(backgroundView)
            
            NSLayoutConstraint.activate([
                instructionLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
                instructionLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -12),
                instructionLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
                instructionLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
                
                backgroundView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
                backgroundView.topAnchor.constraint(equalTo: cameraView.safeAreaLayoutGuide.topAnchor, constant: 20)
            ])
        }
    
    // MARK: - Setup Methods
    private func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        let videoDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back).devices.first
        
        guard let device = videoDevice else {
            print("Could not find video device")
            return
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        }
        
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
    }
    
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
                    self?.drawDetectionResults(results)
                }
            }
            coreMLRequest.imageCropAndScaleOption = .scaleFill
        } catch {
            print("Failed to load Vision ML model: \(error)")
        }
    }
    
    private func setupLayers() {
        detectionOverlay = CALayer()
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0, y: 0, width: bufferSize.width, height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: cameraView.bounds.midX, y: cameraView.bounds.midY)
        cameraView.layer.addSublayer(detectionOverlay)
    }
    
    private func setupStatusLabel() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundView.layer.cornerRadius = 10
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel = UILabel()
        statusLabel.text = "Scanning for symbols..."
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(statusLabel)
        cameraView.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
            statusLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -12),
            statusLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            backgroundView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupDetectionFrame() {
        detectionFrameLayer?.removeFromSuperlayer()
        
        let detectionFrameWidth = cameraView.bounds.width * 0.8
        let detectionFrameHeight = detectionFrameWidth
        let detectionFrameX = (cameraView.bounds.width - detectionFrameWidth) / 2
        let detectionFrameY = (cameraView.bounds.height - detectionFrameHeight) / 2
        
        detectionFrameRect = CGRect(x: detectionFrameX, y: detectionFrameY,
                                  width: detectionFrameWidth, height: detectionFrameHeight)
        
        let overlayLayer = CALayer()
        overlayLayer.frame = cameraView.bounds
        
        let path = UIBezierPath(rect: cameraView.bounds)
        let clearPath = UIBezierPath(roundedRect: detectionFrameRect, cornerRadius: 20)
        path.append(clearPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = clearPath.cgPath
        borderLayer.strokeColor = UIColor.systemYellow.cgColor
        borderLayer.lineWidth = 4
        borderLayer.fillColor = UIColor.clear.cgColor
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1.0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        borderLayer.add(pulseAnimation, forKey: "pulse")
        
        overlayLayer.addSublayer(fillLayer)
        overlayLayer.addSublayer(borderLayer)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Position sign within frame"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        instructionLabel.sizeToFit()
        instructionLabel.center = CGPoint(x: cameraView.bounds.midX, y: detectionFrameRect.maxY + 30)
        
        overlayLayer.addSublayer(instructionLabel.layer)
        cameraView.layer.addSublayer(overlayLayer)
        detectionFrameLayer = overlayLayer
    }
    
    private func updateLayerGeometry() {
        let bounds = cameraView.bounds
        previewLayer.frame = bounds
        detectionOverlay.frame = bounds
    }
    
    private func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    private func stopCaptureSession() {
        session.stopRunning()
    }

    // MARK: - Detection Methods
       private func drawDetectionResults(_ results: [VNRecognizedObjectObservation]) {
           detectionOverlay.sublayers = nil
           
           let highConfidenceDetections = results.filter { $0.confidence > detectionConfidenceThreshold }
           let frameDetections = highConfidenceDetections.compactMap { observation -> VNRecognizedObjectObservation? in
               let viewRect = VNRectToViewRect(observation.boundingBox,
                                              viewWidth: cameraView.bounds.width,
                                              viewHeight: cameraView.bounds.height)
               return detectionFrameRect.contains(viewRect) ? observation : nil
           }
           
           if frameDetections.isEmpty {
               if Date().timeIntervalSince(lastDetectionTimestamp) > detectionCooldownPeriod {
                   statusLabel.text = "Scanning for symbols..."
                   // Don't auto-hide popup anymore
               }
           } else {
               statusLabel.text = "Symbol detected"
               lastDetectionTimestamp = Date()
               
               if let topDetection = frameDetections.max(by: { $0.confidence < $1.confidence }),
                  let topLabel = topDetection.labels.first {
                   
                   // Only show new popup if different symbol detected or no popup showing
                   if topLabel.identifier != lastDetectedClass || detailPopupView?.superview == nil {
                       lastDetectedClass = topLabel.identifier
                       showDetailPopup(for: topLabel.identifier, confidence: topLabel.confidence)
                   }
                   
                   // Remove the cooldown timer completely since we want persistent popup
                   detectionCooldownTimer?.invalidate()
                   detectionLockoutActive = true
               }
           }
           
           // Draw bounding boxes
           let viewWidth = cameraView.bounds.width
           let viewHeight = cameraView.bounds.height
           
           for observation in frameDetections {
               guard let topLabelObservation = observation.labels.first else { continue }
               
               let boundingBox = createBoundingBoxLayer(for: observation, viewWidth: viewWidth, viewHeight: viewHeight)
               let textLayer = createTextLayer(with: "\(topLabelObservation.identifier): \(Int(observation.confidence * 100))%",
                                             for: observation,
                                             viewWidth: viewWidth,
                                             viewHeight: viewHeight)
               
               detectionOverlay.addSublayer(boundingBox)
               detectionOverlay.addSublayer(textLayer)
           }
       }

    // MARK: - Popup Methods
    private func showDetailPopup(for signClass: String, confidence: Float) {
            detailPopupView?.removeFromSuperview()
        
        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 24
        popupView.clipsToBounds = true
        popupView.translatesAutoresizingMaskIntoConstraints = false
        
        // Ensure popup appears above everything
        popupView.layer.zPosition = 1
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOffset = CGSize(width: 0, height: 4)
        popupView.layer.shadowRadius = 8
        popupView.layer.shadowOpacity = 0.25
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = getIconForDetection(signClass: signClass)
        
        let confidenceLabel = UILabel()
        confidenceLabel.text = "Confidence: \(Int(confidence * 100))%"
        confidenceLabel.textColor = .gray
        confidenceLabel.font = UIFont.systemFont(ofSize: 16)
        confidenceLabel.textAlignment = .center
        confidenceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = getTitleFor(signClass: signClass)
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = getDescriptionFor(signClass: signClass)
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionLabel = UILabel()
        actionLabel.text = getActionFor(signClass: signClass)
        actionLabel.textColor = .black
        actionLabel.font = UIFont.systemFont(ofSize: 16)
        actionLabel.textAlignment = .center
        actionLabel.numberOfLines = 0
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let serviceButton = UIButton(type: .system)
        serviceButton.backgroundColor = UIColor(named: "yellow1") ?? UIColor(red: 0.93, green: 0.75, blue: 0.33, alpha: 1.0)
        serviceButton.setTitle("Find nearest service!", for: .normal)
        serviceButton.setTitleColor(.white, for: .normal)
        serviceButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        serviceButton.layer.cornerRadius = 18
        serviceButton.translatesAutoresizingMaskIntoConstraints = false
        serviceButton.addTarget(self, action: #selector(findNearestService), for: .touchUpInside)
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.setTitleColor(.systemBlue, for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(hideDetailPopup), for: .touchUpInside)
        
        popupView.addSubview(imageView)
        popupView.addSubview(confidenceLabel)
        popupView.addSubview(titleLabel)
        popupView.addSubview(descriptionLabel)
        popupView.addSubview(actionLabel)
        popupView.addSubview(serviceButton)
        popupView.addSubview(dismissButton)
        view.addSubview(popupView)
        
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            popupView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),
            
            imageView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            confidenceLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            confidenceLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            confidenceLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            confidenceLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: confidenceLabel.bottomAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            
            actionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            actionLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            actionLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            
            serviceButton.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: 20),
            serviceButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            serviceButton.widthAnchor.constraint(equalTo: popupView.widthAnchor, multiplier: 0.7),
            serviceButton.heightAnchor.constraint(equalToConstant: 55),
            
            dismissButton.topAnchor.constraint(equalTo: serviceButton.bottomAnchor, constant: 16),
            dismissButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -16)
        ])
        
        detailPopupView = popupView
        detailLabel = descriptionLabel
        detailImageView = imageView
        
        popupView.alpha = 0
                popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                
                UIView.animate(withDuration: 0.3) {
                    popupView.alpha = 1
                    popupView.transform = .identity
                }
            }
    
    @objc private func hideDetailPopup() {
            UIView.animate(withDuration: 0.3, animations: {
                self.detailPopupView?.alpha = 0
                self.detailPopupView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.detailPopupView?.removeFromSuperview()
                self.detailPopupView = nil
                self.lastDetectedClass = nil
                self.detectionLockoutActive = false
            }
        }

    // MARK: - Service Methods
    @objc private func findNearestService() {
        let searchQuery = "car service center"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "car+service"
        
        if let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedQuery)&directionsmode=driving") {
            if UIApplication.shared.canOpenURL(googleMapsURL) {
                UIApplication.shared.open(googleMapsURL, options: [:]) { success in
                    if !success {
                        self.openGoogleMapsWeb(query: encodedQuery)
                    }
                }
            } else {
                self.openGoogleMapsWeb(query: encodedQuery)
            }
        } else {
            self.fallbackToAppleMaps(query: searchQuery)
        }
    }
    
    private func openGoogleMapsWeb(query: String) {
        if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)") {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        } else {
            self.fallbackToAppleMaps(query: query)
        }
    }
    
    private func fallbackToAppleMaps(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = MKCoordinateRegion(.world)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, !response.mapItems.isEmpty else {
                MKMapItem.openMaps(with: [MKMapItem.forCurrentLocation()], launchOptions: nil)
                return
            }
            
            let firstItem = response.mapItems.first!
            let currentLocation = MKMapItem.forCurrentLocation()
            
            MKMapItem.openMaps(with: [currentLocation, firstItem],
                              launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }

    // MARK: - Helper Methods
    private func getIconForDetection(signClass: String) -> UIImage? {
        let formattedClassName = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        let iconMapping = [
            "brake": "brake_icon",
            "abs": "abs_icon",
            "airbag": "airbag_icon",
            "battery": "battery_icon",
            "door": "door_icon",
            "engine": "engine_icon",
            "fuel": "fuel_icon",
            "oil": "oil_icon",
            "seat": "seatbelt_icon",
            "steer": "steering_icon",
            "stabil": "stability_icon",
            "temp": "temperature_icon",
            "tire": "tire_icon",
            "check": "engine_icon"
        ]
        
        for (keyword, iconName) in iconMapping {
            if formattedClassName.contains(keyword) {
                return UIImage(named: iconName) ?? UIImage(systemName: "exclamationmark.triangle")
            }
        }
        return UIImage(systemName: "exclamationmark.triangle")
    }
    
    private func getTitleFor(signClass: String) -> String {
        let formattedClass = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        
        if formattedClass.contains("brake") {
            return "Brake System Issue"
        } else if formattedClass.contains("abs") || formattedClass.contains("anti") {
            return "Anti Lock Braking System"
        } else if formattedClass.contains("charg") || formattedClass.contains("battery") {
            return "Charging System Issue"
        } else if formattedClass.contains("check") || (formattedClass.contains("engine") && !formattedClass.contains("cool")) {
            return "Check Engine"
        } else if formattedClass.contains("door") {
            return "Door Open"
        } else if formattedClass.contains("steer") || formattedClass.contains("eps") {
            return "Electronic Power Steering"
        } else if formattedClass.contains("stab") || formattedClass.contains("esp") {
            return "Electronic Stability Problem"
        } else if formattedClass.contains("temp") || formattedClass.contains("cool") {
            return "High Engine Coolant Temperature"
        } else if formattedClass.contains("oil") {
            return "Low Engine Oil Warning"
        } else if formattedClass.contains("fuel") {
            return "Low Fuel"
        } else if formattedClass.contains("tire") || formattedClass.contains("tpms") {
            return "Low Tire Pressure Warning"
        } else if formattedClass.contains("master") {
            return "Master Warning"
        } else if formattedClass.contains("airbag") || formattedClass.contains("srs") {
            return "SRS-Airbag"
        } else if formattedClass.contains("seat") || formattedClass.contains("belt") {
            return "Seat Belt Warning"
        }
        return signClass.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private func getDescriptionFor(signClass: String) -> String {
        let formattedClass = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        
        if formattedClass.contains("brake") {
            return "Problem with the main braking system."
        } else if formattedClass.contains("abs") || formattedClass.contains("anti") {
            return "Issue with the Anti-Lock Braking System detected."
        } else if formattedClass.contains("charg") || formattedClass.contains("battery") {
            return "The battery is not charging properly while the engine is running."
        } else if formattedClass.contains("engine") || formattedClass.contains("check") {
            return "Engine or emission control system malfunction detected."
        } else if formattedClass.contains("door") {
            return "One or more doors are not completely closed."
        } else if formattedClass.contains("steer") || formattedClass.contains("eps") {
            return "Power steering system malfunction detected."
        } else if formattedClass.contains("stab") || formattedClass.contains("esp") {
            return "Issue with the vehicle stability control system."
        } else if formattedClass.contains("temp") || formattedClass.contains("cool") {
            return "The engine is overheating."
        } else if formattedClass.contains("oil") {
            return "Engine oil pressure is dangerously low."
        } else if formattedClass.contains("fuel") {
            return "Fuel level is critically low."
        } else if formattedClass.contains("tire") || formattedClass.contains("tpms") {
            return "One or more tires have pressure below the recommended level."
        } else if formattedClass.contains("master") || formattedClass.contains("general") {
            return "General vehicle system malfunction detected."
        } else if formattedClass.contains("airbag") || formattedClass.contains("srs") {
            return "Issue with the Supplemental Restraint System (airbags)."
        } else if formattedClass.contains("seat") || formattedClass.contains("belt") {
            return "Driver or passenger seat belt is not fastened."
        }
        return "Dashboard warning indicator requiring attention."
    }
    
    private func getActionFor(signClass: String) -> String {
        let formattedClass = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        
        if formattedClass.contains("brake") {
            return "Action: Check brake fluid level. Have your brake system inspected immediately. Driving with brake issues is dangerous."
        } else if formattedClass.contains("abs") || formattedClass.contains("anti") {
            return "Action: Have your ABS system checked by a professional as soon as possible. Your regular brakes should still work."
        } else if formattedClass.contains("charg") || formattedClass.contains("battery") {
            return "Action: Check the alternator, battery, and electrical connections. Your vehicle may stop running soon."
        } else if formattedClass.contains("engine") || formattedClass.contains("check") {
            return "Action: Have your vehicle diagnosed by a professional. Continue driving only if the light is steady (not flashing)."
        } else if formattedClass.contains("door") {
            return "Action: Stop the vehicle and ensure all doors, hood, and trunk are properly closed before driving."
        } else if formattedClass.contains("steer") || formattedClass.contains("eps") {
            return "Action: Have the power steering system checked by a professional. Steering may become more difficult."
        } else if formattedClass.contains("stab") || formattedClass.contains("esp") {
            return "Action: Have the stability control system checked. Drive cautiously, especially on slippery surfaces."
        } else if formattedClass.contains("temp") || formattedClass.contains("cool") {
            return "Action: Pull over safely, turn off the engine, and allow it to cool down. Check coolant levels when safe."
        } else if formattedClass.contains("oil") {
            return "Action: Stop driving immediately and check oil level. Continuing to drive may cause severe engine damage."
        } else if formattedClass.contains("fuel") {
            return "Action: Refuel your vehicle as soon as possible to avoid running out of fuel and damaging the fuel pump."
        } else if formattedClass.contains("tire") || formattedClass.contains("tpms") {
            return "Action: Check tire pressure in all tires and inflate to the recommended PSI as soon as possible."
        } else if formattedClass.contains("master") || formattedClass.contains("warn") {
            return "Action: Check your vehicle's information display for specific warnings and have your vehicle inspected."
        } else if formattedClass.contains("airbag") || formattedClass.contains("srs") {
            return "Action: Have the airbag system checked immediately by an authorized service center."
        } else if formattedClass.contains("seat") || formattedClass.contains("belt") {
            return "Action: Ensure all passengers fasten their seat belts before the vehicle is in motion."
        }
        return "Action: Consult your vehicle's manual or have a professional inspect your vehicle."
    }
    
    private func createBoundingBoxLayer(for observation: VNRecognizedObjectObservation, viewWidth: CGFloat, viewHeight: CGFloat) -> CALayer {
        let boxRect = VNRectToViewRect(observation.boundingBox, viewWidth: viewWidth, viewHeight: viewHeight)
        let boxLayer = CALayer()
        boxLayer.frame = boxRect
        boxLayer.borderColor = CGColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.8)
        boxLayer.borderWidth = 3
        boxLayer.backgroundColor = CGColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.3)
        boxLayer.cornerRadius = 4
        return boxLayer
    }
    
    private func createTextLayer(with text: String, for observation: VNRecognizedObjectObservation, viewWidth: CGFloat, viewHeight: CGFloat) -> CATextLayer {
        let textSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        let rect = VNRectToViewRect(observation.boundingBox, viewWidth: viewWidth, viewHeight: viewHeight)
        let textBounds = CGRect(
            x: rect.minX,
            y: rect.minY - textSize.height - 8,
            width: max(textSize.width + 24, rect.width),
            height: textSize.height + 8
        )
        
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.font = UIFont.boldSystemFont(ofSize: 14)
        textLayer.fontSize = 14
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
        textLayer.cornerRadius = 4
        textLayer.alignmentMode = .center
        textLayer.frame = textBounds
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
    private func VNRectToViewRect(_ vnRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> CGRect {
        return CGRect(
            x: vnRect.minX * viewWidth,
            y: (1 - vnRect.maxY) * viewHeight,
            width: vnRect.width * viewWidth,
            height: vnRect.height * viewHeight
        )
    }
    
    // MARK: - AVCapture Delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageWidth = CVPixelBufferGetWidth(pixelBuffer)
        let imageHeight = CVPixelBufferGetHeight(pixelBuffer)
        
        if bufferSize.width != CGFloat(imageWidth) || bufferSize.height != CGFloat(imageHeight) {
            bufferSize = CGSize(width: CGFloat(imageWidth), height: CGFloat(imageHeight))
            DispatchQueue.main.async { [weak self] in
                self?.updateLayerGeometry()
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        do {
            try imageRequestHandler.perform([coreMLRequest])
        } catch {
            print("Failed to perform detection: \(error)")
        }
    }
}

extension CGRect {
    func contains(_ other: CGRect) -> Bool {
        return self.intersection(other) == other
    }
}
