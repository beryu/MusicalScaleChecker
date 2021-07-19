//
//  ChartView.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2020/10/23.
//

import Foundation
import SwiftUI
import Swift
import Charts

struct ChartView: UIViewRepresentable{
    let maxDataSize:Int = 500
    
    var freq:Float
    var reload:Bool
    
    var isFlat:Bool
    
    var noteNames:[String] = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    var scaleNames:[String] = ["ド", "ド#", "レ", "レ#", "ミ", "ファ", "ファ#", "ソ", "ソ#", "ラ", "ラ#", "シ"]
    var noteNamesF:[String] = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    var scaleNamesF:[String] = ["ド", "レ♭", "レ", "ミ♭", "ミ", "ファ", "ソ♭", "ソ", "ラ♭", "ラ", "シ♭", "シ"]
    
    func makeUIView(context: Context) -> some UIView {
        let chartView = LineChartView()
        var rawData: [Int] = []
        for i in 0...maxDataSize {
            rawData.append(50)
        }
        let entries = rawData.enumerated().map { ChartDataEntry(x: Double($0.offset), y: Double($0.element)) }
        let dataSet = LineChartDataSet(entries: entries)
        dataSet.drawValuesEnabled = false
        dataSet.colors = [UIColor(hex:"D06969")]
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 2
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        
        chartView.noDataText = ""
        // X軸のラベルを非表示
        chartView.xAxis.enabled = false
        // X軸の線、グリッドを非表示にする
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        // 右側のY座標の設定
        chartView.rightAxis.enabled = true
        chartView.rightAxis.drawAxisLineEnabled = false
        if(!isFlat){
            chartView.rightAxis.valueFormatter = YRightAxisValueFormatter(noteNames: noteNames, scaleNames: scaleNames)
        }else{
            chartView.rightAxis.valueFormatter = YRightAxisValueFormatter(noteNames: noteNamesF, scaleNames: scaleNamesF)
        }
        chartView.rightAxis.labelTextColor = .systemGray
        chartView.rightAxis.axisMinimum = 0.0
        chartView.rightAxis.labelTextColor = UIColor(hex: "D9D9D9")
        chartView.rightAxis.drawGridLinesEnabled = false
        //左側のY座標の設定
        chartView.leftAxis.enabled = true
        chartView.leftAxis.drawAxisLineEnabled = false
        if(!isFlat){
            chartView.leftAxis.valueFormatter = YLeftAxisValueFormatter(noteNames: noteNames, scaleNames: scaleNames)
        }else{
            chartView.leftAxis.valueFormatter = YLeftAxisValueFormatter(noteNames: noteNamesF, scaleNames: scaleNamesF)
        }
        chartView.leftAxis.labelTextColor = .systemGray
        chartView.leftAxis.axisMinimum = 0.0
        chartView.leftAxis.labelTextColor = UIColor(hex: "D9D9D9")
        chartView.leftAxis.drawGridLinesEnabled = false
        
        //凡例を非表示
        chartView.legend.enabled = false
        //拡大禁止
        chartView.highlightPerTapEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.dragEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.leftAxis.axisMaximum = 100.0
        
        return chartView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let chartView:LineChartView = uiView as! LineChartView
        let dataSet = chartView.data?.dataSets[0]
        guard let lastEntry:ChartDataEntry = (dataSet?.entryForIndex(dataSet!.entryCount-1)) else {return}
        let entry:ChartDataEntry = ChartDataEntry(x: lastEntry.x+1, y: Double(freq))
        chartView.data?.addEntry(entry, dataSetIndex: 0)
        if(chartView.data!.dataSets[0].entryCount >= maxDataSize){
            chartView.xAxis.axisMinimum = (dataSet?.entryForIndex(0)!.x)!+1
            chartView.leftAxis.axisMaximum = dataSet!.yMax < 100 ? 100.0 : dataSet!.yMax
            chartView.rightAxis.axisMaximum = chartView.leftAxis.axisMaximum
            chartView.data?.dataSets[0].removeEntry(x: 0)
        }
        
        if(!isFlat){
            chartView.rightAxis.valueFormatter = YRightAxisValueFormatter(noteNames: noteNames, scaleNames: scaleNames)
        }else{
            chartView.rightAxis.valueFormatter = YRightAxisValueFormatter(noteNames: noteNamesF, scaleNames: scaleNamesF)
        }
        if(!isFlat){
            chartView.leftAxis.valueFormatter = YLeftAxisValueFormatter(noteNames: noteNames, scaleNames: scaleNames)
        }else{
            chartView.leftAxis.valueFormatter = YLeftAxisValueFormatter(noteNames: noteNamesF, scaleNames: scaleNamesF)
        }
        
        chartView.notifyDataSetChanged()
    }

}

//Y軸のラベルを変換
class YLeftAxisValueFormatter: IAxisValueFormatter {
    let noteFrequencies:[Float] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNames:[String]
    var scaleNames:[String]
    
    init(noteNames:[String], scaleNames:[String]){
        self.noteNames = noteNames
        self.scaleNames = scaleNames
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if(value == 0){ return "" }
        var frequency:Float = Float(value)  //Floatに変換
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
        
        let octave:Int = Int(log2f(Float(value) / frequency))
        
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
        let freq:String = String(format: "%4d", Int(value))
        /*
        let note = noteNames[index] + octave.description
        let freq:String = String(format: "%4d", Int(tracker.frequency))
        
        scaleText.text = scaleNames[index]
        noteJaText.text = prefix + noteNames[index]
        noteText.text = note
        freqText.text = freq + "Hz"
         */
        return prefix + noteNames[index]
    }
}

class YRightAxisValueFormatter: IAxisValueFormatter {
    let noteFrequencies:[Float] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNames:[String]
    var scaleNames:[String]
    
    init(noteNames:[String], scaleNames:[String]){
        self.noteNames = noteNames
        self.scaleNames = scaleNames
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if(value == 0){ return "" }
        var frequency:Float = Float(value)  //Floatに変換
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
        
        let octave:Int = Int(log2f(Float(value) / frequency))
        
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
        let freq:String = String(format: "%4d", Int(value))
        /*
        let note = noteNames[index] + octave.description
        let freq:String = String(format: "%4d", Int(tracker.frequency))
        
        scaleText.text = scaleNames[index]
        noteJaText.text = prefix + noteNames[index]
        noteText.text = note
        freqText.text = freq + "Hz"
         */
        return freq + "Hz"
    }
}
