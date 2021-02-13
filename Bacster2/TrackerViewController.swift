//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//

import UIKit
import Lottie
import SQLite

class TrackerViewController: UITableViewController {
    
    let cellID = "cellID"
    let headerID = "headerID"
    var questionID = "drinkClass"
    var question = questionsDict["drinkClass"]
    var drink = Drink()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = "Tracker"
        view.backgroundColor = .systemRed
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        tableView.register(AnswerCell.self, forCellReuseIdentifier: cellID)
        tableView.register(QuestionHeader.self, forHeaderFooterViewReuseIdentifier: headerID)
        
        tableView.sectionHeaderHeight = 50
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return question?.answers.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! AnswerCell
        
        cell.nameLabel.text = question?.answers[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as! QuestionHeader
        
        header.nameLabel.text = question?.questionString
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item
        var nextQuestionID: String
        
        // Set the nextQuestionID
        if question?.pushTo[index] != nil {
            nextQuestionID = (question?.pushTo[index])!
        } else {
            nextQuestionID = (question?.pushTo[0])!
        }
        
        // Finished with questions
        if nextQuestionID == "done" {
            let controller = ResultsController()
            controller.drink = drink
            navigationController?.pushViewController(controller, animated: true)
        }
        
        // Response for each question
        if questionID == "drinkClass" {
            let data = ["Beer", "Wine", "Spirits", "Cocktail", "Custom"]
            drink.drinkClass = data[index]
            
        } else if questionID == "beerStrength" {
            let data: [Float] = [0.027, 0.035, 0.048, 0.068, 0.085, 0.115]
            drink.beerStrength = data[index]
        } else if questionID == "beerContainer" {
            let data = ["Full Solo Cup", "Half Solo Cup", "Standard Can", "Tall Can", "Pint", "Half Pint"]
            drink.beerContainer = data[index]
        } else if questionID == "sipOrShotgun" {
            let data = ["Sipping", "Shotgunning"]
            drink.sipOrShotgun = data[index]
        } else if questionID == "timeBeganConsumption" {
            var timeBegan = Date()
            switch index {
            case 0: break
            case 1: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-15.0 * 60.0))
            case 2: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-30.0 * 60.0))
            case 3: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-45.0 * 60.0))
            case 4: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-60.0 * 60.0))
            case 5: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-90.0 * 60.0))
            default: break
            }
            drink.timeBeganConsumption = timeBegan
        } else if questionID == "hunger" {
            let data: [Float] = [6.0, 9.0, 12.0, 15.0]
            drink.hunger = data[index]
        } else if questionID == "wineColor" {
            drink.wineColor = question?.answers[index]
        } else if questionID == "spiritType" {
            drink.spiritType = question?.answers[index]
        } else if questionID == "spiritContainer" {
            let data = ["Shot", "Tall shot", "Double shot", "Glencairn"]
            drink.whiskeyContainer = data[index]
        } else if questionID == "sakeContainer" {
            let data = ["Tokkuri", "Masu", "2-go", "3-go", "4-go", "Shot", "Tall shot", "Double shot"]
            drink.sakeContainer = data[index]
        } else if questionID == "cordialType" {
            drink.cordialType = question?.answers[index]
        } else if questionID == "cocktailType" {
            drink.cocktailType = question?.answers[index]
        } else if questionID == "cocktailMultiplier" {
            var multiplier: Float = 1.0
            switch index {
                case 0: break
                case 1: multiplier = 1.5
                case 2: multiplier = 2.0
                case 3: multiplier = 3.0
                default: break
            }
            drink.cocktailSize = multiplier
        }
        
        if nextQuestionID != "done" {
            let controller = TrackerViewController()
            controller.drink = drink
            controller.questionID = nextQuestionID
            controller.question = questionsDict[controller.questionID]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

class ResultsController: UIViewController {
    
    private var animationView: AnimationView?
    
    var drink = Drink() {
        didSet {
            // resultsLabel.text = "You added your drink! Party on! ;)"
        }
    }
    
    func saveDrink() -> Int64 {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let drinks = Table("drinks")
        
        let id = Expression<Int64>("id")
        let time_added = Expression<Int64>("time_added")
        let drink = Expression<SQLite.Blob>("drink")
        do {
            let db = try Connection("\(path)/db.sqlite3")
            try db.run(drinks.create(ifNotExists: true) { t in     // CREATE TABLE "drinks" (
                t.column(id, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(time_added, unique: true)
                t.column(drink)
            })
            let time_now = Int64(NSDate().timeIntervalSince1970)
            let rowID = try db.run(drinks.insert(time_added <- time_now, drink <- drink))
            return rowID

        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed: \(message), in \(String(describing: statement))")
            return -1
        } catch let error {
            NSLog("insertion failed: \(error)")
            return -1
        }
    }
    
    func deleteDrink(rowID: Int) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let drinks = Table("drinks")
        let id = Expression<Int>("id")
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let drinkToDelete = drinks.filter(id == rowID)
            try db.run(drinkToDelete.delete())
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            NSLog("insertion failed: \(error)")
        }
    }
    
    func successAnimation(size: CGFloat) {
        animationView!.frame = CGRect(x: self.view.frame.size.width / 2 - size / 2, y: 125, width: size, height: size)
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 0.8
        view.addSubview(animationView!)
        animationView!.play()
    }
    
    func addAnotherDrinkButton(size: CGFloat) {
        let addAnotherButton = MyButton()
        addAnotherButton.frame = CGRect(x: self.view.frame.size.width / 2 - ((size + 50 ) / 2), y: 175 + size, width: size + 50, height: 30)
        addAnotherButton.setTitle("Add another drink", for: .normal)
        addAnotherButton.addTarget(self, action: #selector(addAnother(_:)), for: .touchUpInside)
        view.addSubview(addAnotherButton)
    }
    
    func addDeleteButton(size: CGFloat, rowID: Int) {
        let deleteButton = MyButton()
        deleteButton.frame = CGRect(x: self.view.frame.size.width / 2 - ((size + 50 ) / 2), y: 225 + size, width: size + 50, height: 30)
        deleteButton.setTitle("Delete this drink", for: .normal)
        deleteButton.tag = rowID
        deleteButton.addTarget(self, action: #selector(deleteDrinkButton(_:)), for: .touchUpInside)
        view.addSubview(deleteButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Done!"
        view.backgroundColor = UIColor.white
        navigationItem.setHidesBackButton(true, animated: true)
        
        // write the drink to the db
        let rowID = saveDrink()
        
        // Add success text
        view.addSubview(resultsLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": resultsLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]-300-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": resultsLabel]))
        
        // Add success animation
        animationView = .init(name: "checkmark")
        let checkmarkSize: CGFloat = animationView!.frame.size.height * 0.9
        successAnimation(size: checkmarkSize)
        
        // Add button to go back to start
        addAnotherDrinkButton(size: checkmarkSize)
        
        // Add button to delete the drink
        addDeleteButton(size: checkmarkSize, rowID: Int(rowID))
    }
    
    @objc func addAnother(_ sender:UIButton!) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func deleteDrinkButton(_ sender:MyButton!) {
        if sender.tag == -1 {
            NSLog("rowID not found; drink cannot be deleted")
            return
        }
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Are you sure you want to delete this drink?", message: "The drink will be permanently deleted.", preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: "Delete drink", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.deleteDrink(rowID: sender.tag)
            self.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    let resultsLabel: UILabel = {
        let label = UILabel()
        label.text = "You added your drink! Party on! ;)"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
}

class QuestionHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AnswerCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[v0]-10-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
}

class MyButton : UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.layer.masksToBounds = true
        self.backgroundColor = #colorLiteral(red: 0.5514355459, green: 0.6232073761, blue: 1, alpha: 1)
        self.layer.cornerRadius = 15
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    }

}
