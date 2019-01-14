import UIKit

final class PictureDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var picture: Picture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = picture?.name
        
        if let imageData = picture?.image {
            self.imageView.image = UIImage(data: imageData)
        }
    }
    
    @IBAction func deleteSelected(_ sender: Any) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let pictureToBeDeleted = picture {
                context.delete(pictureToBeDeleted)
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func shareSelected(_ sender: Any) {
        guard let image = imageView.image else { return }
        let shareViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareViewController, animated: true)
    }
    
}
