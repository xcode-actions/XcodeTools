import Foundation

import ArgumentParser



extension Regex : @retroactive ExpressibleByArgument where Output == Substring {
	
	public init?(argument: String) {
		do    {self = try Regex(argument)}
		catch {return nil}
	}
	
}
