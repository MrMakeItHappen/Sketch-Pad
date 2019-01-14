import UIKit

final class PictureListCollectionViewController: UICollectionViewController {
    private var pictures: [Picture] = []
}

extension PictureListCollectionViewController {
    override func viewWillAppear(_ animated: Bool) {
        self.getPictures()
    }
    
    private func getPictures() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        guard let pictures = try? context.fetch(Picture.fetchRequest()) as? [Picture] else { return }
        guard let pics = pictures else { return }
        self.pictures = pics
        self.collectionView.reloadData()
    }
}

extension PictureListCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pictures.count
    }
}

extension PictureListCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as? PictureCell {
            let picture = self.pictures[indexPath.row]
            cell.textLabel.text = picture.name
            
            if let imageData = picture.image{
                cell.imageView.image = UIImage(data: imageData)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "pictureDetail", sender: self.pictures[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PictureDetailViewController {
            if let picture = sender as? Picture {
                destination.picture = picture
            }
        }
        
    }
}

class PictureCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
}
