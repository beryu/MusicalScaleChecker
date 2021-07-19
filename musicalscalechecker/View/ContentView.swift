//
//  ContentView.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2020/10/23.
//

import SwiftUI
import AudioKit
import StoreKit
import GoogleMobileAds

class TunerConductor: ObservableObject {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode
    var tracker: PitchTap!
    var silence: Fader
    
    let noteFrequencies:[Float] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    var noteNames:[String] = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    var scaleNames:[String] = ["ド", "ド#", "レ", "レ#", "ミ", "ファ", "ファ#", "ソ", "ソ#", "ラ", "ラ#", "シ"]
    
    @Published var isFlat:Bool = false {
        didSet{
            UserDefaults.standard.set(isFlat, forKey: "isFlat")
            changeSharpFlat()
        }
    }
    
    @Published var frequency:Float = 0
    @Published var freq:Float = 0
    
    @Published var slider:Float = 0 {
        didSet{
            UserDefaults.standard.set(slider, forKey: "slider")
        }
    }
    
    @Published var pitch:String = "--"
    @Published var note:String = "--"
    @Published var noteJa:String = "--"
    
    let maxSense:Float = 1.0
    
    @Published var timer : Timer!
    @Published var reload:Bool = false
    @Published var timerInterval: Float = 0.005 {
        didSet{
            UserDefaults.standard.set(timerInterval, forKey: "timer")
            if(!isStopped){
                self.start()
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
    
    func changeSharpFlat(){
        if(isFlat){
            noteNames = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
            scaleNames = ["ド", "レ♭", "レ", "ミ♭", "ミ", "ファ", "ソ♭", "ソ", "ラ♭", "ラ", "シ♭", "シ"]
        }else{
            noteNames = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
            scaleNames = ["ド", "ド#", "レ", "レ#", "ミ", "ファ", "ファ#", "ソ", "ソ#", "ラ", "ラ#", "シ"]
        }
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        if maxSense * slider/100.0 < amp && pitch < 20000{
            freq = pitch
            var frequency:Float = Float(pitch)  //Floatに変換
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {   //noteFrequenciesの値までオクターブを下げていく
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {   //noteFrequenciesの値までオクターブを上げる
                frequency *= 2.0
            }
            /* ドとレを行き来する問題
             　ドの方が近ければ/2する
            */
            if(frequency > Float(noteFrequencies[noteFrequencies.count - 1])){
                if(fabsf(Float(noteFrequencies[noteFrequencies.count - 1]) - frequency) > fabsf(Float(noteFrequencies[0]) - frequency/2.0)){
                    frequency /= 2.0
                }
            }

            var minDistance: Float = 10_000.0   //間の距離
            var index:Int = 0

            for i in 0..<noteFrequencies.count {
                let distance:Float = fabsf(Float(noteFrequencies[i]) - frequency)   //各音程までの距離の絶対値
                if distance < minDistance { //一番小さい距離のものを記憶
                    index = i
                    minDistance = distance
                }
            }
            
            let octave:Int = Int(log2f(Float(pitch) / frequency))
            
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
            
            let note = noteNames[index] + octave.description
            
            self.pitch = note
            self.note = prefix + noteNames[index]
            self.noteJa = scaleNames[index]
        } else {
            freq = 0
            self.pitch = "--"
            self.note = "--"
            self.noteJa = "--"
        }
    }

    init() {
        UserDefaults.standard.register(defaults: ["isFlat" : false, "slider" : 0, "timer" : 0.005])
        isFlat = UserDefaults.standard.bool(forKey: "isFlat")
        slider = UserDefaults.standard.float(forKey: "slider")
        timerInterval = UserDefaults.standard.float(forKey: "timer")
        
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
        
        changeSharpFlat()
    }
    
    func start() {
        do {
            try engine.start()
            tracker.start()
        } catch let err {
            Log(err)
        }
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerInterval), repeats: true) {_ in
            if(!self.isStopped){
                self.frequency = self.freq
                self.reload.toggle()
            }
       }
        //2回しないと起動しない
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
        print("start")
    }

    func stop() {
        engine.stop()
        timer.invalidate()
        print("stop")
    }
}

struct ContentView: View {
    @ObservedObject var conductor = TunerConductor()
    @State var isPresentedSubView = false
    @State var navBarHidden:Bool = true
    
    var body: some View {
        NavigationView{
            ZStack{
                Color(hex: "262626")
                    .edgesIgnoringSafeArea(.all)
                
                HStack{
                    Spacer()
                    VStack{
                        NavigationLink(destination: SettingView(isFlat: $conductor.isFlat, timerInterval: $conductor.timerInterval, navBarHidden: $navBarHidden, isAdHidden: $conductor.isAdHidden)){
                            Image("setting")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color.gray)
                                .padding()
                        }
                        /*
                        if !conductor.isAdHidden {
                            NavigationLink(destination: SettingView(isFlat: $conductor.isFlat, timerInterval: $conductor.timerInterval, navBarHidden: $navBarHidden, rewarded: $conductor.rewarded, isAdHidden: $conductor.isAdHidden)){
                                Image("NoAd")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color.gray)
                                    .padding()
                            }
                        }
                        */
                        Spacer()
                    }
                }
                VStack{
                    ZStack{
                        HStack{
                            VStack{
                                Slider(value: $conductor.slider, in: 0...100, step: 1)
                                    .accentColor(Color(hex: "D06969"))
                                    .frame(width: 200)
                                HStack{
                                    Spacer()
                                    Text("マイク感度: \(Int(100-conductor.slider), specifier: "%3d")%")
                                        .font(.custom("komorebi-gothic", size: 10))
                                        .foregroundColor(Color(hex: "D9D9D9"))
                                        .rotationEffect(.degrees(-180.0), anchor: .center)
                                }
                                .frame(width: 200)
                            }
                            .rotationEffect(.degrees(-90.0), anchor: .topLeading)
                            .padding(.leading, 35)
                            .offset(x: -100, y: 100)
                        }
                        VStack{
                            Text("\(conductor.pitch)")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text("\(conductor.note)")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text("\(conductor.noteJa)")
                                .font(.custom("komorebi-gothic", size: 100))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text("\(Int(conductor.frequency), specifier: "%4d")Hz")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text(conductor.isStopped ? "Stopped" : "       ")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "FA8383"))
                                .padding()
                        }
                    }
                    .padding(.top)
                    ChartView(freq: conductor.frequency, reload: conductor.reload, isFlat: conductor.isFlat)
                        .padding(.top)
                    if !conductor.isAdHidden {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            AdView()
                                .frame(height: 90)
                        }else{
                            AdView()
                                .frame(height: 60)
                        }
                    }
                }
            }
            .onTapGesture(){
                conductor.isStopped.toggle()
            }
            .onAppear(){
                conductor.start()
                navBarHidden = true
                //n回に1回レビューを促す
                UserDefaults.standard.register(defaults: ["slider" : 0.0, "count" : 1])
                let count:Int = UserDefaults.standard.integer(forKey: "count")
                UserDefaults.standard.setValue(count+1, forKey: "count")
                if count%15 == 0 {
                    SKStoreReviewController.requestReview()
                }
            }
            .onDisappear(){
                conductor.stop()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                conductor.start()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(navBarHidden)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
