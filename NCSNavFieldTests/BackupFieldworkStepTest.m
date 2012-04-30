//
//  SyncStepsTest.m
//  NCSNavField
//
//  Created by John Dzak on 4/20/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

#import "BackupFieldworkStepTest.h"
#import "ApplicationPersistentStore.h"

@implementation NSDate (Stub)

+ (id)date {
    NSDateFormatter* f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss"];
    [f setTimeZone:[NSTimeZone localTimeZone]];
    return [f dateFromString:@"2012-04-20 16:01:59"];
}

@end

@implementation BackupFieldworkStepTest

ApplicationPersistentStore* store;
ApplicationPersistentStoreBackup* backup;

- (void) setUp {
    NSString *filePath = [self mainFieldworkPath];
    if (!filePath) {
        filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"main.sqlite"];
        NSData *data = [@"Test" dataUsingEncoding:NSUTF8StringEncoding];
        [data writeToFile:filePath atomically:YES];
        filePath = [self mainFieldworkPath];
    }
    STAssertNotNil(filePath, @"Path should exist");
    
    store = [ApplicationPersistentStore instance];
    backup = [store backup];
}

- (void) tearDown {
    NSFileManager* dfm = [NSFileManager defaultManager];
    [dfm removeItemAtPath:[self backupFieldworkPath] error:NULL];
}

- (void)testBackupFieldworkFilename {
    STAssertEqualObjects([store backupFieldworkFilename], @"sync-backup-20120420160159.sqlite", @"Wrong backup filename");
}

- (void)testPerformBackup {
    STAssertNotNil([self backupFieldworkPath], @"Path should exist");
    STAssertTrue([store success], @"Should be successful");
}

- (void)testPerformBackupUnsuccessfull {
    [[NSFileManager defaultManager] removeItemAtPath:[self backupFieldworkPath] error:NULL];
    STAssertNil([[NSBundle mainBundle] pathForResource:@"sync-backup-20120420160159" ofType:@"sqlite"] , @"Path should not exist");
    STAssertFalse([store success], @"Should be unsuccessful");
}

- (void)testRollback {
    STAssertNotNil([self backupFieldworkPath], @"Path should exist");
    STAssertTrue([store success], @"Should be successful");
    [store rollback];
    STAssertNil([self backupFieldworkPath], @"Path should not exist");
}

#pragma mark - Helper Methods

- (NSString*) mainFieldworkPath {
    return [[NSBundle mainBundle] pathForResource:@"main" ofType:@"sqlite"];
}

- (NSString *)backupFieldworkPath {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sync-backup-20120420160159" ofType:@"sqlite"];
    return filePath;
}

@end
