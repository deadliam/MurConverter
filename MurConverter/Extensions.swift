//
//  Extensions.swift
//  MurConverter
//
//  Created by Anatolii Kasianov on 01.09.2022.
//

import Foundation
import AppKit

extension NSImage {
   /// Create a CIImage using the best representation available
   ///
   /// - Returns: Converted image, or nil
   func asCIImage() -> CIImage? {
      if let cgImage = self.asCGImage() {
         return CIImage(cgImage: cgImage)
      }
      return nil
   }

   /// Create a CGImage using the best representation of the image available in the NSImage for the image size
   ///
   /// - Returns: Converted image, or nil
   func asCGImage() -> CGImage? {
      var rect = NSRect(origin: CGPoint(x: 0, y: 0), size: self.size)
      return self.cgImage(forProposedRect: &rect, context: NSGraphicsContext.current, hints: nil)
    }
}

extension CIImage {
   /// Create a CGImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asCGImage(context: CIContext? = nil) -> CGImage? {
      let ctx = context ?? CIContext(options: nil)
      return ctx.createCGImage(self, from: self.extent)
   }

   /// Create an NSImage version of this image
   /// - Parameters:
   ///   - pixelSize: The number of pixels in the result image. For a retina image (for example), pixelSize is double repSize
   ///   - repSize: The number of points in the result image
   /// - Returns: Converted image, or nil
   #if os(macOS)
   @available(macOS 10, *)
   func asNSImage(pixelsSize: CGSize? = nil, repSize: CGSize? = nil) -> NSImage? {
      let rep = NSCIImageRep(ciImage: self)
      if let ps = pixelsSize {
         rep.pixelsWide = Int(ps.width)
         rep.pixelsHigh = Int(ps.height)
      }
      if let rs = repSize {
         rep.size = rs
      }
      let updateImage = NSImage(size: rep.size)
      updateImage.addRepresentation(rep)
      return updateImage
   }
   #endif
}

extension CGImage {
   /// Create a CIImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asCIImage() -> CIImage {
      return CIImage(cgImage: self)
   }

   /// Create an NSImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asNSImage() -> NSImage? {
      return NSImage(cgImage: self, size: .zero)
   }
}

//extension NSImage {
//    
//    func saveToDocuments(filename: String) {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileURL = documentsDirectory.appendingPathComponent(filename)
//        
//        if let bits = filename?.representations.first as? NSBitmapImageRep {
//            let data = bits.representationUsingType(.NSJPEGFileType, properties: [:])
//            data?.writeToFile("/path/myImage.jpg", atomically: false)
//        }
//        
//        if let data = self.repre jpegData(compressionQuality: 1.0) {
//            do {
//                try data.write(to: fileURL)
//            } catch {
//                print("error saving file to documents:", error)
//            }
//        }
//    }
//
//}
