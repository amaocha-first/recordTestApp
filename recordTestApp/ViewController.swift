//
//  ViewController.swift
//  recordTestApp
//
//  Created by coco j on 2019/02/01.
//  Copyright © 2019 coco j. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false
    
    var audioFileArray: [String] = []
    var url : URL?
    var urlArray: [URL] = []
    let userDefaults = UserDefaults.standard
    var userDefaultsIsNil: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults.register(defaults: ["nilFlag" : true])
        userDefaultsIsNil = userDefaults.bool(forKey: "nilFlag")

        if userDefaultsIsNil == false {
            audioFileArray = userDefaults.array(forKey: "stringsArray") as! [String]
            tableView.reloadData()
            for i in audioFileArray {
                let getURL = userDefaults.url(forKey: i)
                urlArray.append(getURL!)
                print(getURL)
            }

        } else {
            print("userdefaultsはnilだよ")
        }
        
        // ボタンのインスタンス生成
        let recordButton = UIButton()
        // ボタンの位置とサイズを設定
        recordButton.frame = CGRect(x:self.view.frame.width/2 - 32.5, y:view.frame.height/1.18,
                                    width:70, height:70)
        //ボタンの画像を設定
        let image = UIImage(named: "record.png")
        recordButton.setImage(image, for: .normal)
        // タップされたときのaction
        recordButton.addTarget(self,action: #selector(buttonTapped(sender:)),for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(recordButton)
        
    }
    
    //ボタンが押された時の処理
    @objc func buttonTapped(sender : AnyObject) {
        if !isRecording {
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try! session.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                
            ]
            
            audioRecorder = try! AVAudioRecorder(url: getURL(), settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            isRecording = true
            
        } else {
            
            audioRecorder.stop()
            print("audioRecorder was stoped!")
            isRecording = false
            
            //urlの文字列が入ったstringsを"stringsArray"というForKeyで保存
            userDefaults.set(audioFileArray, forKey: "stringsArray")
            userDefaults.set(url, forKey: audioFileArray.last!)
            userDefaultsIsNil = false
            //初期値がtrue(userDefaultsには何も入っていない)なので、falseにしたuserDefaultsIsNilを保存する
            userDefaults.set(userDefaultsIsNil, forKey: "nilFlag")
            self.tableView.reloadData()
        }
    }
    
    func getURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        //現在時刻をString型で取得
        let now: String = "\(NSDate())"
        url = docsDirect.appendingPathComponent(now)
        audioFileArray.append(now)
        urlArray.append(url!)
        return url!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isPlaying {
            //let audioFileURLArrayAnyToURL = audioFileArray[indexPath.row] as! [URL]
            

            audioPlayer = try! AVAudioPlayer(contentsOf: urlArray[indexPath.row])
            audioPlayer.delegate = self
            audioPlayer.play()
            
            isPlaying = true
            
        }else{
            
            audioPlayer.stop()
            isPlaying = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        cell!.textLabel?.text = "新規録音"
        
        return cell!
    }
    
}

