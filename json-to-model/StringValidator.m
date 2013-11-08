//
//  StringValidator.m
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "StringValidator.h"
#import "Condition.h"

@implementation StringValidator

+ (NSString*)getValidationMethodForStringNamed:(NSString*)propertyName usingSchemaDefinition:(NSDictionary*)schemaDefinition
{
    
    NSString *string = [NSString stringWithFormat:@"self.%@", propertyName];
    NSMutableArray *conditions = [NSMutableArray array];
    
    //Checking required
    BOOL required = [[schemaDefinition objectForKey:@"required"] boolValue];
    if (required) {
        Condition *condition = [[Condition alloc]init];
        condition.conditionStringInsideIf = [NSString stringWithFormat:@"%@ == nil"
                                             , string];
        condition.userInfoForError = [NSString stringWithFormat:@"%@ is a required property.", propertyName];
        [conditions addObject:condition];
    }
    
    //Checking maxLength
    NSNumber *maxLength = [schemaDefinition objectForKey:@"maxLength"];
    if (maxLength) {
        Condition *condition = [[Condition alloc]init];
        condition.conditionStringInsideIf = [NSString stringWithFormat:@"[%@ length] > %@", string, maxLength];
        condition.userInfoForError = @"maxLength condition failed";
        [conditions addObject:condition];
    }
    
    //Checking minLength
    NSNumber *minLength = [schemaDefinition objectForKey:@"minLength"];
    if (minLength) {
        Condition *condition = [[Condition alloc]init];
        condition.conditionStringInsideIf = [NSString stringWithFormat:@"[%@ length] < %@", string, minLength];
        condition.userInfoForError = @"minLength condition failed";
        [conditions addObject:condition];
    }
    
    //Checking pattern
    NSString *pattern = [schemaDefinition objectForKey:@"pattern"];
    if (pattern) {
        Condition *condition = [[Condition alloc]init];
        condition.conditionStringInsideIf = [NSString stringWithFormat:@"[[NSPredicate predicateWithFormat:@\"SELF MATCHES %@\"] evaluateWithObject:%@]", pattern, string];
        condition.userInfoForError = @"pattern condition failed";
        [conditions addObject:condition];
    }
    return [super getValidationMethodContent:conditions];
}
@end
