//
//  OnboardingFlow.swift
//  Bacster2
//
//  Created by Adam Circle on 3/6/21.
//

import Foundation
import UIKit
import Lottie
import SQLite

/*
class OBNavCon: UINavigationController {
    self
} */

class OBPage0: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 0.9921568627, alpha: 1)
        navigationController?.isNavigationBarHidden = true
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 200))
        titleLabel.text = "Welcome to BACster!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        view.addSubview(titleLabel)
        
        let subtitleLabel = OnboardingLabel(frame: CGRect(x: 50, y: 200, width: self.view.frame.size.width - 100, height: 200))
        subtitleLabel.text = "We're going to get started by collecting some basic health information necessary to calculate your BAC."
        subtitleLabel.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(subtitleLabel)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height * 0.96 - 50, width: length, height: 50))
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    @objc func didTapButton(_ button: UIButton) {
        //self.authorizeHealthkit()
        let nextVC = OBPage1()
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
    
class OBPage1: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let sexArray = ["Male", "Female", "Other"]
    var sexPicker: UIPickerView!
    let profile = UserHealthProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 0.9921568627, alpha: 1)
        
        navigationController?.isNavigationBarHidden = true
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: self.view.frame.size.height / 4, width: self.view.frame.size.width - 20, height: 50))
        titleLabel.text = "What is your sex?"
        view.addSubview(titleLabel)
        
        sexPicker = UIPickerView(frame: CGRect(x: 100, y: self.view.frame.size.height / 4 + 80, width: view.frame.size.width - 200, height: 200))
        //sexPicker.translatesAutoresizingMaskIntoConstraints = false
        sexPicker.delegate = self as UIPickerViewDelegate
        sexPicker.dataSource = self as UIPickerViewDataSource
        view.addSubview(sexPicker)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height * 0.96 - 50, width: length, height: 50))
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return sexArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return sexArray[row]
    }
    
    @objc func didTapButton(_ button: UIButton) {
        if sexPicker.selectedRow(inComponent: 0) == 0 {
            profile.sex = 1
        } else {
            profile.sex = 0
        }
        let nextVC = OBPage2()
        nextVC.profile = profile
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

class OBPage2: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let ageArray = Array(16...125)
    var agePicker: UIPickerView!
    var profile: UserHealthProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 0.9921568627, alpha: 1)
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: self.view.frame.size.height / 4, width: self.view.frame.size.width - 20, height: 50))
        titleLabel.text = "How old are you?"
        view.addSubview(titleLabel)
        
        agePicker = UIPickerView(frame: CGRect(x: 100, y: self.view.frame.size.height / 4 + 80, width: view.frame.size.width - 200, height: 200))
        agePicker.delegate = self as UIPickerViewDelegate
        agePicker.dataSource = self as UIPickerViewDataSource
        view.addSubview(agePicker)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height * 0.96 - 50, width: length, height: 50))
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return ageArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return String(ageArray[row])
    }
    
    @objc func didTapButton(_ button: UIButton) {
        //self.authorizeHealthkit()
        let nextVC = OBPage3()
        profile.age = Int64(ageArray[agePicker.selectedRow(inComponent: 0)])
        nextVC.profile = profile
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

class OBPage3: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let footArray = Array(4...8)
    let inchArray = Array(0...11)
    var heightPicker: UIPickerView!
    var profile: UserHealthProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 0.9921568627, alpha: 1)
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: self.view.frame.size.height / 4, width: self.view.frame.size.width - 20, height: 50))
        titleLabel.text = "How tall are you?"
        view.addSubview(titleLabel)
        
        heightPicker = UIPickerView(frame: CGRect(x: 50, y: self.view.frame.size.height / 4 + 80, width: view.frame.size.width - 100, height: 300))
        heightPicker.delegate = self as UIPickerViewDelegate
        heightPicker.dataSource = self as UIPickerViewDataSource
        view.addSubview(heightPicker)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height * 0.96 - 50, width: length, height: 50))
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return footArray.count
        case 2:
            return inchArray.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(footArray[row])
        case 1:
            return "ft"
        case 2:
            return String(inchArray[row])
        default:
            return "in"
        }
    }
    
    @objc func didTapButton(_ button: UIButton) {
        //self.authorizeHealthkit()
        let nextVC = OBPage4()
        profile.heightInMeters = (Double(footArray[heightPicker.selectedRow(inComponent: 0)]) + Double(inchArray[heightPicker.selectedRow(inComponent: 0)]) / 12) * 0.3048
        nextVC.profile = profile
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

class OBPage4: UIViewController, UITextFieldDelegate {
    
    var profile: UserHealthProfile!
    var weightField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 0.9921568627, alpha: 1)
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: self.view.frame.size.height / 4, width: self.view.frame.size.width - 20, height: 50))
        titleLabel.text = "How much do you weigh?"
        view.addSubview(titleLabel)
        
        weightField = UITextField(frame: CGRect(x: 0, y: 300, width: view.frame.size.width, height: 80))
        weightField.becomeFirstResponder()
        weightField.placeholder = "0"
        weightField.textAlignment = .center
        weightField.font = UIFont.systemFont(ofSize: 50.0)
        weightField.delegate = self
        weightField.keyboardType = .numberPad
        weightField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        weightField.addDoneButtonToKeyboard(action: #selector(weightField.resignFirstResponder))
        view.addSubview(weightField)
        
        let lbsLabel = UILabel(frame: CGRect(x: view.frame.size.width / 2 + 60, y: 310, width: 100, height: 80))
        lbsLabel.text = "lbs"
        lbsLabel.textColor = .darkGray
        lbsLabel.font = UIFont.systemFont(ofSize: 25.0)
        view.addSubview(lbsLabel)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height * 0.96 - 50, width: length, height: 50))
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 3
    }
    
    @objc func didTapButton(_ button: UIButton) {
        if weightField.hasText && Int(weightField.text!)! > 20 {
            let nextVC = OBPage5()
            profile.weightInKilograms = Double(weightField.text!)! * 0.453592
            //NSLog(String(profile.weightInKilograms!))
            nextVC.profile = profile
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

class OBPage5: UIViewController {
    
    private var animationView: AnimationView?
    var profile: UserHealthProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 0.9921568627, alpha: 1)
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: self.view.frame.size.height / 4.8, width: self.view.frame.size.width - 20, height: 50))
        titleLabel.text = "Great! We're all done!"
        view.addSubview(titleLabel)
        
        // Add success animation
        animationView = .init(name: "champagne")
        let checkmarkSize: CGFloat = animationView!.frame.size.height * 0.7
        successAnimation(size: checkmarkSize)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height * 0.96 - 50, width: length, height: 50))
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    
    func successAnimation(size: CGFloat) {
        animationView!.frame = CGRect(x: self.view.frame.size.width / 2 - size / 2 - 10, y: self.view.frame.size.height / 5 - 60, width: size, height: size)
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 0.8
        view.addSubview(animationView!)
        animationView!.play()
    }
    
    @objc func didTapButton(_ button: UIButton) {
        //self.authorizeHealthkit()
        //let tabBarCon = TabBarController()
        //self.view.window?.rootViewController = tabBarCon
        let homeVC = UIApplication.shared.windows[0].rootViewController?.children[0] as? HomeCVController
        homeVC?.profile = profile
        profile.save()
        Core.shared.setIsNotNewUser()
        self.dismiss(animated: true, completion: nil)
        //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        //self.navigationController?.popToRootViewController(animated: true)
        //self.window?.rootViewController = tabBarCon
    }
}


class OnboardingLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.textAlignment = .center
        self.textColor = .black
        self.font = UIFont.boldSystemFont(ofSize: 22)
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
    }
}

class ContinueButton : UIButton {

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
        self.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.6235294118, blue: 1, alpha: 1)
        self.layer.cornerRadius = 15
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.setTitle("Continue", for: .normal)
    }

}

class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
    
    func setIsNewUser() {
        UserDefaults.standard.set(false, forKey: "isNewUser")
    }
}

class UserHealthProfile {
    var timeAdded: Double?
    var age: Int64?
    var sex: Int64?
    var heightInMeters: Double?
    var weightInKilograms: Double?
    var widmarkFactor: Double? {
        guard let weightKG: Double = weightInKilograms,
              let heightMeters: Double = heightInMeters,
              let sex = sex,
              let age = age,
              heightMeters > 0,
              weightKG > 0,
              age > 0
        else {
            return nil
        }
        if sex != 0 {  // male
            return 0.62544 + 0.13664 * heightMeters - weightKG * (0.00189 + 0.002425 / pow(heightMeters, 2)) + 1 / (weightKG * (0.57986 + 2.54 * heightMeters - 0.02255 * Double(age)))
        }
        return 0.50766 + 0.11165 * heightMeters - weightKG * (0.001612 + 0.0031 / pow(heightMeters, 2)) - 1 / (weightKG * (0.62115 - 3.1665 * heightMeters))
    }
    
