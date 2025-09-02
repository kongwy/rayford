//
//  ScanningViewController.swift
//  Rayford
//
//  Created by Weiyi Kong on 2/9/2025.
//

import UIKit
import AVFoundation

class ScanningViewController: UIViewController {
    @IBOutlet weak var allowCameraAccessView: UIView!
    weak var delegate: SaveAccountDelegate?
    private var session = AVCaptureSession()
    private let output = AVCaptureMetadataOutput()
    private var layer: AVCaptureVideoPreviewLayer?
    private var rotationCoordiantor: AVCaptureDevice.RotationCoordinator?

    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        output.setMetadataObjectsDelegate(nil, queue: nil)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            startScanning()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self.startScanning()
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayerFrameAndOrientation()
    }

    private func startScanning() {
        if let device = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: device) {
            allowCameraAccessView.isHidden = true
            navigationItem.prompt = "Point your camera at a QR code to scan it."
            session.addInput(input)
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
            layer = AVCaptureVideoPreviewLayer(session: session)
            layer!.videoGravity = .resizeAspectFill
            view.layer.addSublayer(layer!)
            rotationCoordiantor = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: layer)
            updateLayerFrameAndOrientation()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }

    private func updateLayerFrameAndOrientation() {
        guard let layer else { return }
        layer.frame = view.layer.bounds
        if let rotationCoordiantor { layer.connection?.videoRotationAngle = rotationCoordiantor.videoRotationAngleForHorizonLevelCapture }
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension ScanningViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection) {

        guard presentedViewController == nil, // Not presenting an error alert
              metadataObjects.count > 0,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let urlString = metadataObject.stringValue else { return }

        guard let url = URL(string: urlString),
              let account = Account(url: url) else { return }

        output.setMetadataObjectsDelegate(nil, queue: nil)
        delegate?.save(account)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

protocol SaveAccountDelegate: AnyObject {
    func save(_ account: Account)
}
