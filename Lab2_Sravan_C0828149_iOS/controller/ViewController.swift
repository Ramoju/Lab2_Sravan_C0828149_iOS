//
//  ViewController.swift
//  Lab2_Sravan_C0828149_iOS
//
//  Created by Sravan Sriramoju on 2022-01-24.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var player2Score: UILabel!
    
    @IBOutlet weak var player1Score: UILabel!
    
    @IBOutlet weak var messageLB: UILabel!
    
    var activePlayer = 1
    var activeGame = true
    var states = WinningPositions()
    var positions = WinningPositions()
    var p1score=0
    var p2score=0
    var cellsBkp: [Int] = []
    var cell: UIButton!
    var d1:String = "0"
    var d2:String = "0"
    
    var player1: [NSManagedObject] = []
    var player2: [NSManagedObject] = []
    

    
    // create the context
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        becomeFirstResponder()
        
        player1Score.text = d1
        player2Score.text = d2
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(replay))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(replay))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(replay))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(replay))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        messageLB.text = ""
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        let activePosition = sender.tag-1
        cell = sender
        if states.gameStates[activePosition] == 0 && activeGame {
            states.gameStates[activePosition] = activePlayer
            if(sender.image(for: .normal)==nil){
                if(activePlayer == 1){
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                        return
                    }
                    let context = appDelegate.persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName:"PlayerOne", in:context)!
                    let record = NSManagedObject(entity:entity, insertInto:context)
                    record.setValue(String(sender.tag), forKey:"gamestate")
                    saveData()
                    sender.setImage(UIImage(named: "nought.png"), for: [])
                    activePlayer = 2
                }
                else{
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                        return
                    }
                    let context = appDelegate.persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName:"PlayerTwo", in:context)!
                    let record = NSManagedObject(entity:entity, insertInto:context)
                    record.setValue(String(sender.tag), forKey:"gamestate")
                    saveData()
                    sender.setImage(UIImage(named: "cross.png"), for: [])
                    activePlayer = 1
            }
                sender.isEnabled=false
        }
            
            //check who is the winner
            for position in positions.winningPositions {
                if states.gameStates[position[0]] != 0 && states.gameStates[position[0]] == states.gameStates[position[1]] && states.gameStates[position[1]] == states.gameStates[position[2]]  {
                    activeGame=false
                    if states.gameStates[position[0]] == 1{
                        messageLB.text = "Player 1 (Noughts) is winner"
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                            return
                        }
                        let context = appDelegate.persistentContainer.viewContext
                        let entity = NSEntityDescription.entity(forEntityName:"PlayerOne", in:context)!
                        let record = NSManagedObject(entity:entity, insertInto:context)
                        p1score += 1
                        record.setValue(String(p1score), forKey:"score")
                        saveData()
                        fetchPlayer1()
                        let sc = player1[player1.count-1]
                        player1Score.text = String(describing: sc.value(forKey: "score") ?? "0")
                        d1 = String(describing: sc.value(forKey: "score") ?? "0")
                        print(String(describing: sc.value(forKey: "score")))
                        
                    }
                    else{
                        messageLB.text = "Player 2 (Crosses) is winner"
                        p2score += 1
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                            return
                        }
                        let context = appDelegate.persistentContainer.viewContext
                        let entity = NSEntityDescription.entity(forEntityName:"PlayerTwo", in:context)!
                        let record = NSManagedObject(entity:entity, insertInto:context)
                        record.setValue(String(p2score), forKey:"score")
                        saveData()
                        fetchPlayer2()
                        let sc = player2[player2.count-1]
                        player2Score.text = String(describing: sc.value(forKey: "score") ?? "0")
                        d2 = String(describing: sc.value(forKey: "score") ?? "0")
                        
                    }
                }
            }
            if drawMatch() && activeGame {
                messageLB.text = "No Winner"
            }
        }
    }
    
    
    //Code for Game replay, method gets invoked when user swipes in any direction
    @objc func replay(gesture: UISwipeGestureRecognizer){
        let swipeGesture = gesture as UISwipeGestureRecognizer
        switch swipeGesture.direction{
        case .left, .right, .up, .down:
            //print("gesture recognised")
            states.gameStates = [0,0,0,0,0,0,0,0,0]
            activeGame = true
            for i in 1..<10 {
                if let buttons = view.viewWithTag(i) as? UIButton {
                    buttons.setImage(nil, for: [])
                    buttons.alpha = 1
                    buttons.isEnabled=true
                }
            }
            messageLB.text = ""
            
        default:
            break
        }
        
    }
    
    //fetching players data
    func fetchPlayer1(){
      //  let fetchRequest = NSFetchRequest < NSManagedObject > (entityName: "Tictactoe")
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: "PlayerOne")
        do {
           player1 =
            try context.fetch(fetchRequest)
        } catch
        let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
}
    
    func fetchPlayer2(){
      //  let fetchRequest = NSFetchRequest < NSManagedObject > (entityName: "Tictactoe")
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: "PlayerTwo")
        do {
           player2 =
            try context.fetch(fetchRequest)
        } catch
        let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
}
    
    
    //
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    // this method checks if game is a draw
    func drawMatch() -> Bool {
        for state in states.gameStates {
            if state == 0 {
                return false
            }
        }
        return true }
    
    
    // this gets executed when user shakes his phone to undo his game
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake{
            positions.gameStates = cellsBkp
            print("\(positions.gameStates) \(cell.tag) ")
            cell.setImage(nil, for: .normal)
            if activePlayer == 1{
                activePlayer = 2
            }
            else
            {
                activePlayer=1
            }
        }
        
        //delete
        do{
       // self.context.delete(self.details[indexPath.row])
            try context.save()
        }catch{
            print(error)
        }
        
    }

}

