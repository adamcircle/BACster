//
//  WelcomeViewCon.swift
//  Bacster2
//
//  Created by Adam Circle on 2/26/21.
//
/*
import UIKit
import Lottie
import HealthKit

class WelcomViewCon: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    var holderView = UIView()
    let scrollView = UIScrollView()
    // var ageLabel = UITextField(frame: CGRect(x: 10, y: 400, width: pageView.frame.size.width - 20, height: 200))
    private var animationView: AnimationView?
    // let isMetric = NSLocale.current.usesMetricSystem
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func authorizeHealthkit() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
            print("HealthKit Successfully Authorized.")
        }
    }
    
    private func configure() {
        view.backgroundColor = .systemRed

        view.addSubview(holderView)
        holderView.backgroundColor = .systemGray
        holderView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [
            holderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            holderView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: holderView.bottomAnchor),
            self.view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: holderView.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        
        holderView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .blue
        constraints = [
            scrollView.topAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.leftAnchor),
            holderView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            holderView.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let titles = ["Welcome to BACster! We're going to get started by collecting some basic health information necessary to calculate your BAC.", "What is your sex?", "How old are you?", "What's your weight?", "Great! We're all done!"]
        
        for pagenum in 0..<5 {
            // configure the pages
            let pageView = UIView(frame: CGRect(x: CGFloat(pagenum) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            pageView.backgroundColor = .green
            pageView.tag = pagenum
            scrollView.addSubview(pageView)
            
            // configure the title label
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 100, width: pageView.frame.size.width - 20, height: 200))
            titleLabel.textAlignment = .center
            titleLabel.textColor = .black
            titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.numberOfLines = 0
            titleLabel.tag = pagenum
            
            
            switch pagenum {
            case 0:
                // Add title text
                titleLabel.text = titles[pagenum]
                pageView.addSubview(titleLabel)
            case 1:
                // Add title text
                titleLabel.text = titles[pagenum]
                pageView.addSubview(titleLabel)
                
                let sexPicker: UIPickerView = UIPickerView(frame: CGRect(x: 30, y: 400, width: pageView.frame.size.width - 60, height: 200))
                //sexPicker.translatesAutoresizingMaskIntoConstraints = false
                sexPicker.delegate = self as UIPickerViewDelegate
                sexPicker.dataSource = self as UIPickerViewDataSource
                pageView.addSubview(sexPicker)
                //sexPicker.center = pageView.center
            
            case 2:
                // Add title text
                titleLabel.text = titles[pagenum]
                pageView.addSubview(titleLabel)
                
                let ageLabel = UITextField(frame: CGRect(x: 10, y: 400, width: pageView.frame.size.width - 20, height: 200))
                pageView.addSubview(ageLabel)
                ageLabel.textAlignment = .center
                ageLabel.attributedPlaceholder = NSAttributedString(string: "21")
                ageLabel.clearsOnBeginEditing = true
                ageLabel.keyboardType = .numberPad
                
            case 3:
                // Add title text
                titleLabel.text = titles[pagenum]
                pageView.addSubview(titleLabel)
            default:
                let _ = 0
            }
            
            
            
            /*
            // Add success animation
            animationView = .init(name: "checkmark")
            let checkmarkSize: CGFloat = animationView!.frame.size.height * 0.9
            successAnimation(size: checkmarkSize)
             */
            
            // Add button to continue
            let continueButton = ContinueButton()
            let length: CGFloat = pageView.frame.size.width * 0.85
            continueButton.frame = CGRect(x: pageView.frame.size.width / 2 - (length / 2), y: pageView.frame.size.height - 150, width: length, height: 50)
            continueButton.setTitle("Continue", for: .normal)
            continueButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            continueButton.tag = pagenum
            pageView.addSubview(continueButton)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(titles.count) * holderView.frame.size.width, height: 0)
        scrollView.isPagingEnabled = true
    }
    
    
    private let userHealthProfile = UserHealthProfile()
    
    private func updateHealthInfo() {
        loadAgeAndSex()
        loadWeight()
        loadHeight()
    }
    
    private func loadAgeAndSex() {

    }
    
    private func loadHeight() {
        //1. Use HealthKit to create the Height Sample Type
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
          print("Height Sample Type is no longer available in HealthKit")
          return
        }
            
        ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
              
            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
              
            //2. Convert the height sample to meters, save to the profile model,
            //   and update the user interface.
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
        }
    }
    
    private func loadWeight() {
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
            
        ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
              
            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
        }

    }
    
    private func displayAlert(for error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "O.K.", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func saveBACToHealthKit() {
      
    }
    
    func successScreen() {
        self.animationView = .init(name: "checkmark")
        let size: CGFloat = animationView!.frame.size.height * 0.9
        animationView!.frame = CGRect(x: holderView.frame.size.width + (holderView.frame.size.width / 2 - size / 2), y: 125, width: size, height: size)
        animationView!.contentMode = .scaleAspectFit
        // animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 0.8
        self.holderView.addSubview(animationView!)
        animationView!.play()
        NSLog("yay")
    }
    
    @objc func didTapButton(_ button: UIButton) {
        switch button.tag {
        case 0:
            self.authorizeHealthkit()
            scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag + 1), y: 0), animated: true)
        case 1:
            //scroll to next page
            scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag + 1), y: 0), animated: true)
        case 2:
            scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag + 1), y: 0), animated: true)
            //self.ageLabel.becomeFirstResponder()
        case 3:
            scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag + 1), y: 0), animated: true)
        case 4:
            Core.shared.setIsNotNewUser()
            dismiss(animated: true, completion: {
                let tabBarCon = TabBarController()
                let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
                sceneDelegate.window?.rootViewController = tabBarCon
            })
        default:
            print("this will never print")
        }
        
    }
}




class ProfileDataStore {
    private enum ProfileSection: Int {
        case ageSex
        case weightHeight
        case readHealthKitData
        case saveBAC
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
*/
