//
//  XcodeProjectLoading.swift
//  XcoderKit
//
//  Created by Geoffrey Foster on 2018-12-10.
//

import Foundation
import XcodeProject
import CommandRegistry

protocol XcodeProjectLoading {
	var xcodeproj: AbsolutePath { get set }
}

extension XcodeProjectLoading {
	func loadedProject() throws -> ProjectFile {
		func projectURL(from path: AbsolutePath) throws -> Foundation.URL {
			if path.extension == "xcodeproj" {
				return URL(fileURLWithPath: path.pathString)
			}
			
			guard localFileSystem.isDirectory(path) else {
				throw Error.invalidProject(path: path.pathString)
			}
			
			let dirs = try localFileSystem.getDirectoryContents(path)
			if let xcodeproj = dirs.sorted().first(where: { $0.hasSuffix("xcodeproj") }) {
				return URL(fileURLWithPath: xcodeproj, relativeTo: URL(fileURLWithPath: path.pathString, isDirectory: true))
			}
			throw Error.invalidProject(path: path.pathString)
		}
		let xcodeprojURL = try projectURL(from: xcodeproj)
		let projectFile: ProjectFile
		do {
			projectFile = try ProjectFile(url: xcodeprojURL)
		} catch {
			throw Error.invalidProject(path: xcodeprojURL.path)
		}
		return projectFile
	}
}

extension ArgumentBinder where Options: XcodeProjectLoading {
	func bindXcodeProject(parser: ArgumentParser) {
		let option = parser.add(option: "--xcodeproj", shortName: nil, kind: PathArgument.self, usage: "Xcode project file to load", completion: .filename)
		bind(option: option) { (options, xcodeproj) in
			options.xcodeproj = xcodeproj.path
		}
	}
}
