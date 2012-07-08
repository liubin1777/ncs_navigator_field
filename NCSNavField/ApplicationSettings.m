//
//  Configuration.m
//  NCSNavField
//
//  Created by John Dzak on 1/16/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

#import "ApplicationSettings.h"
#import "NSStringHelper.h"

NSString* const SettingsDidChangeNotification = @"ApplicationSettingsChanged";
NSString* const CLIENT_ID = @"client.id";
NSString* const CORE_URL = @"navigator.core.url";
NSString* const CAS_SERVER_URL = @"cas.server.url";
NSString* const PGT_RECEIVE_URL = @"pgt.receive.url";
NSString* const PGT_RETRIEVE_URL = @"pgt.retrieve.url";
NSString* const PURGE_FIELDWORK_BUTTON = @"purge.fieldwork.button";
NSString* const UPCOMING_DAYS_TO_SYNC = @"upcoming.days.to.sync";

@implementation ApplicationSettings

@synthesize coreURL=_coreURL;
@synthesize clientId=_clientId;
@synthesize casServerURL=_casServerURL;
@synthesize pgtReceiveURL=_pgtReceiveURL;
@synthesize pgtRetrieveURL=_pgtRetrieveURL;
@synthesize purgeFieldworkButton=_purgeFieldworkButton;
@synthesize upcomingDaysToSync=_upcomingDaysToSync;

static ApplicationSettings* instance;

- (id)init {
    self = [super init];
    if (self) {
        _clientId = [[self retreiveClientId] retain];
        _coreURL = [[self retreiveCoreURL] retain];
        _casServerURL = [[self casServerURL] retain];
        _pgtReceiveURL = [[self pgtReceiveURL] retain];
        _pgtRetrieveURL = [[self pgtRetrieveURL] retain];
        _purgeFieldworkButton = [self isPurgeFieldworkButton];
        _upcomingDaysToSync = [self upcomingDaysToSync];
        
        [self registerDefaultsFromSettingsBundle];

    }
    
    return self;
}

+ (ApplicationSettings*) instance {
    if (!instance) {
        instance = [[ApplicationSettings alloc] init];
    }
    return instance;
}

+ (void) reload {
    [[ApplicationSettings instance] reload];
}

- (void) reload {
    self.clientId = [self retreiveClientId];
    self.coreURL = [self retreiveCoreURL];
    self.casServerURL = [self casServerURL];
    self.pgtReceiveURL = [self pgtReceiveURL];
    self.pgtRetrieveURL = [self pgtRetrieveURL];
    self.purgeFieldworkButton = [self purgeFieldworkButton];
    self.upcomingDaysToSync = [self upcomingDaysToSync];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SettingsDidChangeNotification object:self];
}

- (NSString*) retreiveClientId {
    NSString *cid = [[NSUserDefaults standardUserDefaults] stringForKey:CLIENT_ID];
    if (cid == nil)
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuid = [(NSString *)CFUUIDCreateString(NULL,uuidRef) autorelease];
        CFRelease(uuidRef);
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:CLIENT_ID];
    }
    return cid;
}

- (NSString*) retreiveCoreURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:CORE_URL];
}

- (NSString*) casServerURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:CAS_SERVER_URL];
}

- (NSString*) pgtReceiveURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PGT_RECEIVE_URL];
}

- (NSString*) pgtRetrieveURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PGT_RETRIEVE_URL];
}

- (BOOL) isPurgeFieldworkButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PURGE_FIELDWORK_BUTTON];
}

- (NSInteger) upcomingDaysToSync {
    return [[NSUserDefaults standardUserDefaults] integerForKey:UPCOMING_DAYS_TO_SYNC];
}

+ (CasConfiguration*) casConfiguration {
    ApplicationSettings* s = [ApplicationSettings instance];
    return [[[CasConfiguration alloc] initWithCasURL:s.casServerURL receiveURL:s.pgtReceiveURL retrieveURL:s.pgtRetrieveURL] autorelease];
}

- (BOOL) coreSynchronizeConfigured {
    return !([NSStringHelper isEmpty:self.coreURL] || [NSStringHelper isEmpty:self.casServerURL] || [NSStringHelper isEmpty:self.pgtReceiveURL] || [NSStringHelper isEmpty:self.pgtRetrieveURL]);
}

- (void)registerDefaultsFromSettingsBundle {
    NSLog(@"Registering default values from Settings.bundle");
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if(!settingsBundle)
    {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    
    for (NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key)
        {
            // check if value readable in userDefaults
            id currentObject = [defs objectForKey:key];
            if (currentObject == nil)
            {
                // not readable: set value from Settings.bundle
                id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                [defaultsToRegister setObject:objectToSet forKey:key];
                NSLog(@"Setting object %@ for key %@", objectToSet, key);
            }
            else
            {
                // already readable: don't touch
                NSLog(@"Key %@ is readable (value: %@), nothing written to defaults.", key, currentObject);
            }
        }
    }
    
    [defs registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
    [defs synchronize];
}

- (void)dealloc {
    [_coreURL release];
    [_clientId release];
    [_casServerURL release];
    [_pgtReceiveURL release];
    [_pgtRetrieveURL release];
    [super dealloc];
}
@end
