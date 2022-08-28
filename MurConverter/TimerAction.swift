//
//  TimerAction.swift
//  DebugCMMX
//
//  Created by Anatolii Kasianov on 09.06.2022.
//

import Foundation

class TimerAction {

    var timer = Timer()
    let timeInterval = 10.0

    init() {}

    func run() {
        if #available(macOS 10.12, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true, block: { _ in
                self.action()
            })
        } else {
            timer = Timer.scheduledTimer(
                timeInterval: timeInterval,
                target: self,
                selector: #selector(action),
                userInfo: nil,
                repeats: true
            )
        }
    }

    @objc func action() {

        DispatchQueue.global(qos: .background).async {
            //            print("This is run on the background queue")
            self.updateBuildTypeList()

            DispatchQueue.main.async {
                //                print("This is run on the main queue, after the previous code in outer block")
            }
        }
    }

    func updateBuildTypeList() {
        
    }
}
