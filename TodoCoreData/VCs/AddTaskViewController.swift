//
//  AddTaskViewController.swift
//  TodoCoreData
//
//  Created by Swayam Rustagi on 05/08/24.
//

import UIKit

class AddTaskViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
                
        imageView.image = UIImage(systemName: "questionmark.circle") // Use a SF Symbol or your placeholder image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
                
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectPhotoTapped))
        imageView.addGestureRecognizer(tapGesture)
    }
    @objc func selectPhotoTapped() {
            let alert = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
            guard let taskName = taskTextField.text, !taskName.isEmpty,
                  let imageData = imageView.image?.jpegData(compressionQuality: 0.8) else {
                print("task was left empty")
                return
            }

            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return
            }
            
            let newTask = TaskItem(context: context)
            newTask.name = taskName
            newTask.createdAt = Date()
            newTask.taskImage = fileName
            
            do {
                try context.save()
//                dismiss(animated: true, completion: nil)
            } catch {
                print("Error saving task: \(error.localizedDescription)")
            }
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let selectedImage = info[.originalImage] as? UIImage {
               imageView.image = selectedImage
           }
           picker.dismiss(animated: true, completion: nil)
       }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }

}
