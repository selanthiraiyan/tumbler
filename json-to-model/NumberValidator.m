//
//  NumberValidator.m
//  Tumbler
//
//  Created by Sharma Elanthiraiyan on 10/11/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "NumberValidator.h"
#import "NSString+StringHelper.h"
#import "Condition.h"

@implementation NumberValidator

+ (NSString*)getValidationMethodForNumberNamed:(NSString*)propertyName usingSchemaDefinition:(NSDictionary*)schemaDefinition
{
    
    NSString *number = [NSString stringWithFormat:@"self.%@", propertyName];
    NSMutableArray *conditions = [NSMutableArray array];
    
    //Checking multipleOf
    NSNumber *multipleOf = [schemaDefinition objectForKey:@"multipleOf"];
    if (multipleOf) {
        Condition *condition = [[Condition alloc]init];
        condition.conditionStringInsideIf = [NSString stringWithFormat:@"(%@ / %f) != 0"
                                          , [number addDoubleValueMethodCall], [multipleOf doubleValue]];
        condition.userInfoForError = @"multipleOf condition failed";
        [conditions addObject:condition];
    }
    
    //Checking maximum
    NSNumber *maximum = [schemaDefinition objectForKey:@"maximum"];
    if (maximum) {
        BOOL exclusiveMaximum = [[schemaDefinition objectForKey:@"exclusiveMaximum"] boolValue];
        
        Condition *condition = [[Condition alloc]init];
        condition.conditionStringInsideIf = [NSString stringWithFormat:@"(%@ > %f)", [number addDoubleValueMethodCall], [maximum doubleValue]];
        
        if (exclusiveMaximum) {
            condition.conditionStringInsideIf = [NSString stringWithFormat:@"(%@ >= %f)", [number addDoubleValueMethodCall], [maximum doubleValue]];
        }

        condition.userInfoForError = @"maximum condition failed";
        [conditions addObject:condition];
    }
    
    //Checking minimum
    NSNumber *minimum = [schemaDefinition objectForKey:@"minimum"];
    if (minimum) {
        BOOL exclusiveMinimum = [[schemaDefinition objectForKey:@"exclusiveMinimum"] boolValue];
        
        Condition *condition = [[Condition alloc]init];
        condition.conditionStringInsideIf = [NSString stringWithFormat:@"(%@ < %f)", [number addDoubleValueMethodCall], [minimum doubleValue]];
        
        if (exclusiveMinimum) {
            condition.conditionStringInsideIf = [NSString stringWithFormat:@"(%@ <= %f)", [number addDoubleValueMethodCall], [minimum doubleValue]];
        }
        
        condition.userInfoForError = @"minimum condition failed";
        [conditions addObject:condition];
    }
    
    return [super getValidationMethodContent:conditions];
}
@end
