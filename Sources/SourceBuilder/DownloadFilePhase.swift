import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(System)
import System
#else
import SystemPackage
#endif

import GlobalConfModule
import XibLoc

import Utils



public struct DownloadFilePhase : BuildPhase {
	
	public enum Err : Error {
		
		case notImplemented
		
		case unknownVariablesInURLTemplate(Set<String>)
		case invalidURL(String)
		case invalidURLResponse(URLResponse)
		case invalidChecksumForDownloadedFile(URL, String)
		
		case unknownNetworkingError /* We should not need that one once Linux has support for async/await */
		
	}
	
	public var downloadedURL: URL
	public var downloadDestination: FilePath
	
	public var expectedHash: (value: String, hasher: AnyHasher)?
	
	public var outputs: [FilePath] {
		return [downloadDestination]
	}
	
	public init(root: FilePath, inputs: [FilePath], arguments: [String: Any]) throws {
		throw Err.notImplemented
	}
	
	public init(urlTemplate template: String, variables: [String: String], destinationFolder: FilePath, expectedHash: (value: String, hasher: AnyHasher)?) throws {
		var unknownVars = Set<String>()
		let variableReplacementBlock: (String) -> String = { str in
			let varName = str.trimmingCharacters(in: .whitespacesAndNewlines)
			guard let val = variables[varName] else {
				unknownVars.insert(varName)
				return ""
			}
			return val
		}
		/* The force-unwrap is valid: all the tokens are valid */
		let xibLocInfo = Str2StrXibLocInfo(simpleSourceTypeReplacements: [OneWordTokens(leftToken: "{{", rightToken: "}}"): variableReplacementBlock], identityReplacement: { $0 })!
		let stringURL = template.applying(xibLocInfo: xibLocInfo)
		guard unknownVars.isEmpty else {
			throw Err.unknownVariablesInURLTemplate(unknownVars)
		}
		guard let url = URL(string: stringURL) else {
			throw Err.invalidURL(stringURL)
		}
		
		self.init(downloadedURL: url, destination: destinationFolder.appending(url.lastPathComponent), expectedHash: expectedHash)
	}
	
	public init(downloadedURL: URL, destination: FilePath, expectedHash: (value: String, hasher: AnyHasher)?) {
		self.downloadedURL = downloadedURL
		self.downloadDestination = destination
		
		self.expectedHash = expectedHash
	}
	
	public var canBeSkipped: Bool {
		get async throws {
			guard Conf.fileManager.fileExists(atPath: downloadDestination.string) else {
				return false
			}
			let hash = try await expectedHash?.hasher.hash(of: downloadDestination)
			guard hash == expectedHash?.value else {
				return false
			}
			return true
		}
	}
	
	public func execute() async throws -> [FilePath] {
		Conf.logger?.info("Downloading file from \(downloadedURL)")
		let (tmpFileURL, urlResponse) = try await temporaryLinuxAsyncDownload(url: downloadedURL)
		guard let httpURLResponse = urlResponse as? HTTPURLResponse, 200..<300 ~= httpURLResponse.statusCode else {
			throw Err.invalidURLResponse(urlResponse)
		}
		/* At some point in the future, FilePath(tmpFileURL) will be possible
		 * (it is already possible when importing System instead of SystemPackage actually).
		 * This init might return nil, so the tmpFilePath variable would have to be set in the guard above. */
		assert(tmpFileURL.isFileURL)
		let tmpFilePath = FilePath(tmpFileURL.path)
		if let expectedHash = expectedHash {
			let hash = try await expectedHash.hasher.hash(of: tmpFilePath)
			guard hash == expectedHash.value else {
				throw Err.invalidChecksumForDownloadedFile(downloadedURL, expectedHash.value)
			}
		}
		try Conf.fileManager.ensureFileDeleted(path: downloadDestination)
		try Conf.fileManager.moveItem(at: tmpFileURL, to: downloadDestination.url)
		Conf.logger?.info("File downloaded")
		return [downloadDestination]
	}
	
	private func temporaryLinuxAsyncDownload(url: URL) async throws -> (URL, URLResponse) {
#if !os(Linux)
		return try await Conf.urlSession.download(from: downloadedURL, delegate: nil)
#else
		return try await withCheckedThrowingContinuation{ continuation in
			Conf.urlSession.downloadTask(with: url, completionHandler: { url, response, error in
				if let url = url, let response = response, error == nil {
					continuation.resume(returning: (url, response))
				} else {
					continuation.resume(throwing: error ?? Err.unknownNetworkingError)
				}
			}).resume()
		}
#endif
	}
	
}
