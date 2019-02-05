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
    
    var audioFileArray: [String] = []
    
    //オーディオ関係の変数
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false
    
    //データ保存関係の変数
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
            isRecording = false
            
            //urlの文字列が入ったstringsを"stringsArray"というForKeyで保存
            userDefaults.set(audioFileArray, forKey: "stringsArray")
            userDefaults.set(url, forKey: audioFileArray.last!)
            userDefaultsIsNil = false
            userDefaults.set("太郎", forKey: "userNameForKey")
            let userName = userDefaults.string(forKey: "userNameForKey")
            print(userName)
            //初期値がtrue(userDefaultsには何も入っていない)なので、falseにしたuserDefaultsIsNilを保存する
            userDefaults.set(userDefaultsIsNil, forKey: "nilFlag")
            self.tableView.reloadData()
        }
    }
    
    func getURL() -> URL{
        //現在時刻をURL化するために必要な変数
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        //現在時刻をString型に変換して取得
        let now: String = "\(NSDate())"
        //nowをURLに変換してurlに代入
        url = docsDirect.appendingPathComponent(now)
        //そのurlを配列に追加
        urlArray.append(url!)
        //また、String型配列のaudioFileArrayに現在時刻をだ追加
        audioFileArray.append(now)
        
        return url!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isPlaying {
        
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

