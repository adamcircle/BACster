//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue
        
    
    }
    
    func calculateWeightKilograms(weightInLbs:Float) -> Float {
        return weightInLbs / 2.205
    }

    func calculateHeightMeters(heightInInches:Float) -> Float {
        return heightInInches / 39.37
    }

    func calculateWeightLbs(weightInKgs:Float) -> Float {
        return weightInKgs * 2.205
    }

    func calculateHeightInches(heightInMeters:Float) -> Float {
        return heightInMeters * 39.37
    }

    func calculateWidmarkFactorMale(heightMeters:Float, weightKG:Float, age:Float) -> Float {
        // Source: Posey et al. 2006. DOI: 10.1385/Forensic Sci. Med. Pathol.:3:1:33, page 35
        return 0.62544 + 0.13664 * heightMeters - weightKG * (0.00189 + 0.002425 / (heightMeters * heightMeters)) + 1 / (weightKG * (0.57986 + 2.54 * heightMeters - 0.02255 * age))
    }

    func calculateWidmarkFactorFemale(heightMeters:Float, weightKG:Float) -> Float {
        // Source: Posey et al. 2006. DOI: 10.1385/Forensic Sci. Med. Pathol.:3:1:33, page 35
        return 0.50766 + 0.11165 * heightMeters - weightKG * (0.001612 + 0.0031 / (heightMeters * heightMeters)) - 1 / (weightKG * (0.62115 - 3.1665 * heightMeters))
    }
    /*
    func calculateCurrentBAC(someDateObj) {
        let timeDiff = getTimeDifferenceBetweenDateObjectsInMinutes(someDateObj, getTimeOfFirstDrinkAsDateObject())
        let bac = 0
        for (; timeDiff >= 0; )
            bac += increaseBACEveryMinute(someDateObj, timeDiff),
            bac -= reduceBACEveryMinute(bac),
            timeDiff--;
        return bac
    }
    
    function getTimeDifferenceBetweenDateObjectsInMinutes(someDateObj, t) {
        return Math.round((someDateObj.getTime() - t.getTime()) / 6e4)
    }
    
    function increaseBACEveryMinute(someDateObj, timeDiff) {
        let o = 0;
        let someDateObj = setDateObjectSecondsAndMillisecondsToZero(new Date(someDateObj.getTime() - 6e4 * timeDiff));
        return drinksConsumed.forEach(someDateObj=>{
            let timeDiff = getTimeDifferenceBetweenDateObjectsInMinutes(someDateObj, someDateObj.drinkConsumedTimeAsDateObject);
            timeDiff >= 0 && someDateObj.drinkFullyAbsorbedTimeAsDateObject >= i && (o += calculateBACToAdd(e, t))
        }
        ),
        o
    }
     */
}