    func load() -> Self {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let uhp = Table("UserHealthProfile")
        
        let timeAdded = Expression<Double>("timeAdded")
        let age = Expression<Int64?>("age")
        let sex = Expression<Int64?>("sex")
        let heightInMeters = Expression<Double?>("heightInMeters")
        let weightInKilograms = Expression<Double?>("weightInKilograms")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            if let row = try db.pluck(uhp) {
                self.timeAdded = row[timeAdded]
                self.age = row[age]
                self.sex = row[sex]
                self.heightInMeters = row[heightInMeters]
                self.weightInKilograms = row[weightInKilograms]
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed, could not load UHP: \(message), in \(String(describing: statement))")
        } catch let error {
            NSLog("could not load UHP: \(error)")
        }
        return self
    }
    
    func save() {
        self.createTable()
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let uhp = Table("UserHealthProfile")
        
        let timeAdded = Expression<Double>("timeAdded")
        let age = Expression<Int64?>("age")
        let sex = Expression<Int64?>("sex")
        let heightInMeters = Expression<Double?>("heightInMeters")
        let weightInKilograms = Expression<Double?>("weightInKilograms")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let time_now = Double(NSDate().timeIntervalSince1970)
            try db.run(uhp.insert(or: .replace,
                            timeAdded <-            time_now,
                            age <-                  self.age,
                            sex <-                  self.sex,
                            heightInMeters <-       self.heightInMeters,
                            weightInKilograms <-    self.weightInKilograms))
            
            NSLog("UserHealthProfile saved.")
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed, UHP Save failed: \(message), in \(String(describing: statement))")
        } catch let error {
            NSLog("UHP Save failed: \(error)")
        }
    }
    
    private func createTable() -> Connection? {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let uhp = Table("UserHealthProfile")
        
        let timeAdded = Expression<Double>("timeAdded")
        let age = Expression<Int64>("age")
        let sex = Expression<Int64>("sex")
        let heightInMeters = Expression<Double>("heightInMeters")
        let weightInKilograms = Expression<Double>("weightInKilograms")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            try db.run(uhp.create(ifNotExists: true) { t in     // CREATE TABLE "uhp" (
                t.column(timeAdded, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(age)
                t.column(sex)
                t.column(heightInMeters)
                t.column(weightInKilograms)
            })
            
            //NSLog("Table created successfully at: \(path)")
            return db
        } catch let error {
            NSLog("UHP table creation failed: \(error)")
            return nil
        }
    }
}


/*
class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserHealthProfile")
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { fatalError("Unresolved error \($0)") }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
} */

/*
class ProfileDataStore {
    private enum ProfileSection: Int {
        case ageSex
        case weightHeight
        case readHealthKitData
        case saveBAC
    }
    
    private let userHealthProfile = UserHealthProfile()
    
    private func loadAndDisplayAgeSexAndBloodType() {
        do {
            let userAgeAndSex = try ProfileDataStore.getAgeAndSex()
            userHealthProfile.age = userAgeAndSex.age
            userHealthProfile.sex = userAgeAndSex.sex
        } catch let error {
            //self.displayAlert(for: error)
        }
    }
    
    
    
    class func getAgeAndSex() throws -> (age: Int, sex: Bool?) {
        
        let healthKitStore = HKHealthStore()

        do {

            //1. This method throws an error if these data are not available.
            let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
            let biologicalSex =       try healthKitStore.biologicalSex()
              
            //2. Use Calendar to calculate age.
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year],
                                                                from: today)
            let thisYear = todayDateComponents.year!
            let age = thisYear - birthdayComponents.year!
             
            //3. Unwrap the wrappers to get the underlying enum values.
            let sex: Bool?
            if biologicalSex.biologicalSex.rawValue == 2 {
                sex = true
            } else if biologicalSex.biologicalSex.rawValue == 0 {
                sex = nil
            } else {
                sex = false
            }
      
            return (age, sex)
        }
    }
    
    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
      
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
            
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
            
        let limit = 1
            
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            //2. Always dispatch to the main thread when complete.
            DispatchQueue.main.async {
                
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                        
                    completion(nil, error)
                    return
                }
                
                completion(mostRecentSample, nil)
                
            }
        }
         
        HKHealthStore().execute(sampleQuery)
    }
    
    private enum ProfileDataError: Error {
      
        case missingWidmarkFactor

        var localizedDescription: String {
            switch self {
                case .missingWidmarkFactor:
                    return "Unable to calculate Widmark Factor with available profile data."
            }
        }
    }
}
*/

extension UIView {

    /// Returns a collection of constraints to anchor the bounds of the current view to the given view.
    ///
    /// - Parameter view: The view to anchor to.
    /// - Returns: The layout constraints needed for this constraint.
    func constraintsForAnchoringTo(boundsOf view: UIView) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
    }
}


extension UITextField {

    func addDoneButtonToKeyboard(action: Selector?) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: action)

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
}
