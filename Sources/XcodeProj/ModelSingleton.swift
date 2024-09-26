@preconcurrency import CoreData
import Foundation



struct ModelSingleton {
	
	static let model = Bundle.module.url(forResource: "PBXModel", withExtension: "momd").flatMap{ NSManagedObjectModel(contentsOf: $0) }
	
}
