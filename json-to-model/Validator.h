//
//  Validator.h
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Condition.h"

@interface Validator : NSObject

+ (NSString*)getValidationMethodContent:(NSArray*)conditions;
+ (void)setErrorMessageForConditionNamed:(NSString*)conditionName schemaDefinition:(NSDictionary*)schemaDefinition intoCondition:(Condition*)condition;

@end
