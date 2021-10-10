//
//  ViewController.swift
//  BackgroundTimer
//
//  Created by CallumHill on 6/10/21.
//

import UIKit

class ViewController: UIViewController
{
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var resetButton: UIButton!
	
	var timerCounting:Bool = false
	var startTime:Date?
	var stopTime:Date?
	
	let userDefaults = UserDefaults.standard
	let START_TIME_KEY = "startTime"
	let STOP_TIME_KEY = "stopTime"
	let COUNTING_KEY = "countingKey"
	
	var scheduledTimer: Timer!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
		stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
		timerCounting = userDefaults.bool(forKey: COUNTING_KEY)
		
		
		if timerCounting
		{
			startTimer()
		}
		else
		{
			stopTimer()
			if let start = startTime
			{
				if let stop = stopTime
				{
					let time = calcRestartTime(start: start, stop: stop)
					let diff = Date().timeIntervalSince(time)
					setTimeLabel(Int(diff))
				}
			}
		}
	}

	@IBAction func startStopAction(_ sender: Any)
	{
		if timerCounting
		{
			setStopTime(date: Date())
			stopTimer()
		}
		else
		{
			if let stop = stopTime
			{
				let restartTime = calcRestartTime(start: startTime!, stop: stop)
				setStopTime(date: nil)
				setStartTime(date: restartTime)
			}
			else
			{
				setStartTime(date: Date())
			}
			
			startTimer()
		}
	}
	
	func calcRestartTime(start: Date, stop: Date) -> Date
	{
		let diff = start.timeIntervalSince(stop)
		return Date().addingTimeInterval(diff)
	}
	func startTimer()
	{
		scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
		setTimerCounting(true)
		startStopButton.setTitle("STOP", for: .normal)
		startStopButton.setTitleColor(UIColor.red, for: .normal)
	}
	
	@objc func refreshValue()
	{
		if let start = startTime
		{
			let diff = Date().timeIntervalSince(start)
			setTimeLabel(Int(diff))
		}
		else
		{
			stopTimer()
			setTimeLabel(0)
		}
	}
	
	func setTimeLabel(_ val: Int)
	{
		let time = secondsToHoursMinutesSeconds(val)
		let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
		timeLabel.text = timeString
	}
	
	func secondsToHoursMinutesSeconds(_ ms: Int) -> (Int, Int, Int)
	{
		let hour = ms / 3600
		let min = (ms % 3600) / 60
		let sec = (ms % 3600) % 60
		return (hour, min, sec)
	}
	
	func makeTimeString(hour: Int, min: Int, sec: Int) -> String
	{
		var timeString = ""
		timeString += String(format: "%02d", hour)
		timeString += ":"
		timeString += String(format: "%02d", min)
		timeString += ":"
		timeString += String(format: "%02d", sec)
		return timeString
	}
	
	func stopTimer()
	{
		if scheduledTimer != nil
		{
			scheduledTimer.invalidate()
		}
		setTimerCounting(false)
		startStopButton.setTitle("START", for: .normal)
		startStopButton.setTitleColor(UIColor.systemGreen, for: .normal)
	}
	
	@IBAction func resetAction(_ sender: Any)
	{
		setStopTime(date: nil)
		setStartTime(date: nil)
		timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
		stopTimer()
	}
	
	func setStartTime(date: Date?)
	{
		startTime = date
		userDefaults.set(startTime, forKey: START_TIME_KEY)
	}
	
	func setStopTime(date: Date?)
	{
		stopTime = date
		userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
	}
	
	func setTimerCounting(_ val: Bool)
	{
		timerCounting = val
		userDefaults.set(timerCounting, forKey: COUNTING_KEY)
	}
}

