//
//  MCFilter.swift
//  MurConverter
//
//  Created by Anatolii Kasianov on 01.09.2022.
//

import Foundation
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins


class MCFilter {
    
    static func filterSepiaImage(url: URL) {
        let coreImage = CIImage(contentsOf: url)
        let context = CIContext()
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(0.9, forKey: kCIInputIntensityKey)
        let sepiaCIImage = sepiaFilter?.outputImage
        let cgOutputImage = context.createCGImage(sepiaCIImage!, from: coreImage!.extent)
        let jpegData = jpegDataFrom(image: cgOutputImage!)
        do {
            try FileManager.default.removeItem(at: url)
            try jpegData.write(to: url)
        } catch {
            print("\(error)")
        }
    }
    
    static func filterGaussianBlurImage(url: URL, filterValue: Double) {
        let coreImage = CIImage(contentsOf: url)
        let context = CIContext()
        let blurFilter = CIFilter( name: "CIGaussianBlur")
        blurFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(filterValue, forKey: kCIInputRadiusKey)
//        blurFilter?.setValue(0.9, forKey: kCIInputIntensityKey)
        let blurCIImage = blurFilter?.outputImage
        let cgOutputImage = context.createCGImage(blurCIImage!, from: coreImage!.extent)
        let jpegData = jpegDataFrom(image: cgOutputImage!)
        do {
            try FileManager.default.removeItem(at: url)
            try jpegData.write(to: url)
        } catch {
            print("\(error)")
        }
    }
    
    static func jpegDataFrom(image: CGImage) -> Data {
        let bitmapRep = NSBitmapImageRep(cgImage: image)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        return jpegData
    }
}


