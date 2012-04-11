//
//  RestKitSettingsTest.h
//  NCSNavField
//
//  Created by John Dzak on 3/19/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

//  Logic unit tests contain unit test code that is designed to be linked into an independent test executable.
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>

@class Fieldwork;

@interface RestKitSettingsTest : SenTestCase

- (Fieldwork *)fieldworkTestData;

- (NSDictionary *)deserializeJson:(NSString *)fieldworkJson;

@end
