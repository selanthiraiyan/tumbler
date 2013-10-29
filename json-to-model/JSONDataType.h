//
//  JSONDataType.h
//  json-to-model
//
//  Created by Sharma Elanthiraiyan on 7/8/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONDataType : NSObject

@property (strong) NSString *className;
@property (strong) NSString *instanceName;
@property (strong) NSString *headerPart;
@property (strong) NSString *implementationPart;
@property BOOL isOfCustomClass;
- (id)initWithClassName:(NSString*)className instanceName:(NSString*)instanceName;

@property (strong) NSDictionary *schemaDefinition;

- (NSString*)getDeclarationHeaderPart;
- (NSString*)getDeclarationImplementationPart;
- (NSString*)getValidationHeaderPart;
- (NSString*)getValidationImplementationPart;
@end
