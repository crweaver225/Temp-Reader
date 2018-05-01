//
//  MainViewController.swift
//  Temp Reader
//
//  Created by Christopher Weaver on 12/9/17.
//  Copyright © 2017 Christopher Weaver. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController {

    @IBOutlet weak var choosenTempLabel: UILabel!
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let currentValue = Int(sender.value)
        choosenTempLabel.text = String(currentValue)
    }
    
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var graphView: LineGraph!
    @IBOutlet weak var temperatureView: TemperatureView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!

    var temperatureList : [Temperature] = []
    var keyID : String?
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lowTempLimit: UILabel!
    
    @IBAction func confirmNotifyButtonPushed(_ sender: Any) {
        
        setNotifyTemp(temp: self.choosenTempLabel.text!)
        
        UIView.animate(withDuration: 1, animations: {
            self.tempSlider.alpha = 0
            self.notifyConfirmButton.alpha = 0
            self.choosenTempLabel.alpha = 0
            self.highTempLimit.alpha = 1
            self.lowTempLimit.alpha = 1
            self.refreshButton.alpha = 1
            
            if let highTempSet = self.getNotifyTemp(high: true) {
                self.highTempLimit.text = "Notify me if Warmer than: \(highTempSet)"
            } else {
                self.highTempLimit.text = "Set up a high temp notificaiton"
            }
            if let lowTempSet = self.getNotifyTemp(high: false) {
                self.lowTempLimit.text = "Notify me if Colder Than: \(lowTempSet)"
            } else {
                self.lowTempLimit.text = "Set up a low temp notification"
            }
        })
        
    }
    @IBOutlet weak var notifyConfirmButton: UIButton!
    @IBAction func refreshPushed(_ sender: Any) {
        initializeTempCall()
    }
    
    @IBOutlet weak var highTempLimit: UILabel!
    var isGraphViewShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MainViewController.counterViewTap(gesture:)))
           let tapView2 = UITapGestureRecognizer(target: self, action: #selector(MainViewController.counterViewTap(gesture:)))
        self.graphView.addGestureRecognizer(tapView2)
        self.temperatureView.addGestureRecognizer(tapView)
        let notifyHighTapView = UITapGestureRecognizer(target: self, action: #selector(MainViewController.changeHighNotifiedTemp))
        let notifyLowTapView = UITapGestureRecognizer(target: self, action: #selector(MainViewController.changeLowNotifiedTemp))
        
        highTempLimit.addGestureRecognizer(notifyHighTapView)
        lowTempLimit.addGestureRecognizer(notifyLowTapView)
      
        loadPreviousData()
        
        setupGraphDisplay()
        
        if let highTempSet = getNotifyTemp(high: true) {
            highTempLimit.text = "Notify me if Warmer than: \(highTempSet)"
        } else {
            highTempLimit.text = "Set up a high temp notificaiton"
        }
        if let lowTempSet = getNotifyTemp(high: false) {
            lowTempLimit.text = "Notify me if Colder Than: \(lowTempSet)"
        } else {
            lowTempLimit.text = "Set up a low temp notification"
        }

        initializeTempCall()
    }

    func initializeTempCall() {
        getTemperatureData() { (temperature) in
       
            if let serverTemperatureList = temperature {
                
                self.saveNewTemperatureData(temperatureData: serverTemperatureList)
                
                let tempSingle = serverTemperatureList.last?.temperature
                
                DispatchQueue.main.async {
                    
                    for tempSingleton in serverTemperatureList {
                        self.temperatureList.append(tempSingleton)
                    }
                    
                    self.lastUpdatedLabel.text = "Last Updated: \(self.convertDateToString(date: (serverTemperatureList.last?.time)!)!)"
                    self.temperatureLabel.text = tempSingle
                    self.temperatureView.counter = Double(tempSingle!)!
                }
            }
        }
    }
    
    @objc func changeHighNotifiedTemp() {
        UIView.animate(withDuration: 1, animations: {
            self.choosenTempLabel.alpha = 1
            self.notifyConfirmButton.alpha = 1
            self.tempSlider.alpha = 1
            self.refreshButton.alpha  = 0
            self.lowTempLimit.alpha = 0
        })
        if let choosenTemp = getNotifyTemp(high: false) {
            choosenTempLabel.text = String(choosenTemp)
        } else {
            choosenTempLabel.text = "0"
        }
    }
    
    @objc func changeLowNotifiedTemp() {
         UIView.animate(withDuration: 1, animations: {
            self.choosenTempLabel.alpha = 1
            self.highTempLimit.alpha = 0
            self.notifyConfirmButton.alpha = 1
            self.tempSlider.alpha = 1
            self.refreshButton.alpha = 0
         })
        if let choosenTemp = getNotifyTemp(high: false) {
            let choosenTempFloat : Float = Float(choosenTemp)!
        
            self.tempSlider.setValue(choosenTempFloat, animated: false)
            choosenTempLabel.text = String(choosenTemp)
        } else {
            choosenTempLabel.text = "20"
        }
    }
    
    func setNotifyTemp(temp : String) {
        var lowTemp : Bool?
        let sql = SQL()
        if lowTempLimit.alpha == 1 {
            lowTemp = true
        } else {
            lowTemp = false
        }
        if let keyID = self.keyID {
            
            if lowTemp! {
                let query = "update limit_values set lowLimit = \(temp) where key_id = '\(keyID)'"
                sql.updateDatabase(query)
            } else {
                let query = "update limit_values set highLimit = \(temp) where key_id = '\(keyID)'"
                sql.updateDatabase(query)
            }
            
            sendTempLimitToPi(keyID: keyID, lowTemp: getNotifyTemp(high: false)!, highTemp: getNotifyTemp(high: true)!)
        }
    }
    
    func sendTempLimitToPi(keyID : String, lowTemp : String, highTemp : String) {

        let url = URL(string: "http://192.168.1.12/setNotifyTemperature?kId=\(keyID)&highTemp=\(highTemp)&lowTemp=\(lowTemp)")

        let urlReq = URLSession.shared.dataTask(with: url!)
        urlReq.resume()
    }
    
    func getNotifyTemp(high : Bool) -> String? {

        var highValue : String?
        var lowValue : String?
        let sql = SQL()
        let query = "select * from limit_values"
        let rows = sql.getRows(query, directory: nil)
        
        for row in rows {
            if let highTemp = row["highLimit"] as? String {
                highValue = highTemp
            }
            if let lowTemp = row["lowLimit"] as? String{
                lowValue = lowTemp
            }
            if let keyID = row["key_id"] as? String {
                self.keyID = keyID
            }
        }
        if high {
            return highValue
        } else {
            return lowValue
        }
    }
    
    func saveNewTemperatureData( temperatureData : [Temperature]) {
      
        let sql = SQL()
        
        for temperatureDataPoint in temperatureData {
            
            let temperature = temperatureDataPoint.temperature
            let time = temperatureDataPoint.unixTime
            let keyId = UUID.init().uuidString
            let query = "insert into temperature_log (key_id, temperature, time) values ('\(keyId)', '\(temperature)', '\(time)')"
            sql.updateDatabase(query)
        }
    }
    
    func convertDateToString( date : Date) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        
        let myString = formatter.string(from: date)
        
        return myString
    }
    
    @objc func counterViewTap(gesture:UITapGestureRecognizer?) {
        
        if (isGraphViewShowing) {
            
            //hide Graph
            UIView.transition(from: graphView,
                              to: temperatureView,
                              duration: 1.0,
                              options: [.transitionFlipFromLeft, .showHideTransitionViews],
                              completion:nil)
        } else {
            
            //show Graph
            setupGraphDisplay()
            UIView.transition(from: temperatureView,
                              to: graphView,
                              duration: 1.0,
                              options: [.transitionFlipFromLeft, .showHideTransitionViews],
                              completion:nil)
        }
        isGraphViewShowing = !isGraphViewShowing
    }
    
    func setupGraphDisplay() {
        
        if !self.temperatureList.isEmpty {
            let lastTenDataPoints = self.temperatureList.suffix(from:  self.temperatureList.count - 15)
            
            graphView.startDate = convertDateToString(date: (lastTenDataPoints.first?.time)!)
            graphView.endDate = convertDateToString(date: (lastTenDataPoints.last?.time)!)
            
            for tempString in lastTenDataPoints {
                
                let tempInt = Double(tempString.temperature)
                
                graphView.graphPoints.append(tempInt!)
            }
        }
    }
    
    func loadPreviousData() {

        let query = "select * from temperature_log order by time"
        
        let sql = SQL()
        let rows = sql.getRows(query, directory: nil)
        
        for row in rows {
            
            if let temperatureData = row["temperature"] as? String {
                if let timeData = row["time"] as? String {
                    let temperature = Temperature(temperature: temperatureData, time: timeData)
                    temperatureList.append(temperature)
                }
            }
            
            DispatchQueue.main.async {
                let tempSingle = self.temperatureList.last?.temperature
                self.lastUpdatedLabel.text = "Last Updated: \(self.convertDateToString(date: (self.temperatureList.last?.time)!)!)"
                self.temperatureLabel.text = tempSingle
                self.temperatureView.counter = Double(tempSingle!)!
            }
        }
    }

    func getTemperatureData(completionHandler : @escaping (_ temperatureList : [Temperature]?) -> Void) {

        var startUnixEpochTime = "0"
        if !self.temperatureList.isEmpty {
            startUnixEpochTime = (self.temperatureList.last?.unixTime)!
        }
        
        let url = URL(string: "http://192.168.1.12/readTemperature?lastTimeDate=\(startUnixEpochTime)")
        
        let urlRequest = URLSession.shared.dataTask(with: url!) { (data, response, error) in

            if let data = data {
                
                do {
                    
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject]
                 
                    var tempArray = [Temperature]()
                    
                    for temp in jsonSerialized! {
                        
                        if let temperatureData = temp["temperature"] as? String {
                            if let timeData = temp["time"] as? String {
                                
                                let temperature = Temperature(temperature: temperatureData, time: timeData)
                                tempArray.append(temperature)
                            }
                        }
                    }
                    
                    completionHandler(tempArray)
                    
                } catch {
                    print("failed to serialize data")
                    completionHandler(nil)
                }
            }
        }
        urlRequest.resume()
        
    }


}
