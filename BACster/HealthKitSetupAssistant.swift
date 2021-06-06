//
//  HealthKitSetupAssistant.swift
//  Bacster2
//
//  Created by Adam Circle on 2/28/21.
//

import HealthKit

class HealthKitSetupAssistant {
  
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
  
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        //1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
          completion(false, HealthkitSetupError.notAvailableOnDevice)
          return
        }
        
        //2. Prepare the data types that will interact with HealthKit
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let bac = HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)
        else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = [bac]
            
        let healthKitTypesToRead: Set<HKObjectType> = [bac,
                                                       dateOfBirth,
                                                       biologicalSex,
                                                       height,
                                                       bodyMass]
        
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
          completion(success, error)
        }

    }
}

