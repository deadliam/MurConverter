//
//  QuotesViewController.swift
//  MurConverter
//
//  Created by Anatolii Kasianov on 26.08.2022.
//

import Foundation
import AppKit

class SettingsViewController: NSViewController {
    
    var filesFormat: String?
    var maxSize: Int?
    var imageHight: Int?
    var imageWidth: Int?
    var filesPath: String?
    
    @IBOutlet var dropHereLabel: NSTextField!
    @IBOutlet var rawImagesPathLabel: NSTextField!
    @IBOutlet var rawImagesPathTitleLabel: NSTextField!
    
    @IBOutlet var filesFormatComboBox: NSComboBox!
    @IBOutlet var filesFormatLabel: NSTextField!
    
    @IBOutlet var maxSizeTextField: NSTextField!
    @IBOutlet var maxSizeLabel: NSTextField!
    
    @IBOutlet var imageHightTextField: NSTextField!
    @IBOutlet var imageHightLabel: NSTextField!
    
    @IBOutlet var imageWidthTextField: NSTextField!
    @IBOutlet var imageWidthLabel: NSTextField!
    
    @IBOutlet var convertButton: NSButton!
    @IBOutlet var resultLabel: NSTextField!
    
    @IBOutlet var errorLabel: NSTextField!
    
    @IBOutlet var progressIndicatior: NSProgressIndicator!
  
    @IBOutlet var dropView: DropView!
    
    enum FilesExtensions: String {
        case jpeg
        case png
    }
    
    enum MCErrorType: String {
        case MCErrorFilesPathIsRequired = "Files path is required. Drop folder"
        case MCErrorFilesExtensionIsRequired = "Error! Extension is required"
        case MCErrorFileFormatHasNoCompression = "Error! Leave max size field empty"
        case MCErrorFilesPathDoesntExist = "Error! Files path doesn't exist"
        case MCErrorUnknown = "Something went wrong :("
    }
    
    func setupUI() {
        progressIndicatior.isHidden = true
        progressIndicatior.isIndeterminate = true
        progressIndicatior.style = .spinning
        
        resultLabel.isHidden = true
        convertButton.bezelColor = .systemGray
        dropHereLabel.isHidden = false
        errorLabel.isHidden = true
        rawImagesPathLabel.isHidden = true
        rawImagesPathTitleLabel.isHidden = true
        filesFormatComboBox.selectItem(at: 0)
        convertButton.bezelColor = .systemGray
        rawImagesPathLabel.stringValue = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        dropView.onDrop = { [weak self] path in
            self?.storeDropFilesPath(path: path)
        }
    }
    
    func collectData() -> Bool {
        
        errorLabel.isHidden = true
        
        guard let format = filesFormatComboBox.selectedCell() else {
            printError(error: MCErrorType.MCErrorFilesExtensionIsRequired.rawValue)
            return false
        }
        filesFormat = format.title
        if filesFormat == "jpg" {
            filesFormat = "jpeg"
        }
        
        maxSize = maxSizeTextField.integerValue
        if filesFormat != FilesExtensions.jpeg.rawValue && maxSize != 0 {
            printError(error: MCErrorType.MCErrorFileFormatHasNoCompression.rawValue)
            return false
        }
        
        if filesPath == nil || filesPath == "" {
            printError(error: MCErrorType.MCErrorFilesPathIsRequired.rawValue)
            return false
        }
        
        imageHight = imageHightTextField.integerValue
        imageWidth = imageWidthTextField.integerValue
        
        return true
    }
    
    func storeDropFilesPath(path: String) {
        filesPath = path
        rawImagesPathLabel.isHidden = false
        rawImagesPathLabel.stringValue = path
        rawImagesPathTitleLabel.isHidden = false
        dropHereLabel.isHidden = true
    }
}

extension SettingsViewController {
  // MARK: Storyboard instantiation
    static func freshController() -> SettingsViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("SettingsViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? SettingsViewController else {
            fatalError("Why cant i find SettingsViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

// MARK: Actions

extension SettingsViewController {

    @IBAction func convert(_ sender: NSButton) {
        
        resultLabel.isHidden = true
        
        if !collectData() {
            return
        }
        
        progressIndicatior.isHidden = false
        progressIndicatior.startAnimation(nil)
        
        let result = performConvert()
        
        if result {
            sender.bezelColor = .green
            resultLabel.isHidden = false
            resultLabel.stringValue = "Done"
        } else {
            sender.bezelColor = .red
            printError(error: MCErrorType.MCErrorUnknown.rawValue)
        }
        
        progressIndicatior.isHidden = true
        progressIndicatior.stopAnimation(nil)
    }
    
    func printError(error: String) {
        errorLabel.isHidden = false
        errorLabel.textColor = .red
        errorLabel.stringValue = error
    }
    
    enum Keys: String {
        case sourceDir = "--source-dir"
        case size = "--size"
        case format = "--format"
        case hight = "--hight"
        case width = "--width"
    }
    
    func composeArguments() -> [String] {
        var args: [String] = []
        
        guard let format = filesFormat else {
            return []
        }
        args.append(Keys.format.rawValue)
        args.append(format)
        
        guard var path = filesPath else {
            return []
        }
        args.append(Keys.sourceDir.rawValue)
        path = path.replacingOccurrences(of: " ", with: "%%%")
        args.append("\(path)")
        
        if let size = maxSize {
            if size != 0 {
                args.append(Keys.size.rawValue)
                args.append("\(size)")
            }
        }
        
        if let hight = imageHight {
            if hight != 0 {
                args.append(Keys.hight.rawValue)
                args.append("\(hight)")
            }
        }
        
        if let width = imageWidth {
            if width != 0 {
                args.append(Keys.width.rawValue)
                args.append("\(width)")
            }
        }
        
        return args
    }
    
    func performConvert() -> Bool {
        let arguments = composeArguments()
        return Utils.runScriptFromBundle(scriptName: "convert.sh", args: arguments)
    }
}
