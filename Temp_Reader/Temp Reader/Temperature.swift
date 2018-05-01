//
//  Temperature.swift
//  Temp Reader
//
//  Created by Christopher Weaver on 12/9/17.
//  Copyright © 2017 Christopher Weaver. All rights reserved.
//

import Foundation

struct Temperature {
    var temperature : String
    var time : Date
    var unixTime : String
    
    init(temperature : String, time : String) {
        
        let timeAsInt = Double(time)
        let convertedDate = Date(timeIntervalSince1970: timeAsInt!)
        self.time = convertedDate
        self.temperature = temperature
        self.unixTime = time
    }
}
