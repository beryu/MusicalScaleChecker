//
//  TunerViewModel.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2021/07/20.
//

import Foundation
import AudioKit

class TunerViewModel: ObservableObject {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode
    var tracker: PitchTap!
    var silence: Fader
    
    @Published var sound = SoundModel()
    
    let maxSense:Float = 1.0
    
    @Published var timer : Timer!
    @Published var reload:Bool = false
    @Published var userData = UserDataModel() {
        didSet {
            sound.changeSharpFlat(isFlat: userData.isFlat)
            if !isStopped {
                /// timerIntervalが変更された場合、リスタートして表示間隔を更新する
                start()
            }
        }
    }
    
    @Published var isStopped:Bool = false {
        didSet{
            if isStopped {
                stop()
            }else{
                start()
            }
        }
    }
    
    //@Published var rewarded:GADRewardedAd
    @Published var isAdHidden: Bool

    func update(_ frequency: Float, _ amp: Float) {
        var frequency_calc = frequency
        if maxSense * userData.slider/100.0 < amp && frequency_calc < 20000{
            sound.frequency = frequency
            while frequency_calc > Float(sound.noteFrequencies[sound.noteFrequencies.count - 1]) {   //noteFrequenciesの値までオクターブを下げていく
                frequency_calc /= 2.0
            }
            while frequency_calc < Float(sound.noteFrequencies[0]) {   //noteFrequenciesの値までオクターブを上げる
                frequency_calc *= 2.0
            }
            /* ドとレを行き来する問題
             　ドの方が近ければ/2する
            */
            if(frequency_calc > Float(sound.noteFrequencies[sound.noteFrequencies.count - 1])){
                if(fabsf(Float(sound.noteFrequencies[sound.noteFrequencies.count - 1]) - frequency_calc) > fabsf(Float(sound.noteFrequencies[0]) - frequency/2.0)){
                    frequency_calc /= 2.0
                }
            }

            var minDistance: Float = 10_000.0   //間の距離
            var index:Int = 0

            for i in 0..<sound.noteFrequencies.count {
                let distance:Float = fabsf(Float(sound.noteFrequencies[i]) - frequency_calc)   //各音程までの距離の絶対値
                if distance < minDistance { //一番小さい距離のものを記憶
                    index = i
                    minDistance = distance
                }
            }
            
            let octave:Int = Int(log2f(frequency / frequency_calc))
            
            //low,mid,hiに対応(A基準のオクターブにする
            var octaveJa:Int = octave
            if(index < 9){
                octaveJa = octave-1 //Aより小さければ1つ下のオクターブとする
            }

            var prefix:String = ""
            if(octaveJa < 2){
                //1以下のオクターブでlow
                for _ in 0...octaveJa.distance(to: 1){
                    prefix = prefix + "low" //1からの距離の回数lowをつける
                }
            }else if(octaveJa < 4){
                //3以下のオクターブでmid
                prefix = "mid" + (octaveJa-1).description   //2,3のオクターブの時、-1するだけで良い
            }else{
                for _ in 0...octaveJa-4{
                    prefix = prefix + "hi"
                }
            }
            
            let note = sound.noteNames[index] + octave.description
            
            sound.pitch = note
            sound.note = prefix + sound.noteNames[index]
            sound.noteJa = sound.scaleNames[index]
        } else {
            sound.frequency = 0
            sound.pitch = "--"
            sound.note = "--"
            sound.noteJa = "--"
        }
    }

    init() {
        mic = engine.input
        silence = Fader(mic, gain: 0)
        engine.output = silence
        
        if let date:Date = UserDefaults.standard.object(forKey: "date") as? Date {
            if let elapsedDays = Calendar.current.dateComponents([.day], from: date, to: Date()).day {
                print(elapsedDays)
                if(elapsedDays <= 5){
                    isAdHidden = true
                }else{
                    isAdHidden = false
                }
            }else{
                isAdHidden = false
            }
        }else{
            isAdHidden = false
        }

        /*
        rewarded = GADRewardedAd(adUnitID: "ca-app-pub-7957268411742512/9338028308")
        //rewarded = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313") //テスト
        rewarded.load(GADRequest()) { error in
          if let error = error {
            print("Loading failed init: \(error)")
          } else {
            print("Loading Succeeded")
          }
        }
        */
        
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                if(!self.isStopped){
                    self.update(pitch[0], amp[0])
                }
            }
        }
        
        sound.changeSharpFlat(isFlat: userData.isFlat)
    }
    
    func start() {
        do {
            try engine.start()
            tracker.start()
        } catch let err {
            //Log(err)
        }
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(userData.timerInterval), repeats: true) {_ in
            if(!self.isStopped){
                self.reload.toggle()
            }
       }
        //2回しないと起動しない
        do {
            try engine.start()
        } catch let err {
            //Log(err)
        }
        print("start")
    }

    func stop() {
        engine.stop()
        timer.invalidate()
        print("stop")
    }
}
