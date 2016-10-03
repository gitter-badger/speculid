//
//  SVGImageConversionBuilder.swift
//  speculid
//
//  Created by Leo Dion on 9/26/16.
//
//

import Foundation

public struct SVGImageConversionBuilder : ImageConversionBuilderProtocol {
  public func conversion(forImage imageSpecification: ImageSpecificationProtocol, withSpecifications specifications: SpeculidSpecificationsProtocol, andConfiguration configuration: SpeculidConfigurationProtocol) -> ConversionResult? {
    guard let scale = imageSpecification.scale else {
      return nil
    }
    
    guard specifications.sourceImageURL.pathExtension.compare("svg", options: .caseInsensitive, range: nil, locale: nil) == .orderedSame else {
      return nil
    }
    
    guard let inkscapeURL = configuration.inkscapeURL else {
      return .Error(MissingRequiredInstallationError(name: "inkscape"))
    }
    
    var arguments : [String] = ["--without-gui","--export-png"]
    if let size = imageSpecification.size {
      let dimension = size.height > size.width ? "-h" : "-w"
      let length = Int(round(max(size.width, size.height) * scale))
      let destinationURL = specifications.contentsDirectoryURL.appendingPathComponent(specifications.sourceImageURL.deletingPathExtension().lastPathComponent).appendingPathExtension("\(size.width.cleanValue)x\(size.height.cleanValue).\(scale.cleanValue)x.png")
      arguments.append(contentsOf: [destinationURL.path,dimension,"\(length)", specifications.sourceImageURL.absoluteURL.path])
    } else if let geometryValue = specifications.geometry?.value {
      let dimension: String
      let length: Int
      switch geometryValue {
      case .Width(let value):
        dimension = "-w"
        length = value
      case .Height(let value):
        dimension = "-h"
        length = value
      }
      let destinationURL = specifications.contentsDirectoryURL.appendingPathComponent(specifications.sourceImageURL.deletingPathExtension().lastPathComponent).appendingPathExtension("\(length).\(scale.cleanValue)x.png")
      arguments.append(contentsOf: [destinationURL.path,dimension,"\(length)", specifications.sourceImageURL.absoluteURL.path])
    } else {
      // convert to
      let destinationURL = specifications.contentsDirectoryURL.appendingPathComponent(specifications.sourceImageURL.deletingPathExtension().lastPathComponent).appendingPathExtension("\(scale.cleanValue)x.png")
      arguments.append(contentsOf: [destinationURL.path, "-d", "\(90*scale)" ,specifications.sourceImageURL.absoluteURL.path])
    }
    
    let process = Process()
    process.launchPath = inkscapeURL.path
    process.arguments = arguments
    
    return .Task(ProcessImageConversionTask(process: process))
    
    
  }
  
  
}