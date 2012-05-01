//
//  RecieveFieldworkStep.m
//  NCSNavField
//
//  Created by John Dzak on 4/27/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

#import "FieldworkStepPostRequest.h"
#import "ApplicationSettings.h"
#import "Fieldwork.h"
#import "Participant.h"
#import "Contact.h"
#import "InstrumentTemplate.h"

@implementation FieldworkStepPostRequest

@synthesize ticket = _ticket;

@synthesize error = _error;

@synthesize response = _response;

- (id) initWithServiceTicket:(CasServiceTicket*)ticket {
    self = [super init];
    if (self) {
        _ticket = [ticket retain];
    }
    return self;
}

- (BOOL) send {
    [self retrieveContacts:self.ticket];
    return [self isSuccessful];
}

- (BOOL) isSuccessful {
    return [self.response isSuccessful];
}


- (void)retrieveContacts:(CasServiceTicket*)serviceTicket {
    if (serviceTicket.pgt) {
        CasConfiguration* conf = [CasConfiguration new];
        CasClient* client = [[CasClient alloc] initWithConfiguration:conf];
        NSString* coreURL = [ApplicationSettings instance].coreURL;
        
        CasProxyTicket* t = [client proxyTicket:NULL serviceURL:coreURL proxyGrantingTicket:serviceTicket.pgt];
        [t reify];
        if (!t.error) {
            NSLog(@"Proxy ticket successfully obtained: %@", t.proxyTicket);
            [self loadDataWithProxyTicket:t];
        } else {
            self.error = [NSString stringWithFormat:@"Failed to obtain proxy ticket: %@", t.message];
            [self showErrorMessage:self.error];

        }
    } else {
        [serviceTicket present];
        if (serviceTicket.ok) {
            CasConfiguration* conf = [CasConfiguration new];
            CasClient* client = [[CasClient alloc] initWithConfiguration:conf];
            NSString* coreURL = [ApplicationSettings instance].coreURL;
            
            CasProxyTicket* t = [client proxyTicket:NULL serviceURL:coreURL proxyGrantingTicket:serviceTicket.pgt];
            [t reify];
            if (!t.error) {
                NSLog(@"Proxy ticket successfully obtained: %@", t.proxyTicket);
                [self loadDataWithProxyTicket:t];
            } else {
                self.error = [NSString stringWithFormat:@"Failed to obtain proxy ticket: %@", t.message];
                [self showErrorMessage:self.error];
            }
        } else {
            self.error = [NSString stringWithFormat:@"Presenting service ticket failed: %@", [serviceTicket message]];
            [self showErrorMessage:self.error];
        }
    }
}

- (void)loadDataWithProxyTicket:(CasProxyTicket*)ticket {
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager.client.HTTPHeaders setValue:[NSString stringWithFormat:@"CasProxy %@", ticket.proxyTicket] forKey:@"Authorization"];
    
    NSDate* today = [NSDate date];
    NSTimeInterval secondsPerWeek = 60 * 60 * 24 * 7;
    NSDate* inOneWeek = [today dateByAddingTimeInterval:secondsPerWeek];
    NSString* clientId = [ApplicationSettings instance].clientId;
    
    NSDateFormatter* rfc3339 = [[[NSDateFormatter alloc] init] autorelease];
    [rfc3339 setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [rfc3339 setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString* path = [NSString stringWithFormat:@"/api/v1/fieldwork?start_date=%@&end_date=%@&client_id=%@", [rfc3339 stringFromDate:today], [rfc3339 stringFromDate:inOneWeek], clientId];
    
    RKObjectLoader* loader = [objectManager objectLoaderWithResourcePath:path delegate:self];
    loader.method = RKRequestMethodPOST;
    
    [loader sendSynchronously];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
	NSLog(@"RootViewController:didLoadObjects -- %@", objects);
    
    Fieldwork* w = [Fieldwork object];
    w.uri = [[objectLoader response] location];
    w.retrievedDate = [NSDate date];
    w.participants = [[NSSet alloc] initWithArray:[objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity.name like %@", [[Participant entity] name ]]]];
    w.contacts = [[NSSet alloc] initWithArray:[objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity.name like %@", [[Contact entity] name ]]]];    
    w.instrumentTemplates = [[NSSet alloc] initWithArray:[objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity.name like %@", [[InstrumentTemplate entity] name ]]]];
    
    NSError *error = nil;    
    if (![[Fieldwork managedObjectContext] save:&error]) {
        NSLog(@"Error saving fieldwork location");
    }
//    
//    [self loadObjectsFromDataStore];
//    
//    self.simpleTable = [[ContactNavigationTable alloc] initWithContacts:_contacts];
//    
//	[self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.error = [NSString stringWithFormat:@"Object loader error while pushing fieldwork.\n%@", [error localizedDescription]];
}


- (void)showErrorMessage:(NSString *)message {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
    
    NSLog(@"%@", message);
}

@end