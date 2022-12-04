//
//  ListCell.swift
//  toDoList
//
//  Created by lera on 01.12.2022.
//

import UIKit

class ListCell: UITableViewCell {
    
    private var task: Task?
    @IBAction func doneCheckbox(_ sender: Any) {
        checkboxBool.toggle()
        task?.done = checkboxBool
        CoreDataService.shared.saveContext()
        setImage()
    }
    
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var noteText: UITextField!
    @IBOutlet weak var taskTitle: UILabel!
    
    @IBAction func noteTextField(_ sender: Any) {
        task?.note = noteText.text
        CoreDataService.shared.saveContext()
    }
    
    @IBOutlet private weak var creationDate: UILabel!
    
    var checkboxBool: Bool = false
    
    func config(from task: Task){
        self.task = task
        self.checkboxBool = task.done
        self.taskTitle.text = task.title
        self.noteText.text = task.note
        self.creationDate.text = task.dateOfCreation?.formatted()
        self.noteText.text = task.note
        setImage()
    }
    
    private func setImage(){
        let image = checkboxBool ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "squareshape")
        checkbox.setImage(image, for: .normal)
    }
}
