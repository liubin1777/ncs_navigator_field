//
//  Event.m
//  NCSNavField
//
//  Created by John Dzak on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "NSString+Additions.h"
#import "NSDate+Additions.h"
#import <NUSurveyor/UUID.h>

@implementation Event

@dynamic eventId, name, eventTypeCode, eventTypeOther, eventRepeatKey, startDate, endDate, startTime, endTime, incentiveTypeId, incentiveCash, incentiveNonCash, dispositionId, dispositionCategoryId, breakOffId, comments, contact, instruments, version, pId;

+ (Event*)event {
    Event* e = [Event object];
    e.eventId = [UUID generateUuidString];
    e.startDate = [NSDate date];
    e.startTime = [NSDate date];
    return e;
}

- (void) setStartTimeJson:(NSString*)startTime {
    self.startTime = [startTime jsonTimeToDate];
}

- (NSString*) startTimeJson {
    return [self.startTime jsonSchemaTime];
}

- (void) setEndTimeJson:(NSString*)endTime {
    self.endTime = [endTime jsonTimeToDate];
}

- (NSString*) endTimeJson {
    return [self.endTime jsonSchemaTime];
}

// BUG: This is a workaround for a bug when using the generated method
//      addInstrumentsObject to add an instrument to the ordered set.
//      https://openradar.appspot.com/10114310
- (void)addInstrumentsObject:(Instrument *)value {
    NSMutableOrderedSet *instruments = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.instruments];
    [instruments addObject:value];
    self.instruments = instruments;
}
@end