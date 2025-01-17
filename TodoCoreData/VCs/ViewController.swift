//
//  ViewController.swift
//  TodoCoreData
//
//  Created by Swayam Rustagi on 05/08/24.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var searchTaskField: UITextField!
    
    
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       private var tasks = [TaskItem]()
       private var filteredTasks = [TaskItem]()

       override func viewDidLoad() {
           super.viewDidLoad()
           taskTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskTableViewCell")
           taskTableView.delegate = self
           taskTableView.dataSource = self
           searchTaskField.delegate = self
           getAllTasks()
           
           let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
           taskTableView.addGestureRecognizer(longPressGesture)
       }

       @IBAction func addButtonPressed(_ sender: Any) {
           self.addButtonTapped()
       }

       @objc func addButtonTapped() {
           let vc = AddTaskViewController()
           self.present(vc , animated: true)
       }

       func getAllTasks() {
           do {
               tasks = try context.fetch(TaskItem.fetchRequest())
               filteredTasks = tasks
               DispatchQueue.main.async {
                   self.taskTableView.reloadData()
               }
           } catch {
               print("Error fetching tasks: \(error.localizedDescription)")
           }
       }

       func createTask(name: String, imageName: String?) {
           let newTask = TaskItem(context: context)
           newTask.name = name
           newTask.createdAt = Date()
           newTask.taskImage = imageName
           
           do {
               try context.save()
               getAllTasks()
           } catch {
               print("Error creating task: \(error.localizedDescription)")
           }
       }

       func deleteTask(task: TaskItem) {
           if let imageName = task.taskImage {
                  let fileManager = FileManager.default
                  let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                  let fileURL = documentDirectory.appendingPathComponent(imageName)
                  
                  do {
                      if fileManager.fileExists(atPath: fileURL.path) {
                          try fileManager.removeItem(at: fileURL)
                      }
                  } catch {
                      print("Error deleting file: \(error.localizedDescription)")
                  }
              }
            
           context.delete(task)

           do {
               try context.save()
               getAllTasks()
           } catch {
               print("Error deleting task: \(error.localizedDescription)")
           }
       }

       func editTask(task: TaskItem, newTaskName: String) {
           task.name = newTaskName

           do {
               try context.save()
               getAllTasks()
           } catch {
               print("Error editing task: \(error.localizedDescription)")
           }
       }
       
       @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
           if gesture.state == .began {
               let point = gesture.location(in: taskTableView)
               if let indexPath = taskTableView.indexPathForRow(at: point) {
                   let task = filteredTasks[indexPath.row]
                   let alert = UIAlertController(title: "Edit Task", message: "Edit Task Name", preferredStyle: .alert)
                   alert.addTextField { (textField) in
                       textField.text = task.name
                   }
                   alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                   alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                       guard let field = alert.textFields?.first, let newText = field.text, !newText.isEmpty else {
                           return
                       }
                       self?.editTask(task: task, newTaskName: newText)
                   }))
                   present(alert, animated: true, completion: nil)
               }
           }
       }
   }

   extension ViewController: UITableViewDelegate {
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               let taskToDelete = filteredTasks[indexPath.row]
               deleteTask(task: taskToDelete)
           }
       }
   }

   extension ViewController: UITableViewDataSource {
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return filteredTasks.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as! TaskTableViewCell
           let task = filteredTasks[indexPath.row]
           cell.configure(with: task)
           return cell
       }
   }

   extension ViewController: UITextFieldDelegate {
       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
           filterTasks(searchText: searchText)
           return true
       }
       
       func filterTasks(searchText: String) {
           if searchText.isEmpty {
               filteredTasks = tasks
           } else {
               filteredTasks = tasks.filter { $0.name?.lowercased().contains(searchText.lowercased()) ?? false }
           }
           taskTableView.reloadData()
       }
   }
