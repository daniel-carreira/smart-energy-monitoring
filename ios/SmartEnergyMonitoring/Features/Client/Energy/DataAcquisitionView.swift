//
//  DataAcquisitionView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import SwiftUI

struct DataAcquisitionView: View {
    @State var equipment: Equipment
    @State private var time: Int = 1 {
        didSet {
            self.timer = "\(time):00"
            self.countdown = Float(time)
        }
    }
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @State private var state: StateView = .First
    
    @State private var startDate: Double = 0.0
    @State private var endDate: Double = 0.0
    @State private var consumption = "0.00"
    @State private var timer = "0.00"
    @State private var countdown: Float = 0.0
    @State private var countdownState: StateCountdown = .ToStart
    
    @State private var requestLoading = false
    
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var mqtt: MQTTManager
    
    @Environment(\.dismiss) var dismiss
    
    enum StateView: Int, CaseIterable, Comparable {
        static func < (lhs: DataAcquisitionView.StateView, rhs: DataAcquisitionView.StateView) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        case First = 1
        case Second = 2
        case Third = 3
        case Fourth = 4
    }
    
    enum StateCountdown {
        case ToStart
        case Started
        case Stopped
        case Finished
    }
    
    func updateCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard countdownState == .Started else { return }
            
            // Gets the current date and makes the time difference calculation
            let diff = endDate - Date.now.timeIntervalSince1970
            
            // Checks that the countdown is not <= 0
            if diff <= 0 {
                timer = "0:00"
                countdownState = .Finished
                return
            }
            
            // Turns the time difference calculation into sensible data and formats it
            let date = Date(timeIntervalSince1970: diff)
            let calendar = Calendar.current
            let minutes = calendar.component(.minute, from: date)
            let seconds = calendar.component(.second, from: date)

            // Updates the time string with the formatted time
            self.countdown = Float(minutes)
            self.timer = String(format:"%d:%02d", minutes, seconds)
            
            updateCountdown()
        }
    }
    
    func submit() -> Void {
        Task {
            do {
                requestLoading = true
                var body = IndividualTrainingExamples(start: Int(startDate), end: Int(endDate), individual: true, equipments_on: [equipment.id])
                let decoded = try JSONEncoder().encode(body)
                try await TrainingExamplesService.post(userId: (session.user?.data.id)!, accessToken: session.accessToken!, parameters: decoded)
                requestLoading = false
                dismiss()
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                requestLoading = false
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                VStack {
                    List {
                        HStack {
                            Symbols.oneFill
                                .foregroundColor(.accentColor)
                            Spacer()
                            if (state < .Second) {
                                Symbols.two
                                    .foregroundColor(.accentColor)
                            }
                            else {
                                Symbols.twoFill
                                    .foregroundColor(.accentColor)
                            }
                            Spacer()
                            if (state < .Third) {
                                Symbols.three
                                    .foregroundColor(.accentColor)
                            }
                            else {
                                Symbols.threeFill
                                    .foregroundColor(.accentColor)
                            }
                            Spacer()
                            if (state < .Fourth) {
                                Symbols.four
                                    .foregroundColor(.accentColor)
                            }
                            else {
                                Symbols.fourFill
                                    .foregroundColor(.accentColor)
                            }
                        }
                        if (state == .First) {
                            Section("Info") {
                                Text("This type of tool should be used to improve the accuracy of the system. The user must use this tool by following all the steps in the order they are presented, otherwise the monitoring system's conclusions will yield false results.")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button("Let's start →") {
                                state = .Second
                            }
                        }
                        else if (state == .Second) {
                            Section("Info") {
                                Text("Please select a period of analysis (recommended between 1..5 minutes). Afterwards, be sure that the \(equipment.name) is turned OFF.")
                                    .foregroundStyle(.secondary)
                            }
                            Stepper(value: $time, in: 1...60) {
                                HStack {
                                    Text("Time: ")
                                    Text("\(time) minute(s)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Button("Next →") {
                                state = .Third
                                mqtt.publish(topic: "\(session.user!.data.id)/tare", with: "")
                                timer = "\(time):00"
                            }
                        }
                        else if (state == .Third) {
                            Section("Info") {
                                Text("Now, turn ON the \(equipment.name) and proceed.")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button("Begin analysis →") {
                                state = .Fourth
                                
                                mqtt.currentAppState.setOnReceive(callback: { topic, payload in
                                    if (topic == "\((session.user?.data.id)!)/power") {
                                        consumption = payload
                                    }
                                })
                            }
                        }
                        else if (state == .Fourth) {
                            Section("Info") {
                                HStack {
                                    Text("Time")
                                    Spacer()
                                    Text(timer)
                                        .foregroundStyle(.secondary)
                                }
                                HStack {
                                    Text("Consumption")
                                    Spacer()
                                    Text("\(consumption) W")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            switch (countdownState) {
                            case .ToStart:
                                Button(action: {
                                    countdownState = .Started
                                    startDate = Date().timeIntervalSince1970
                                    let date = Calendar.current.date(byAdding: .minute, value: time, to: Date.now)!
                                    endDate = date.timeIntervalSince1970
                                    updateCountdown()
                                }, label: {
                                    HStack {
                                        Symbols.play
                                        Text("Start")
                                    }
                                })
                                
                            case .Started:
                                Button(action: {
                                    countdownState = .ToStart
                                    startDate = Date().timeIntervalSince1970
                                    let date = Calendar.current.date(byAdding: .minute, value: time, to: Date.now)!
                                    endDate = date.timeIntervalSince1970
                                    time = time
                                }, label: {
                                    HStack {
                                        Symbols.stop
                                        Text("Stop")
                                    }
                                })
                            case .Finished:
                                Button(action: {
                                    mqtt.publish(topic: "\(session.user!.data.id)/reset", with: "")
                                    submit()
                                }, label: {
                                    HStack {
                                        Text("Save →")
                                    }
                                })
                            case .Stopped:
                                EmptyView()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Data Acquisition")
        .alert("Data post failed", isPresented: $didFail, actions: {
            Button("Ok") {
                dismiss()
            }
        }, message: {
            Text(failMessage)
        })
        .overlay(loadingOverlay)
        
    }
    
    @ViewBuilder private var loadingOverlay: some View {
        if requestLoading {
            ZStack {
                Color(white: 0, opacity: 0.75)
                ProgressView().tint(.white)
            }
        }
    }
    
}
