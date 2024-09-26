@preconcurrency import CoreData
import Foundation

import SPMProj



/** All of the errors thrown by the module should have this type. */
public enum XcodeProjError : Error {
	
	case cannotReadFile(URL, Error)
	
	case cannotFindSingleXcodeproj
	
	case unsupportedPBXProj(UnsupportedPBXProjError)
	
	/** `objectID` is `nil` if unknown or not applicable (root, etc.) */
	case pbxProjParseError(PBXProjParseError, objectID: String?)
	case infoPlistParseError(InfoPlistParseError)
	case xcconfigParseError(XCConfigParseError)
	case buildSettingParseError(BuildSettingParseError)
	
	/** `objectID` is `nil` if unknown or not applicable (root, etc.) */
	case invalidPBXProjObjectGraph(PBXProjObjectGraphError, objectID: String?)
	case missingVariable(String)
	
	case multipleMatchingSPMTargetsFound([(SPMProj, SPMTarget)])
	
	case internalError(InternalError)
	
	public enum PBXProjParseError : Error {
		
		case plistParseError(Error)
		case deserializedPlistHasInvalidType
		
		case missingProperty(propertyName: String)
		case unexpectedPropertyValueType(propertyName: String/*, value: Any*/)
		
		case unknownOrInvalidProjectReference([String: String])
		
		case invalidIntString(propertyName: String, string: String)
		case invalidURLString(propertyName: String, string: String)
		
		case isaNotFoundInModel(String)
		case invalidObjectTypeInDecodedObjects(expectedType: PBXObject.Type)
		case invalidObjectTypeFetchedOrCreated(expectedType: PBXObject.Type)
		case tryingToInstantiateAbstractISA(String, entity: NSEntityDescription)
		
	}
	
	public enum InfoPlistParseError : Error {
		
		case plistParseError(Error)
		case deserializedPlistHasInvalidType
		
	}
	
	public enum XCConfigParseError : Error {
		
		case cannotFindFile(URL)
		
		case unknownDirective(String)
		case gotSpaceAfterSharpInDirective
		case noSpaceAfterIncludeDirective
		case expectedDoubleQuoteAfterIncludeDirective
		case unterminatedIncludeFileName
		case unexpectedCharAfterInclude
		
		case invalidFirstCharInVar(Character)
		case unexpectedCharAfterVarName
		
		case invalidLine(XCConfig.Line)
		
	}
	
	/* Very few errors: it is practically impossible to get an invalid build setting given the format it has.
	 * It is however very possible to get an unexpected value, but that’s another story. */
	public enum BuildSettingParseError : Error {
		
		case unfinishedKey(full: String, garbage: String)
		
	}
	
	public enum PBXProjObjectGraphError : Error {
		
		case coreDataSaveError(Error)
		
		case missingProperty(propertyName: String)
		
		case atLeastTwoConfigurationsHaveSameName
		/**
		 When retrieving combined settings of a target, we retrieve all the settings in all the configuration names the target has.
		 It is expected for the project to have at least the same configuration names as the target.
		 This error is thrown if the target has a configuration name the project does not have. */
		case targetHasConfigurationNameProjectDoesNot(configName: String)
		case baseConfigurationReferenceIsNotTextXCConfig(configurationID: String?)
		
	}
	
	public enum UnsupportedPBXProjError : Error {
		
		case unknownArchiveVersion(String)
		case unknownObjectVersion(String)
		/** Not sure what a non emtpy “classes” property means in a pbxproj, so we throw an error if we get that. */
		case classesPropertyIsNotEmpty//([String: Any])
		
		case unknownRootProperties(Set<String>)
		
	}
	
	public enum InternalError : Error {
		
		case modelNotFound
		case cannotLoadModel(Error)
		
		/** Combined settings for a project should have a `nil` target name. */
		case combinedSettingsForProjectWithTargetName
		case combinedSettingsForTargetWithoutTarget
		case combinedSettingsForTargetWithoutTargetName
		
		case managedContextHasNoModel
		case gotMoreThanOneObjectForID(String)
		case unknownObjectTypeDuringSerialization//(object: Any)
		case tryingToInstantiateNonPBXObjectEntity(isa: String, entity: NSEntityDescription)
		
		case unknownFileElementClass(rawISA: String?)
		
		case cannotGetDeveloperDir
		
	}
	
}

typealias Err = XcodeProjError
