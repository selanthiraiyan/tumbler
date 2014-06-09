//
//  ModelBase.m
//  JSON Test
//
//  Created by Sharma Elanthiraiyan on 7/4/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "ModelBase.h"
#import <objc/runtime.h>

@implementation ModelBase

- (id)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
        for (i = 0; i < outCount; i++) {
            NSString *propertyName;
            objc_property_t property = properties[i];
            propertyName = [NSString stringWithCString:property_getName(property)];
            
            id myObject = [dict valueForKey:propertyName];
            
            if (myObject == nil) {
                continue;
            }
            
            
            NSString *text = propertyName;
            NSString *capitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
            NSString *className = [NSString stringWithFormat:@"%@%@", [self getClassNamePrefix], capitalized];
            
            if ([myObject isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *array = [NSMutableArray array];
                for (id innerObject in myObject) {
                    if ([innerObject isKindOfClass:[NSDictionary class]]) {
                        if (NSClassFromString(className) != nil) {
                            [array addObject:[[NSClassFromString(className) alloc]initWithDict:innerObject]];
                        }
                        else {
                            [NSException raise:@"Model class not found." format:@"Class with name %@ not found.", className];
                        }
                    }
                    else {
                        [array addObject:innerObject];
                    }
                }
                [self setValue:array forKey:propertyName];
                
            }
            else if ([myObject isKindOfClass:[NSDictionary class]]) {
                
                if (NSClassFromString(className) != nil) {
                    [self setValue:[[NSClassFromString(className) alloc]initWithDict:myObject] forKey:propertyName];
                }
                else {
                    [NSException raise:@"Model class not found." format:@"Class with name %@ not found.", className];
                }
                
            }
            else {
                [self setValue:myObject forKey:propertyName];
            }
        }
        free(properties);
    }
    return self;
}

- (NSDictionary*)toDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
    for (i = 0; i < outCount; i++) {
        NSString *propertyName;
        objc_property_t property = properties[i];
    	propertyName = [NSString stringWithCString:property_getName(property)];
        id myObject = [self valueForKey:propertyName];
        
        if (myObject == nil) {
            continue;
        }
        
        if ([myObject isKindOfClass:[NSArray class]]) {
            NSMutableArray *dictArray = [NSMutableArray array];
            for (id object in myObject) {
                if ([object respondsToSelector:@selector(toDict)]) {
                    [dictArray addObject:[object toDict]];
                }
                else {
                    [dictArray addObject:object];
                }
            }
            [dict setObject:dictArray forKey:propertyName];
        }
        else if ([myObject respondsToSelector:@selector(toDict)]) {
            [dict setObject:[myObject toDict] forKey:propertyName];
        }
        else {
            [dict setObject:myObject forKey:propertyName];
        }
    }
    free(properties);
    return dict;
}

- (NSString*)toJSONString
{
    
    NSDictionary *dict = [self toDict];
    NSError *error = nil;
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}

- (NSString*)getServletName
{
    return @"ServletName";
}

- (NSString*)getServletGroup
{
    return @"ServletGroup";
}

- (NSString*)errorMessageForKey:(NSString*)key
{
    return key;
}
@end
