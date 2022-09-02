//
//  QuotesViewController.swift
//  MurConverter
//
//  Created by Anatolii Kasianov on 26.08.2022.
//

import Foundation
import AppKit
import CoreImage

class SettingsViewController: NSViewController {
    
    var filesFormat: String?
    var maxSize: Int?
    var imageHeight: Int?
    var imageWidth: Int?
    var filesPaths: [String]?
    
    let rawImagesPathTitleDefaultValue = "Images: "
    
    @IBOutlet var dropHereLabel: NSTextField!
    @IBOutlet var rawImagesPathLabel: NSTextField!
    @IBOutlet var rawImagesPathTitleLabel: NSTextField!
    
    @IBOutlet var filesFormatComboBox: NSComboBox!
    @IBOutlet var filesFormatLabel: NSTextField!
    
    @IBOutlet var maxSizeTextField: NSTextField!
    @IBOutlet var maxSizeLabel: NSTextField!
    
    @IBOutlet var imageHeightTextField: NSTextField!
    @IBOutlet var imageHeightLabel: NSTextField!
    
    @IBOutlet var imageWidthTextField: NSTextField!
    @IBOutlet var imageWidthLabel: NSTextField!
    
    @IBOutlet var convertButton: NSButton!
    @IBOutlet var resultLabel: NSTextField!
    
    @IBOutlet var grayscaleCheckbox: NSButton!
    @IBOutlet var sepiaCheckbox: NSButton!
    @IBOutlet var blurComboBox: NSComboBox!
    
    @IBOutlet var errorLabel: NSTextField!
    
    @IBOutlet var progressIndicatior: NSProgressIndicator!
  
    @IBOutlet var dropView: DropView!
    
    enum FilesExtensions: String {
        case jpeg
        case png
    }
    
    enum ActionButtonStates: String {
        case readyToConvert = "Convert"
        case convertProcessing = "Converting..."
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
        
        grayscaleCheckbox.setButtonType(.switch)
        grayscaleCheckbox.state = .off
        
        sepiaCheckbox.setButtonType(.switch)
        sepiaCheckbox.state = .off
        
        blurComboBox.selectItem(at: 0)
        
        resultLabel.isHidden = true
        convertButton.bezelColor = .systemGray
        dropHereLabel.isHidden = false
        errorLabel.isHidden = true
        rawImagesPathLabel.isHidden = true
        
        rawImagesPathTitleLabel.isHidden = true
        filesFormatComboBox.selectItem(at: 0)

        convertButton.bezelColor = .systemGray
        convertButton.setButtonType(.momentaryChange)
        convertButton.title = ActionButtonStates.readyToConvert.rawValue
        
        rawImagesPathLabel.stringValue = ""
        rawImagesPathTitleLabel.stringValue = rawImagesPathTitleDefaultValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        dropView.onDrop = { [weak self] paths in
            self?.storeDropFilesPath(paths: paths)
            self?.resultLabel.isHidden = true
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
        
        if filesPaths == nil || filesPaths?[0] == "" {
            printError(error: MCErrorType.MCErrorFilesPathIsRequired.rawValue)
            return false
        }
        
        imageHeight = imageHeightTextField.integerValue
        imageWidth = imageWidthTextField.integerValue
        
        return true
    }
    
    func storeDropFilesPath(paths: [String]) {
        
        rawImagesPathLabel.isHidden = false
        
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: paths[0], isDirectory: &isDir) {
            if isDir.boolValue && paths.count == 1 {
                filesPaths = getFilesPaths(url: URL(fileURLWithPath: paths[0]))
                rawImagesPathLabel.stringValue = paths[0]
                rawImagesPathTitleLabel.stringValue = rawImagesPathTitleDefaultValue
            } else {
                filesPaths = paths
                let path: NSString = NSString(string: paths[0]).deletingLastPathComponent as NSString
                rawImagesPathTitleLabel.stringValue = rawImagesPathTitleDefaultValue.appending("\(paths.count) file(s) addded")
                rawImagesPathLabel.stringValue = "\(path)"
            }
        }

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
    
    @IBAction func checkGrayscaleCheckbox(_ sender: NSButton) {
        if sepiaCheckbox.state == .on {
            sepiaCheckbox.state = .off
        }
    }
    
    @IBAction func checkSepiaCheckbox(_ sender: NSButton) {
        if grayscaleCheckbox.state == .on {
            grayscaleCheckbox.state = .off
        }
    }

    @IBAction func convert(_ sender: NSButton) {
        
        resultLabel.isHidden = true
        
        if !collectData() {
            return
        }
        
        progressIndicatior.isHidden = false
        progressIndicatior.startAnimation(nil)
        sender.isEnabled = false
        sender.title = ActionButtonStates.convertProcessing.rawValue
        
        let result = performConvert()
        
        if result {
//            sender.contentTintColor = .green
            
            resultLabel.isHidden = false
            resultLabel.stringValue = "Done"
            // enable to Done label disaappear after timer
//            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
//                self.resultLabel.isHidden = true
//            }
        } else {
//            sender.bezelColor = .red
            printError(error: MCErrorType.MCErrorUnknown.rawValue)
        }
        
        progressIndicatior.isHidden = true
        progressIndicatior.stopAnimation(nil)
        sender.isEnabled = true
        sender.title = ActionButtonStates.readyToConvert.rawValue
    }
    
    func printError(error: String) {
        errorLabel.isHidden = false
        errorLabel.textColor = .red
        errorLabel.stringValue = error
    }
    
    func getFilesPaths(url: URL) -> [String]? {
        var paths: [String] = []
        var urls: [URL] = []
        do {
            urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            return nil
        }
        let filesOnlyUrls = urls.filter { (url) -> Bool in
            do {
                let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                return !resourceValues.isDirectory!
            } catch {
                return false
                
            }
        }
        paths = filesOnlyUrls.map({ $0.path })
        return paths
    }
    
