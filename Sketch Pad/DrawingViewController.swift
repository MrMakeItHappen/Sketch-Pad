import UIKit
import ChromaColorPicker

final class DrawingViewController: UIViewController, ChromaColorPickerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolsStackView: UIStackView!
    
    private var endPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    private var currentColor: CGColor = UIColor.black.cgColor
    private var brushSize: Float = 10.0
    private var colorPicker: ChromaColorPicker?
    private var blur = UIBlurEffect()
    private var blurView = UIVisualEffectView()
    
}

extension DrawingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colorPicker = ChromaColorPicker(frame: CGRect(x: view.frame.size.width / 2 - 125, y: view.frame.size.height / 2 - 150, width: 250, height: 250))
        
        self.blur = UIBlurEffect(style: .light)
        self.blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
        
        guard let picker = colorPicker else { return }
        picker.delegate = self
        picker.padding = 5
        picker.stroke = 3
        picker.supportsShadesOfGray = true
        view.addSubview(picker)
        colorPicker?.isHidden = true
        blurView.isHidden = true
    }
}

extension DrawingViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7) {
            self.toolsStackView.alpha = 0
        }
        guard let beginPoint = touches.first?.location(in: self.imageView) else { return }
        self.endPoint = beginPoint
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let movedToPoint = touches.first?.location(in: self.imageView) else { return }
        draw(from: endPoint, to: movedToPoint)
        endPoint = movedToPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7) {
            self.toolsStackView.alpha = 1
        }
        guard let endedPoint = touches.first?.location(in: self.imageView) else { return }
        draw(from: endPoint, to: endedPoint)
    }
}

extension DrawingViewController {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        self.currentColor = color.cgColor
        colorPicker.isHidden = true
        blurView.isHidden = true
    }
    
    private func draw(from originPoint: CGPoint, to endPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        self.imageView.draw(CGRect(x: 0, y: 0, width: self.imageView.frame.width, height: self.imageView.frame.height))
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.move(to: originPoint)
        context.addLine(to: endPoint)
        context.setLineWidth(CGFloat(brushSize))
        context.setLineCap(.round)
        context.setStrokeColor(currentColor)
        context.strokePath()
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

extension DrawingViewController {
    @IBAction func colorPickerSelected(_ sender: Any) {
        colorPicker?.adjustToColor(UIColor(cgColor: currentColor))
        colorPicker?.isHidden = false
        blurView.isHidden = false
    }
    
    @IBAction func sizePickerSelected(_ sender: Any) {
        let alertController = UIAlertController(title: "Brush Size?", message: "\n\n\n\n\n", preferredStyle: .alert)
        
        let sizeSlider = UISlider(frame: CGRect(x: 10.0, y: 50.0, width: 250.0, height: 80.0))
        sizeSlider.minimumValue = 1
        sizeSlider.maximumValue = 100
        sizeSlider.value = brushSize
        alertController.view.addSubview(sizeSlider)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (alert) in
            self.brushSize = sizeSlider.value
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    @IBAction func erasePickerSelected(_ sender: Any) {
        self.currentColor = UIColor.white.cgColor
    }
    
    @IBAction func deletedSelected(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveSelected(_ sender: Any) {
        let alertController = UIAlertController(title: "Choose a name", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Ex. My Masterpiece"
        }
        
        let saveAction = UIAlertAction(title: "Save Name", style: .default) { (action) in
            guard let name = alertController.textFields?.first?.text else { return }
            if name != "" {
                guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
                let savedPicture = Picture(context: context)
                savedPicture.name = name
                
                guard let image = self.imageView.image else { return }
                savedPicture.image = image.jpegData(compressionQuality: 1)
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                self.dismiss(animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
}
