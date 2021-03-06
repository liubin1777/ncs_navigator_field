//
//  DatabaseTest.h
//  NCSNavField
//
//  Created by John Dzak on 4/11/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

//  Logic unit tests contain unit test code that is designed to be linked into an independent test executable.
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import <CoreData.h>

@interface DatabaseTest : SenTestCase


- (void)setUp;
- (void)tearDown;
- (NSManagedObjectContext*)managedObjectContext;

@end
