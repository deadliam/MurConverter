//
//  Utils.swift
//  MurConverter
//
//  Created by Anatolii Kasianov on 26.08.2022.
//

import Foundation

class Utils {
    
    static func runScriptFromBundle(scriptName: String, args: [String] = [""]) -> Bool {
        let path = scriptPath(scriptName)
        let arguments = args.joined(separator: " ")
        let (output, exitCode) = Utils.executeShellCommand("\(path) \(arguments)")
        print(output)
        if output.contains("Operation not permitted") || exitCode != 0 {
            return false
        }
        return true
    }
    
    static func scriptPath(_ scriptName: String) -> String {
        let path = Bundle(for: Utils.self)
            .path(forResource: (scriptName as NSString).deletingPathExtension, ofType: (scriptName as NSString).pathExtension)!
        return path
    }
    
    @discardableResult
    static func executeShellCommand(_ input: String) -> (output: String, exitCode: Int32) {
        // Create a Task instance
        let task = Process()

        // Set the task parameters
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", input]
        task.environment = [
            "LC_ALL": "en_US.UTF-8",
            "HOME": NSHomeDirectory()
        ]

        // Create a Pipe and make the task put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        // Launch the task
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return (output, task.terminationStatus)
    }
}
