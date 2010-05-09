//
//  FFTypes.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

typedef enum {
	FFDataTypeJSON,
	FFDataTypeXML,
	FFDataTypeRSS,
	FFDataTypeAtom
} FFDataType;

typedef enum {
	FFReturnTypeNSString,
	FFReturnTypeJSONValue,
	FFReturnTypeNSXMLDocument,
	FFReturnTypeFFXmlDocPtrWrapper,
	FFReturnTypePSFeed
} FFReturnType;
