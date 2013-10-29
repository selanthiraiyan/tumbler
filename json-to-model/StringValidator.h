//
//  StringValidator.h
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Validator.h"

@interface StringValidator : Validator

+ (NSString*)getValidationMethodForStringNamed:(NSString*)propertyName usingSchemaDefinition:(NSDictionary*)schemaDefinition;

@end
