//
//  ModelBase.h
//  JSON Test
//
//  Created by Sharma Elanthiraiyan on 7/4/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelBaseProtocol.h"
@interface ModelBase : NSObject <JSONModelBaseProtocol>

+ (NSString*)getServletName;
+ (NSString*)getServletGroup;
+ (NSString*)getServletVersion;
- (NSString*)getClassNamePrefix;
- (NSString*)toJSONString;
- (id)initWithDict:(NSDictionary*)dict;
- (NSString*)errorMessageForKey:(NSString*)key;

@end
