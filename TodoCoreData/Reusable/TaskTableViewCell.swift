//
//  TaskTableViewCell.swift
//  TodoCoreData
//
//  Created by Swayam Rustagi on 05/08/24.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var taskDate: UILabel!
    
    @IBOutlet weak var imageViewLogo: UIImageView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
           imageViewLogo.contentMode = .scaleAspectFill
           imageViewLogo.clipsToBounds = true
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
           // Configure the view for the selected state
       }
       
       func configure(with task: TaskItem) {
           taskName.text = task.name
           
           if let date = task.createdAt {
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "dd/MM/yyyy"
               taskDate.text = dateFormatter.string(from: date)
           } else {
               taskDate.text = "Unknown date"
           }
           
           if let imageName = task.taskImage {
               let fileManager = FileManager.default
               let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
               let fileURL = documentDirectory.appendingPathComponent(imageName)
               
               if let imageData = try? Data(contentsOf: fileURL) {
                   imageViewLogo.image = UIImage(data: imageData)
               } else {
                   imageViewLogo.image = UIImage(systemName: "photo") // Fallback image
               }
           } else {
               imageViewLogo.image = UIImage(systemName: "photo") // Fallback image
           }
       }
   }
