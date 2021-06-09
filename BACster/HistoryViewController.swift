//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//


import UIKit
import SQLite

class HistoryTVController: UITableViewController {

    var drinksConsumed: [Drink] = []
    var timeLastUpdated: Int64 = 0
    let ident = "type2"
    let headerID = "headerID"
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        self.getDrinksConsumed()
        self.background()
        
        navigationItem.title = "History"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(onboard(sender: )))
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = infoBarButtonItem
        
        tableView.register(DrinkEntry.self, forCellReuseIdentifier: cellID)
        tableView.register(HistoryHeader.self, forHeaderFooterViewReuseIdentifier: headerID)
        tableView.dataSource = self
        
        tableView.sectionHeaderHeight = 70
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("updateDashboard"), object: nil)
    }
    
    @objc func infoAction() {
        let alert = UIAlertController(title: "Terms of Use", message:
        """
        These are the Terms of Use for BACster as of the 31st of May, 2021.
        
        Please read these Terms of Use ("Terms") carefully before using the BACster app (the "Service") operated by BACster ("us", "we", or "our").

        Your access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users and others who access or use the Service.

        By accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.

        For Entertainment Only

        Our Service is to be used for entertainment purposes only. By using the Service you acknowledge and agree that we shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with use of or reliance on our Service.
        """, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func getDrinksConsumed() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let drinks = Table("drinks")
        var cutoff_time: Int64 = 0
        if cutoff_time < self.timeLastUpdated {
            cutoff_time = self.timeLastUpdated
        }
        
        let timeAdded = Expression<Int64>("timeAdded")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let query = drinks.filter(timeAdded >= cutoff_time)   // WHERE timeAdded >= cutoff time
            for drink in try db.prepare(query) {
                self.drinksConsumed.append(Drink().load(from: drink))
            }
            self.timeLastUpdated = Int64(Date().timeIntervalSince1970)
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed, drinks not retreived: \(message), in \(String(describing: statement))")
        } catch let error {
            NSLog("drinks not retreived: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let drink = drinksConsumed.reversed()[indexPath.row]
        let page = DrinkDataPage()
        let cell = tableView.cellForRow(at: indexPath) as! DrinkEntry
        page.navigationItem.title = cell.nameLabel.text
        page.drink = drink
        navigationController?.pushViewController(page, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinksConsumed.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DrinkEntry
        
        let drink = drinksConsumed.reversed()[indexPath.row]
        switch drink.drinkClass {
        case "Beer":
            cell.nameLabel.text = "\(drink.beerContainer!.capitalizingFirstLetter()) of beer"
        case "Wine":
            cell.nameLabel.text = "\(drink.wineContainer!.capitalizingFirstLetter()) of wine"
        case "Spirits":
            if drink.spiritType != "Cordials" {
                cell.nameLabel.text = "\(drink.spiritContainer!.capitalizingFirstLetter()) of \(drink.spiritType!)"
            } else {
                cell.nameLabel.text = "\(drink.spiritContainer!.capitalizingFirstLetter()) of \(drink.cordialType!)"
            }
        case "Cocktail":
            switch drink.cocktailMultiplier {
            case 1.0:
                cell.nameLabel.text = "Standard \(drink.cocktailType!)"
            case 1.5:
                cell.nameLabel.text = "Strong \(drink.cocktailType!)"
            case 2.0:
                cell.nameLabel.text = "Double \(drink.cocktailType!)"
            case 3.0:
                cell.nameLabel.text = "Triple \(drink.cocktailType!)"
            default:
                cell.nameLabel.text = "An invalid \(drink.cocktailType!)"
            }
        
        default:
            cell.nameLabel.text = "Invalid drinkClass"
        }
        
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .short
        cell.descLabel.text = df.string(from: Date(timeIntervalSince1970: drink.timeBeganConsumption))
        return cell
    }
    
    func background() {
        if drinksConsumed.count == 0 {
            tableView.setNoDataPlaceholder("No drinks yet!")
        } else {
            tableView.removeNoDataPlaceholder()
        }
    }
    
    @objc func update(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            if data["reset"] == true {
                self.drinksConsumed = []
                self.timeLastUpdated = 0
            }
        }
        self.getDrinksConsumed()
        self.background()
        self.tableView.reloadData()
    }
    
    @objc func onboard(sender: UIBarButtonItem) {
        let welcomeViewCon = UINavigationController.init(rootViewController: OBPage1())
        welcomeViewCon.modalPresentationStyle = .fullScreen
        present(welcomeViewCon, animated: true, completion: nil)
    }
    
}

class DrinkDataPage: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var drink: Drink? = nil
    let ident = "type3"
    let ident2 = "type4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        collectionView?.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        
        collectionView?.register(DrinkInfoCell.self, forCellWithReuseIdentifier: ident)
        collectionView?.register(DrinkDeleteButton.self, forCellWithReuseIdentifier: ident2)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInsetReference = .fromSafeArea
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.isScrollEnabled = true
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        collectionView.insetsLayoutMarginsFromSafeArea = true
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let lay = collectionViewLayout as! UICollectionViewFlowLayout
            let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing * 2 - 20
            
            return CGSize(width: widthPerItem, height: widthPerItem - 0.09 * UIScreen.main.bounds.width)
        }
        return CGSize(width: self.view.frame.width - 20, height: 50)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 8
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ident, for: indexPath) as! DrinkInfoCell
        switch indexPath.row {
        case 0:
            if indexPath.section == 0 {
                let time = Date(timeIntervalSince1970: (drink?.timeBeganConsumption)!)
                let df = DateFormatter()
                df.timeStyle = .short
                df.dateStyle = .long
                cell.dataLabel.text = df.string(from: time)
                cell.descLabel.text = "Time consumed"
            } else {
                let button = collectionView.dequeueReusableCell(withReuseIdentifier: ident2, for: indexPath) as! DrinkDeleteButton
                button.dataLabel.text = "DELETE"
                return button
            }
        case 1:
            let time = Date(timeIntervalSince1970: (drink?.timeAdded)!)
            let df = DateFormatter()
            df.timeStyle = .short
            df.dateStyle = .long
            cell.dataLabel.text = df.string(from: time)
            cell.descLabel.text = "Time added"
        case 2:
            cell.dataLabel.text = String(format: "%.01f", (drink?.percentAlcohol ?? -0.99) * 100)
            cell.descLabel.text = "Percent alcohol"
        case 3:
            cell.dataLabel.text = String(format: "%.f", drink?.gramsAlcohol ?? -98)
            cell.descLabel.text = "Grams alcohol"
        case 4:
            cell.dataLabel.text = String(format: "%.lld   |   %.01f", drink?.volumeML ?? -97, Double(drink?.volumeML ?? 2868) * 0.033814)
            cell.descLabel.text = "Volume (mL | oz)"
        case 5:
            switch drink?.drinkClass {
            case "Beer":
                cell.dataLabel.text = drink?.beerContainer
                cell.descLabel.text = "Container"
            case "Wine":
                cell.dataLabel.text = drink?.wineContainer
                cell.descLabel.text = "Container"
            case "Spirits":
                if drink?.spiritType == nil {
                    cell.dataLabel.text = drink?.cordialType
                    cell.descLabel.text = "Cordial type"
                } else {
                    cell.dataLabel.text = drink?.spiritType
                    cell.descLabel.text = "Spirit type"
                }
            case "Cocktail":
                cell.dataLabel.text = drink?.cocktailType
                cell.descLabel.text = "Cocktail type"
            default:
                cell.dataLabel.text = String(-96)
                cell.descLabel.text = "Invalid drink class"
            }
        case 6:
            switch drink?.drinkClass {
            case "Beer":
                if drink?.sipOrShotgun == "Sipping" {
                    cell.dataLabel.text = "Sipped"
                } else {
                    cell.dataLabel.text = "Shotgunned"
                }
                cell.descLabel.text = "Sipped?"
            case "Wine":
                cell.dataLabel.text = drink?.wineColor
                cell.descLabel.text = "Type of wine"
            case "Spirits":
                cell.dataLabel.text = drink?.spiritContainer
                cell.descLabel.text = "Container"
            case "Cocktail":
                cell.descLabel.text = "Strength"
                switch drink?.cocktailMultiplier {
                case 1.0:
                    cell.dataLabel.text = "Standard"
                case 1.5:
                    cell.dataLabel.text = "Strong"
                case 2.0:
                    cell.dataLabel.text = "Double"
                case 3.0:
                    cell.dataLabel.text = "Triple"
                default:
                    cell.dataLabel.text = String(-94)
                }
            default:
                cell.dataLabel.text = String(-95)
                cell.descLabel.text = "Invalid drink class"
            }
        case 7:
            switch drink?.halfLife {
            case 15:
                cell.dataLabel.text = "Full"
            case 12:
                cell.dataLabel.text = "Not hungry"
            case 9:
                cell.dataLabel.text = "Hungry"
            case 6:
                cell.dataLabel.text = "Very hungry"
            default:
                cell.dataLabel.text = "-93, invalid halflife"
            }
            cell.descLabel.text = "Hunger level"
        default:
            cell.dataLabel.text = "Invalid row"
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.deleteDrink()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 10, left: 12.5, bottom: 10, right: 12.5)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func deleteDrink() {
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Are you sure you want to delete this drink?", message: "The drink will be permanently deleted.", preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: "Delete drink", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true).first!
            
            do {
                let db = try Connection("\(path)/db.sqlite3")
                self.drink?.delete(from: db)
                
                // Update stats
                let data = ["reset": true]
                NotificationCenter.default.post(name: Notification.Name("updateDashboard"), object: nil, userInfo: data)
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
}

class DrinkDeleteButton: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var dataLabel: UILabel = {
        let label = UILabel()
        label.text = "DELETE"
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = label.font.withSize(20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    func setup() {
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = .init(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 1)
        self.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        addSubview(dataLabel)
        let constraints = [
            dataLabel.topAnchor.constraint(equalTo: self.topAnchor),
            dataLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            dataLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            dataLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

class DrinkInfoCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var DLtopAnchConst: CGFloat = 0
    var DLbotAnchConst: CGFloat = -30
    
    var descLabel: RoundedUILabel = {
        let label = RoundedUILabel()
        label.text = "test DESC"
        label.textAlignment = .center
        label.font = label.font.withSize(20)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.6235294118, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dataLabel: UILabel = {
        let label = UILabel()
        label.text = "test QTY"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = label.font.withSize(20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setup() {
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = .init(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 1)
        self.backgroundColor = .white
        addSubview(descLabel)
        addSubview(dataLabel)
        let constraints = [
            dataLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: self.DLtopAnchConst),
            dataLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            dataLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: DLbotAnchConst),
            dataLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            descLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
            descLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            descLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            descLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}


class DrinkEntry: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(descLabel)
        
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 18),
            descLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            descLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 18)
        ]
            
        NSLayoutConstraint.activate(constraints)
        
    }
}

class HistoryHeader: UITableViewHeaderFooterView {
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
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst().lowercased()
    }

    private mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UITableView {
    func setNoDataPlaceholder(_ message: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        label.text = message
        // styling
        label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        label.sizeToFit()

        self.isScrollEnabled = false
        self.backgroundView = label
        self.separatorStyle = .none
    }
    
    func removeNoDataPlaceholder() {
            self.isScrollEnabled = true
            self.backgroundView = nil
            self.separatorStyle = .singleLine
        }
}
