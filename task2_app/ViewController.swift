//
//  ViewController.swift
//  task2_app
//
//  Created by Nazlıcan Çay on 28.08.2023.
//


import UIKit
import UserNotifications
import AVFoundation



class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    var audioPlayer: AVAudioPlayer?
    var volume: Float = 0.1
    var timePicker: UIDatePicker!

       
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Create time picker
                timePicker = UIDatePicker()
                timePicker.preferredDatePickerStyle = .inline
                timePicker.datePickerMode = .time
                timePicker.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: 200)
                self.view.addSubview(timePicker)

                // Create Set Alarm button
                let setAlarmButton = UIButton(frame: CGRect(x: 0, y: 260, width: self.view.frame.width, height: 50))
                setAlarmButton.setTitle("Set Alarm", for: .normal)
                setAlarmButton.backgroundColor = .blue
                setAlarmButton.addTarget(self, action: #selector(setAlarm(_:)), for: .touchUpInside)
                self.view.addSubview(setAlarmButton)
            }

            @objc func setAlarm(_ sender: UIButton) {
                let selectedTime = timePicker.date
                scheduleNotification(at: selectedTime)
                print("Alarm set")
            }
    func scheduleNotification(at date: Date) {
        let calendar = Calendar.current
        
        // Break the date into components
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        // Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create the content
        let content = UNMutableNotificationContent()
        content.title = "Wake up!"
        content.body = "Time to wake up!"
        content.sound = UNNotificationSound.default
        
        // Create the request
        let request = UNNotificationRequest(identifier: "AlarmNotification", content: content, trigger: trigger)
        
        // Schedule the request
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(components)")
            }
        }
    }

    
   
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
            playAlarmSound()
            
            // Show an alert to stop music
            let alert = UIAlertController(title: "Alarm", message: "Stop Music?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Stop", style: .default, handler: { _ in
                self.audioPlayer?.stop()
            }))
            
            // Show the alert
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(alert, animated: true, completion: nil)
            }
            
            completionHandler()
        }
    func playAlarmSound() {
            guard let url = Bundle.main.url(forResource: "AlarmSound", withExtension: "mp3") else { return }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = volume
                audioPlayer?.play()
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    self.volume += 0.05
                    self.audioPlayer?.volume = self.volume
                    
                    if self.volume >= 1.0 {
                        timer.invalidate()
                    }
                }
            } catch {
                print("Audio could not be played.")
            }
        }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Request permission to display alerts and play sounds.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied because: \(String(describing: error?.localizedDescription)).")
            }
        }
        return true
    }



}

