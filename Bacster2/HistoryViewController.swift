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
        view.backgroundColor = .systemGreen
        self.getDrinksConsumed()
        
        navigationItem.title = "History"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(onboard(sender: )))
        
        tableView.register(DrinkEntry.self, forCellReuseIdentifier: cellID)
        tableView.register(HistoryHeader.self, forHeaderFooterViewReuseIdentifier: headerID)
        
        tableView.sectionHeaderHeight = 70
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("updateDashboard"), object: nil)
    }
    
    func getDrinksConsumed() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let drinks = Table("drinks")
        var cutoff_time: Int64 = 0
        if cutoff_time < self.timeLastUpdated {
            cutoff_time = self.timeLastUpdated
        }
        
        let timeBeganConsumption = Expression<Int64>("timeBeganConsumption")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let query = drinks.filter(timeBeganConsumption >= cutoff_time)   // WHERE timeAdded >= cutoff time
            self.drinksConsumed = []
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
        let drink = drinksConsumed[indexPath.row]
        let page = DrinkDataPage()
        page.drink = drink
        navigationController?.pushViewController(page, animated: true)
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as! HistoryHeader
//        
//        header.nameLabel.text = "History"
//        return header
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinksConsumed.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DrinkEntry
        
        let drink = drinksConsumed[indexPath.row]
        switch drink.drinkClass {
        case "Beer":
            cell.nameLabel.text = "A \(drink.beerContainer!.lowercased()) of beer"
        case "Wine":
            cell.nameLabel.text = "A \(drink.wineContainer!.lowercased()) of wine"
        case "Spirits":
            if drink.spiritType != "Cordials" {
                cell.nameLabel.text = "A \(drink.spiritContainer!.lowercased()) of \(drink.spiritType!)"
            } else {
                cell.nameLabel.text = "A \(drink.spiritContainer!.lowercased()) of \(drink.cordialType!)"
            }
        case "Cocktail":
            switch drink.cocktailMultiplier {
            case 1.0:
                cell.nameLabel.text = "A standard \(drink.cocktailType!)"
            case 1.5:
                cell.nameLabel.text = "A strong \(drink.cocktailType!)"
            case 2.0:
                cell.nameLabel.text = "A double \(drink.cocktailType!)"
            case 3.0:
                cell.nameLabel.text = "A triple \(drink.cocktailType!)"
            default:
                cell.nameLabel.text = "An invalid \(drink.cocktailType!)"
            }
        
        default:
            cell.nameLabel.text = "Invalid drinkClass"
        }
        
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .short
        cell.descriptionLabel.text = df.string(from: Date(timeIntervalSince1970: drink.timeBeganConsumption))
        return cell
    }
    
    @objc func update() {
        self.getDrinksConsumed()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        view.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        
        collectionView?.register(DrinkInfoCell.self, forCellWithReuseIdentifier: ident)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInsetReference = .fromSafeArea
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.isScrollEnabled = collectionView.collectionViewLayout.collectionViewContentSize.height > collectionView.frame.size.height - (self.tabBarController?.tabBar.frame.size.height)!
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        collectionView.insetsLayoutMarginsFromSafeArea = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            let lay = collectionViewLayout as! UICollectionViewFlowLayout
            let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing * 2 - 20
            
            return CGSize(width: widthPerItem, height: widthPerItem - 0.09 * UIScreen.main.bounds.width)
            
            //return CGSize(width: (self.view.frame.width / 2) - 20, height: 140)
        }
        return CGSize(width: self.view.frame.width - 100, height: self.view.frame.height / 3 - 0.05 * UIScreen.main.bounds.width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch drink?.drinkClass {
        case "Beer":
            return 10
        case "Wine":
            return 9
        case "Spirits":
            return 9
        case "Cocktail":
            return 9
        default:
            return 7
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ident, for: indexPath) as! DrinkInfoCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 10, left: 12.5, bottom: 10, right: 12.5)
        }
        return UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
    
    var descriptionLabel: RoundedUILabel = {
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
    
    var quantityLabel: UILabel = {
        let label = UILabel()
        label.text = "test QTY"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = label.font.withSize(60)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setup() {
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = .init(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 1)
        self.backgroundColor = .white
        addSubview(descriptionLabel)
        addSubview(quantityLabel)
        let constraints = [
            quantityLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            quantityLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            quantityLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            quantityLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            descriptionLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
            descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
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
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 18),
            descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 18)
        ]
            
        NSLayoutConstraint.activate(constraints)
        
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[v0]-10-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": descriptionLabel]))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[v0]-4-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": descriptionLabel]))
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
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
