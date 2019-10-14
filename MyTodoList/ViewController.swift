//
//  ViewController.swift
//  MyTodoList
//
//  Created by 今枝弘樹 on 2019/05/16.
//  Copyright © 2019 Hiroki Imaeda. All rights reserved.
//

import UIKit

//UITableViewDataSource,UITableViewDelegateのプロトコルを実装する宣言
class ViewController: UIViewController {
    
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        storedTodoList()
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        let alertController = UIAlertController(title: "ToDo追加", message: "ToDoを入力してください", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: nil)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default){
            (action: UIAlertAction) in
            if let textField = alertController.textFields?.first{
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.right)
                self.todoListSynchronize()
            }
        }
        alertController.addAction(okButton)
        let cancelButton = UIAlertAction(title: "CANSEL", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    
    private func storedTodoList() {
        if let storedTodoList = UserDefaults.standard.object(forKey: "todoList") as? Data {
            do {
                if let unarchiverTodoList = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MyTodo.self], from: storedTodoList) as? [MyTodo] {
                    todoList.append(contentsOf: unarchiverTodoList)
                }
            } catch {
                print("error: todoList synchronize")
            }
        }
    }
    private func todoListSynchronize() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "todoList")
            UserDefaults.standard.synchronize()
        } catch {
            print("error: todoList synchronize")
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if todoList[indexPath.row].todoDone {
            todoList[indexPath.row].todoDone = false
        } else {
            todoList[indexPath.row].todoDone = true
        }
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        
        todoListSynchronize()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            todoList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
            todoListSynchronize()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        cell.textLabel?.text = todoList[indexPath.row].todoTitle
        
        if todoList[indexPath.row].todoDone {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
}

//シリアライズできるようにNSObjectを継承し、NSSecureCodingプロトコルに準拠する
class MyTodo: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool{
        return true
    }
    var todoTitle: String?
    var todoDone: Bool = false
    
    override init() {
        
    }
    
    //NSCodingプロトコルに宣言されているシリアライズ処理(エンコード処理)
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDone")
    }
    
    //NSCodingプロトコルに宣言されているデシリアライズ処理(デコード処理)
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
    }
}
