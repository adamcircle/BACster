//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//

import UIKit
import Lottie

class Drink {
    var gramsAlcohol: Float?
    var percentAcohol: Float?
    var timeBeganConsumption: Date?
    var timeAdded: Date?
    var consumptionDuration: DateInterval?
    var drinkClass: String?
    var containerSize: Float? // units of mL
    var drinkUnits: String?
    var drinkFullLife: Date?
    var drinkHalfLife: Date?
    var hunger: Float?
    
    // Beer Specific Data
    var beerStrength: Float?  // lo: .027, med: .035, full: .048, dub: .0675, trip: .085, quad: .115
    var sipOrShotgun: String?
    var beerContainer: String?
    
    // Wine Specific Data
    var wineColor: String?
    var wineContainer: String?
    
    // Spirit Specific Data
    var spiritType: String?
    var whiskeyContainer: String?
    var sakeContainer: String?
    var cordialType: String?
    
    // Cocktail Specific Data
    var cocktailType: String?
    var cocktailSize: Float?
    
    private func getGramsAlcohol() {
        self.gramsAlcohol = 4.0
    }
}


struct Question {
    var questionString: String
    var answers: [String]
    var pushTo: [Int:String]
}

let questionsDict: [String:Question] = [
    "drinkClass":
        Question(questionString: "What are you drinking?",
                 answers: ["Beer", "Wine", "Spirits", "Cocktail", "Custom"],
                 pushTo: [0: "beerStrength", 1: "wineColor", 2: "spiritType", 3: "cocktailType", 4: "hunger"]),
    "beerStrength":
        Question(questionString: "What is the strength of your beer? (most beers are 'Full')",
                 answers: ["Low (2.7%)", "Medium (3.5%)", "Full (4.8%)", "Dubbel (6.8%)", "Trippel (8.5%)", "Quadruppel (11.5%)", "Custom"],
                 pushTo: [0: "beerContainer"]),
    "beerContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Full Solo Cup", "Half Solo Cup", "Standard Can", "Tall Can", "Pint", "Half Pint", "Custom"],
                 pushTo: [0: "sipOrShotgun"]),
    "sipOrShotgun":
        Question(questionString: "Are you sipping or shotgunning?",
                 answers: ["Sipping", "Shotgunning"],
                 pushTo: [0: "timeBeganConsumption"]),
    "timeBeganConsumption":
        Question(questionString: "When did you start drinking?",
                 answers: ["Now", "15 minutes ago", "30 minutes ago", "45 minutes ago", "1 hour ago", "1.5 hour ago"],
                 pushTo: [0: "hunger"]),
    "hunger":
        Question(questionString: "How hungry are you right now?",
                 answers: ["Full", "Not Hungry", "Hungry", "Very Hungry"],
                 pushTo: [0: "done"]),
    "wineColor":
        Question(questionString: "Red, white, or bubbly?",
                 answers: ["Red", "White", "Champagne"],
                 pushTo: [0: "wineContainer"]),
    "wineContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Glass", "Flute", "Half bottle", "Bottle", "Solo Cup", "Half Solo Cup"],
                 pushTo: [0: "timeBeganConsumption"]),
    "spiritType":
        Question(questionString: "What are you drinking?",
                 answers: ["Vodka", "Rum", "Tequila", "Gin", "Whiskey", "Sake", "Cordials"],
                 pushTo: [0: "spiritContainer", 1: "spiritContainer", 2: "spiritContainer", 3: "spiritContainer", 4: "whiskeyContainer", 5: "sakeContainer", 6: "cordialType"]),
    "spiritContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Standard shot (1oz)", "Tall shot (1.5oz)", "Double shot (2oz)", "Quarter Solo Cup", "Half Solo Cup"],
                 pushTo: [0: "timeBeganConsumption"]),
    "whiskeyContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Standard shot (1oz)", "Tall shot (1.5oz)", "Double shot (2oz)", "Glencairn"],
                 pushTo: [0: "timeBeganConsumption"]),
    "sakeContainer":
        Question(questionString: "How much are you drinking?",
                 answers: [ "Tokkuri (small flask)", "Masu (wooden box)", "2-go", "3-go", "4-go", "Standard shot (1oz)", "Tall shot (1.5oz)", "Double shot (2oz)"],
                 pushTo: [0: "timeBeganConsumption"]),
    "cordialType":
        Question(questionString: "What are you drinking?",
                 answers: ["Amaretto", "Baileys", "Jägermeister", "Kahlúa", "Schnapps", "Amarula", "Pavan", "Licor 43", "Strega", "Custom"],
                 pushTo: [0: "spiritContainer"]),
    "cocktailType":
        Question(questionString: "What are you drinking?", answers: ["Bloody Mary", "Jack & Coke", "Gin & Tonic", "Rum & Coke", "Manhattan", "Margarita", "Mimosa", "Mai Tai", "Mojito", "Daquiri", "Piña Colada", "Martini", "Aviation", "Sidecar"], pushTo: [0: "cocktailSize"]),
    "cocktailSize":
        Question(questionString: "How big is the cocktail?",
                 answers: ["About standard size", "A drink and a half", "Double", "Triple"],
                 pushTo: [0: "timeBeganConsumption"])
]

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
            resultsLabel.text = "You added your drink! Party on! ;)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Done!"
        view.backgroundColor = UIColor.white
        
        view.addSubview(resultsLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": resultsLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]-300-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": resultsLabel]))
        
        // Add success animation
        animationView = .init(name: "checkmark")
        let size = animationView!.frame.size.height * 0.9
        animationView!.frame = CGRect(x: self.view.frame.size.width / 2 - size / 2, y: 150,
                                      width: size, height: size)
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 0.8
        view.addSubview(animationView!)
        animationView!.play()
        
        
    }
    
    let resultsLabel: UILabel = {
        let label = UILabel()
        label.text = "Congrats"
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
        label.text = "Sample question"
        label.font = UIFont.boldSystemFont(ofSize: 14)
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
        label.text = "Sample answer"
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