    func gatherRawImages() -> [Image]? {
        
        var rawImages: [Image] = []

        guard let format = filesFormat else {
            return nil
        }
        
        var isGrayscale = false
        if grayscaleCheckbox.state == .on {
            isGrayscale = true
        }
        
        var isBlurred = false
        var blurValue = 0.0
        if let blurV = blurComboBox.selectedCell(), blurV.doubleValue != 0.0 {
            isBlurred = true
            blurValue = blurV.doubleValue
        }
        
        var isSepia = false
        if sepiaCheckbox.state == .on {
            isSepia = true
        }
        
        var paths: [String]?
        var resultsFolderPath: NSString?
        if let filesPaths = filesPaths {
            paths = filesPaths
            resultsFolderPath = NSString(string: paths![0]).deletingLastPathComponent as NSString
        }
        let resultImagesFolder = createResultFolder(at: URL(fileURLWithPath: resultsFolderPath! as String), withName: format)
        
        paths?.forEach({
            let image = Image(sourcePath: $0,
                              resultPathFolder: resultImagesFolder,
                              resultExtension: format,
                              maxSize: maxSize,
                              hight: imageHeight,
                              width: imageWidth,
                              isGrayscale: isGrayscale,
                              isBlurred: isBlurred,
                              blurValue: blurValue,
                              isSepia: isSepia)
            rawImages.append(image)
        })
        
        return rawImages
    }
    
    func composeArguments(image: Image) -> [String] {
        var args: [String] = []
        
        // 1
        args.append(image.sourcePath.replacingOccurrences(of: " ", with: "%%%"))
        // 2
        args.append(image.resultPath.replacingOccurrences(of: " ", with: "%%%"))
        // 3
        args.append(image.resultExtension)
        // 4
        var isGrayscaleLiteral = "false"
        if image.isGrayscale {
            isGrayscaleLiteral = "true"
        }
        args.append(isGrayscaleLiteral)
        
        // 5
        var isBlurredLiteral = "false"
        if image.isBlurred {
            isBlurredLiteral = "true"
        }
        args.append(isBlurredLiteral)
        
        // 6
        args.append("\(image.blurValue)")
    
        // 7
        args.append(image.height != nil ? "\(image.height!)" : " ")
        // 8
        args.append(image.width != nil ? "\(image.width!)" : " ")
       
        return args
    }
    
    func checkImageSize(image: Image) -> UInt64 {
        let filePath = image.resultPath
        var fileSize : UInt64 = 200

        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64

            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        return fileSize
    }
    
    func sizeDoesntMeetsExpectations(expected: Int, actual: Int) -> Bool {
        return actual >= expected
    }
    
    func createResultFolder(at: URL, withName: String) -> String {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd--HH-mm-ss"
        let dateString = df.string(from: date)
        let resultImagesDirectory = "\(withName)-\(dateString)"
        do {
            try FileManager.default.createDirectory(at: at.appendingPathComponent(resultImagesDirectory), withIntermediateDirectories: false)
        } catch {
            print("Can't create dir at: \(at.path) with error: \(error)")
        }
        return resultImagesDirectory
    }
    
    func performConvert() -> Bool {
        
        guard let rawImages = gatherRawImages() else {
            return false
        }
        
        var result = true
        for image in rawImages {
            var quality = 100
            var actualSize = 200
            var expectedSize = 200
            if let size = image.maxSize, image.maxSize != 0 {
                expectedSize = size
            }
           
            while sizeDoesntMeetsExpectations(expected: expectedSize, actual: actualSize) {
                var arguments = composeArguments(image: image)
                if image.resultExtension == "jpeg" {
                    // 9 argument
                    arguments.append("\(quality)")
                } else {
                    arguments.append("0")
                    actualSize = 0
                }
                let res = Utils.runScriptFromBundle(scriptName: "convert-image.sh", args: arguments)
                
                if !res {
                    result = false
                    actualSize = 0
                } else {
                    actualSize = Int(checkImageSize(image: image)) / 1000000
                    quality -= 3
                }
                
                if image.isBlurred {
                    MCFilter.filterGaussianBlurImage(url: URL(fileURLWithPath: image.resultPath), filterValue: image.blurValue)
                }
                
                if image.isSepia {
                    MCFilter.filterSepiaImage(url: URL(fileURLWithPath: image.resultPath))
                }
            }
        }
        return result
    }
}

class Image {
    
    let sourcePath: String
    let resultPath: String
    let resultExtension: String
    let maxSize: Int?
    let height: Int?
    let width: Int?
    let isGrayscale: Bool
    let isBlurred: Bool
    let isSepia: Bool
    let blurValue: Double
    
    init(sourcePath: String,
         resultPathFolder: String,
         resultExtension: String,
         maxSize: Int?,
         hight: Int?,
         width: Int?,
         isGrayscale: Bool,
         isBlurred: Bool,
         blurValue: Double,
         isSepia: Bool) {
        self.sourcePath = sourcePath
        self.resultExtension = resultExtension
        let sourceURL = URL(fileURLWithPath: sourcePath)
        let resultURL = (sourceURL.deletingLastPathComponent()
            .appendingPathComponent(resultPathFolder)
            .appendingPathComponent(sourcePath.fileName()
                .appending(".")
                .appending(resultExtension)))
        self.resultPath = resultURL.path
        self.maxSize = maxSize
        self.height = hight
        self.width = width
        self.isGrayscale = isGrayscale
        self.isBlurred = isBlurred
        self.blurValue = blurValue
        self.isSepia = isSepia
    }
}

extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
