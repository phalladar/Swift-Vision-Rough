import UIKit
import CoreML
import Vision
import ImageIO

class VisionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func takePicture(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker, animated: true)
    }
    @IBAction func chooseImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true)
    }

    var inputImage: CIImage!

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        guard let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else { fatalError("no image from image picker") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("can't create CIImage from UIImage") }
        let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)
        inputImage = ciImage.applyingOrientation(Int32(orientation.rawValue))

        imageView.image = uiImage

        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: Int32(orientation.rawValue))
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                self.textRequest.reportCharacterBoxes = true
                try handler.perform([self.textRequest])
            } catch {
                print(error)
            }
        }
    }
    
    lazy var textRequest: VNDetectTextRectanglesRequest = {
            return VNDetectTextRectanglesRequest(completionHandler: self.handleTextClassification)
    }()
    
    func handleTextClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNDetectedObjectObservation]
            else { fatalError("couldn't find text") }
        
        for textObservation in observations {
            // Bounding box around text
            print(textObservation.boundingBox)
            let realObs = textObservation as? VNTextObservation
            // Bounding boxes around characters
            let characterBoxes = realObs?.characterBoxes
//            print(characterBoxes)
        }
    }
    
}

