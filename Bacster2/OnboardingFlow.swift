//
//  OnboardingFlow.swift
//  Bacster2
//
//  Created by Adam Circle on 3/6/21.
//

import Foundation
import UIKit
import Lottie
import HealthKit

/*
class OBNavCon: UINavigationController {
    self
} */

class OBPage0: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        navigationController?.isNavigationBarHidden = true
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 200))
        titleLabel.text = "Welcome to BACster! We're going to get started by collecting some basic health information necessary to calculate your BAC."
        view.addSubview(titleLabel)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height - 150, width: length, height: 50))
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
        self.view.backgroundColor = .systemPink
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 200))
        titleLabel.text = "What is your sex?"
        view.addSubview(titleLabel)
        
        sexPicker = UIPickerView(frame: CGRect(x: 100, y: 400, width: view.frame.size.width - 200, height: 200))
        //sexPicker.translatesAutoresizingMaskIntoConstraints = false
        sexPicker.delegate = self as UIPickerViewDelegate
        sexPicker.dataSource = self as UIPickerViewDataSource
        view.addSubview(sexPicker)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height - 150, width: length, height: 50))
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
            profile.sex = true
        } else {
            profile.sex = false
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
        self.view.backgroundColor = .lightGray
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 200))
        titleLabel.text = "How old are you?"
        view.addSubview(titleLabel)
        
        agePicker = UIPickerView(frame: CGRect(x: 100, y: 400, width: view.frame.size.width - 200, height: 200))
        agePicker.delegate = self as UIPickerViewDelegate
        agePicker.dataSource = self as UIPickerViewDataSource
        view.addSubview(agePicker)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height - 150, width: length, height: 50))
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
        profile.age = Int(ageArray[agePicker.selectedRow(inComponent: 0)])
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
        self.view.backgroundColor = .lightGray
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 200))
        titleLabel.text = "How old are you?"
        view.addSubview(titleLabel)
        
        heightPicker = UIPickerView(frame: CGRect(x: 50, y: 400, width: view.frame.size.width - 100, height: 300))
        heightPicker.delegate = self as UIPickerViewDelegate
        heightPicker.dataSource = self as UIPickerViewDataSource
        view.addSubview(heightPicker)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height - 150, width: length, height: 50))
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
        self.view.backgroundColor = .green
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 200))
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
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height - 150, width: length, height: 50))
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
            NSLog(String(profile.weightInKilograms!))
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
        self.view.backgroundColor = .green
        
        // configure the title label
        let titleLabel = OnboardingLabel(frame: CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 200))
        titleLabel.text = "Great! We're all done!"
        view.addSubview(titleLabel)
        
        // Add success animation
        animationView = .init(name: "champagne")
        let checkmarkSize: CGFloat = animationView!.frame.size.height * 0.7
        successAnimation(size: checkmarkSize)
        
        // Add button to continue
        let length: CGFloat = self.view.frame.size.width * 0.85
        let continueButton = ContinueButton(frame: CGRect(x: self.view.frame.size.width / 2 - (length / 2), y: self.view.frame.size.height - 150, width: length, height: 50))
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        self.view.addSubview(continueButton)
    }
    
    
    func successAnimation(size: CGFloat) {
        animationView!.frame = CGRect(x: self.view.frame.size.width / 2 - size / 2 - 30, y: 125, width: size, height: size)
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
        self.backgroundColor = #colorLiteral(red: 0.5514355459, green: 0.6232073761, blue: 1, alpha: 1)
        self.layer.cornerRadius = 15
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.setTitle("Continue", for: .normal)
    }

}

class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(false, forKey: "isNewUser")
    }
    
    func setIsNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}

class UserHealthProfile {
    var age: Int?
    var sex: Bool?
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
        if sex {  // male
            return 0.62544 + 0.13664 * heightMeters - weightKG * (0.00189 + 0.002425 / pow(heightMeters, 2)) + 1 / (weightKG * (0.57986 + 2.54 * heightMeters - 0.02255 * Double(age)))
        }
        return 0.50766 + 0.11165 * heightMeters - weightKG * (0.001612 + 0.0031 / pow(heightMeters, 2)) - 1 / (weightKG * (0.62115 - 3.1665 * heightMeters))
    }
}

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
