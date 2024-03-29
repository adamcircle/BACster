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
        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        // register cells
        tableView.register(AnswerCell.self, forCellReuseIdentifier: cellID)
        tableView.register(QuestionHeader.self, forHeaderFooterViewReuseIdentifier: headerID)
        
        tableView.sectionHeaderHeight = 70
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
            let data = ["Beer", "Wine", "Spirits", "Cocktail"]
            drink.drinkClass = data[index]
            
        } else if questionID == "beerStrength" {
            let data: [Double] = [0.027, 0.035, 0.048, 0.068, 0.085, 0.115]
            drink.beerStrength = data[index]
        } else if questionID == "beerContainer" {
            drink.beerContainer = question?.answers[index]
        } else if questionID == "timeBeganConsumption" {
            var timeBegan = Date().addingTimeInterval(TimeInterval(-1 * 60.0))
            switch index {
            case 0: break
            case 1: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-15.0 * 60.0))
            case 2: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-30.0 * 60.0))
            case 3: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-45.0 * 60.0))
            case 4: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-60.0 * 60.0))
            case 5: timeBegan = timeBegan.addingTimeInterval(TimeInterval(-90.0 * 60.0))
            default: break
            }
            drink.timeBeganConsumption = Double(timeBegan.timeIntervalSince1970)
        } else if questionID == "hunger" {
            let data: [Int64] = [15, 12, 9, 6]
            drink.halfLife = data[index]
        } else if questionID == "wineColor" {
            drink.wineColor = question?.answers[index]
        } else if questionID == "wineContainer" {
            drink.wineContainer = question?.answers[index]
        } else if questionID == "spiritType" {
            drink.spiritType = question?.answers[index]
        } else if questionID == "spiritContainer" {
            drink.spiritContainer = question?.answers[index]
        } else if questionID == "whiskeyContainer" {
            drink.spiritContainer = question?.answers[index]
        } else if questionID == "sakeContainer" {
            drink.spiritContainer = question?.answers[index]
        } else if questionID == "cordialType" {
            drink.cordialType = question?.answers[index]
        } else if questionID == "cocktailType" {
            drink.cocktailType = question?.answers[index]
        } else if questionID == "cocktailMultiplier" { // hunger level
            var multiplier: Double = 1.0
            switch index {
                case 0: break
                case 1: multiplier = 1.5
                case 2: multiplier = 2.0
                case 3: multiplier = 3.0
                default: break
            }
            drink.cocktailMultiplier = multiplier
        } else if questionID == "sipOrShotgun" {
            drink.sipOrShotgun = question?.answers[index]
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
    
    var drink = Drink()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drink.timeAdded = Double(Date().timeIntervalSince1970)
        drink.computeDerivedValues()
        navigationItem.title = "Done!"
        view.backgroundColor = UIColor.white
        navigationItem.setHidesBackButton(true, animated: true)
        
        // write the drink to the db
        var db: Connection?
        let rowID: Int64?
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true).first!
            db = try Connection("\(path)/db.sqlite3")
            
            rowID = drink.save(to: db!)
        } catch {
            NSLog("Could not open connection to save drink: ")
            rowID = -1
        }
        
        // Update stats
        NotificationCenter.default.post(name: Notification.Name("updateDashboard"), object: nil)
        
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
        deleteButton(size: checkmarkSize, rowID: Int(rowID!))
    }
    
    func successAnimation(size: CGFloat) {
        animationView!.frame = CGRect(x: self.view.frame.size.width / 2 - size / 2, y: self.view.frame.size.height - 450, width: size, height: size)
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 0.8
        view.addSubview(animationView!)
        animationView!.play()
    }
    
    func addAnotherDrinkButton(size: CGFloat) {
        let addAnotherButton = ResultsButton()
        addAnotherButton.frame = CGRect(x: self.view.frame.size.width / 2 - ((size + 50 ) / 2), y: self.view.frame.size.height - 250, width: size + 50, height: 30)
        addAnotherButton.setTitle("Add another drink", for: .normal)
        addAnotherButton.addTarget(self, action: #selector(addAnother(_:)), for: .touchUpInside)
        view.addSubview(addAnotherButton)
    }
    
    func deleteButton(size: CGFloat, rowID: Int) {
        let deleteButton = ResultsButton()
        deleteButton.frame = CGRect(x: self.view.frame.size.width / 2 - ((size + 50 ) / 2), y: self.view.frame.size.height - 200, width: size + 50, height: 30)
        deleteButton.setTitle("Delete this drink", for: .normal)
        deleteButton.tag = rowID
        deleteButton.addTarget(self, action: #selector(deleteDrinkButton(_:)), for: .touchUpInside)
        view.addSubview(deleteButton)
    }
    
    @objc func addAnother(_ sender:UIButton!) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func deleteDrinkButton(_ sender:ResultsButton!) {
        if sender.tag == -1 {
            NSLog("rowID not found; drink cannot be deleted")
            return
        }
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Are you sure you want to delete this drink?", message: "The drink will be permanently deleted.", preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: "Delete drink", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true).first!
            
            do {
                let db = try Connection("\(path)/db.sqlite3")
                self.drink.delete(from: db)
                
                // Update stats
                NotificationCenter.default.post(name: Notification.Name("updateDashboard"), object: nil)
            } catch let error {
                NSLog("connection failed, could not delete drink: \(error)")
            }
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
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
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
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
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[v0]-10-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
}

class ResultsButton : UIButton {

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
