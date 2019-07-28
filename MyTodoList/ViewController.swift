//
//  ViewController.swift
//  MyTodoList
//
//  Created by 今枝弘樹 on 2019/05/16.
//  Copyright © 2019 Hiroki Imaeda. All rights reserved.
//

import UIKit

//UITableViewDataSource,UITableViewDelegateのプロトコルを実装する宣言
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //保存しているToDoの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data {
            do {
                if let unarchiverTodoList = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MyTodo.self], from: storedTodoList) as? [MyTodo] {
                    todoList.append(contentsOf: unarchiverTodoList)
                }
            } catch {
                //エラー処理なし
            }
        }
    }
    
    //+ボタンをタップした時の処理
    @IBAction func tapAddButton(_ sender: Any) {
        //アラートダイアログを生成
        let alertController = UIAlertController(title: "ToDo追加", message: "ToDoを入力してください", preferredStyle: UIAlertController.Style.alert)
        
        //テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        
        //OKボタンの機能を定義
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default){
            (action: UIAlertAction) in
            //OKボタンがタップされた時の処理
            if let textField = alertController.textFields?.first{
                //ToDoの配列に入力値を先頭に挿入
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                //テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.right)
                
                //ToDoを保存する処理
                let userDefaults = UserDefaults.standard
                //Data型にシニアライズする
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey:"todoList")
                    userDefaults.synchronize()
                } catch {
                    //エラー処理なし
                }
            }
        }
        //OKボタンを追加
        alertController.addAction(okButton)
        
        //CANCELボタンの機能を定義
        let cancelButton = UIAlertAction(title: "CANSEL", style: UIAlertAction.Style.cancel, handler: nil)
        //CANSELボタンを追加
        alertController.addAction(cancelButton)
        
        //アラートダイアログを表示
        present(alertController, animated: true, completion: nil)
    }
    
    //テーブルの行数を返却する関数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ToDoの配列の長さを返却する
        return todoList.count
    }
    
    //テーブルごの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //todoCell識別子を利用して再利用可能なセルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        //行番号に合ったToDoの情報を取得
        let myTodo = todoList[indexPath.row]
        
        //セルのラベルにToDoのタイトルをセット
        cell.textLabel?.text = myTodo.todoTitle
        
        //セルのチェックマーカー状態をセット
        if myTodo.todoDone {
            //チェックあり
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            //チェックなし
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    //セルをタップした時の処理、チェックマークを付けるか付けないか
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone {
            //完了済みの場合は未完了に変更
            myTodo.todoDone = false
        } else {
            //未完了の場合は完了済みに変更
            myTodo.todoDone = true
        }
        
        //セルの状態を変更
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        
        //データ保存。シニアライズする
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            //UserDefaultsに保存
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        } catch {
            //エラー処理なし
        }
    }
    
    //セルが編集可能かどうかを返却する
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //セルを削除した時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //削除可能かどうか
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //ToDoリストから削除
            todoList.remove(at: indexPath.row)
            //セルを削除
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
            //データ保存。Data型にシニアライズする
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
                //UserDefaultsに保存
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            } catch {
                //エラー処理なし
            }
        }
    }
}

//独自クラスMyTodoを作成
//シリアライズできるようにNSObjectを継承し、NSSecureCodingプロトコルに準拠する必要がある
class MyTodo: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool{
        return true
    }
    
    //ToDoのタイトル
    var todoTitle: String?
    
    //ToDoが完了したかどうかを表すフラグ
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
