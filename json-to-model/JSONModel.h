//
//  JSONModel.h
//  json-to-model
//
//  Created by Sharma Elanthiraiyan on 7/8/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONDataType.h"

@interface JSONModel : NSObject

@property (strong) NSString *className;
@property (strong) NSString *parentClassName;
@property (strong) NSMutableArray *adoptsProtocolsNamed;
@property (strong) NSMutableArray *consistsOfInstanceVarsOfClass;

@property (strong) NSString *servletName;
@property (strong) NSString *servletGroup;
@property (strong) NSString *servletVersion;
@property BOOL isRequest;

@property (strong) NSDictionary *schemaDefinition;

- (id)initWithName:(NSString*)name;
- (id)initWithName:(NSString *)name outerClass:(JSONModel*)model;


- (NSString*)getHeaderPart;
- (NSString*)getImplementationPart;
@end
