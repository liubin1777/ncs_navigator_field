//
//  Instrument.m
//  NCSNavField
//
//  Created by John Dzak on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Instrument.h"
#import "SBJSON.h"
#import "NSDate+Additions.h"
#import "NSString+Additions.h"
#import "ResponseSet.h"
#import "InstrumentPlan.h"
#import "InstrumentTemplate.h"
#import <MRCEnumerable/MRCEnumerable.h>
#import "NUSurvey+Additions.h"
#import <RestKit/RestKit.h>
#import "ResponseGenerator.h"
#import "NUResponse+Additions.h"
#import "Event.h"
#import "Contact.h"
#import "SurveyResponseSetRelationship.h"

NSInteger const INSTRUMENT_TYPE_ID_PROVIDER_BASED_SAMPLING_ELIGIBILITY_SCREENER = 44;

@implementation Instrument

@dynamic instrumentId, name, event, instrumentTypeId, instrumentTypeOther,
    instrumentVersion, repeatKey, startDate, startTime, endDate, endTime,
    statusId, breakOffId, instrumentModeId, instrumentModeOther,
    instrumentMethodId, supervisorReviewId, dataProblemId, comment, responseSets, instrumentPlanId, responseTemplates;

- (NSArray*) responseSetDicts {
    NSMutableArray* all = [[NSMutableArray alloc] init];
    for (ResponseSet* rs in self.responseSets) {
        NSDictionary* d = rs.toDict;
        [all addObject:d];
    }
    return all;
}

- (void) setResponseSetDicts:(NSArray*)responseSetDicts {
    NSMutableSet* all = [[NSMutableSet alloc] init];
    for (NSDictionary* rsDict in responseSetDicts) {
        ResponseSet* rs = [ResponseSet object];
        [rs fromJson:[[[SBJSON alloc] init] stringWithObject:rsDict]];
        [all addObject:rs];
    }
    self.responseSets = all;
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

- (InstrumentPlan*)instrumentPlan {
    return [InstrumentPlan findFirstByAttribute:@"instrumentPlanId" withValue:self.instrumentPlanId];
}

- (NSString*)determineInstrumentVersionFromSurveyTitle {
    NSString* version = nil;
    
    InstrumentPlan* ip = [self instrumentPlan];
    if (ip) {
        InstrumentTemplate* first = [ip.instrumentTemplates firstObject];
        if (first) {
            NSDictionary* survey = [first representationDictionary];
            NSString* title = [survey valueForKey:@"title"];
            if (title) {
                NSRegularExpression *regex =
                    [NSRegularExpression regularExpressionWithPattern:@"V(\\d+(\\.\\d)?)" options:NSRegularExpressionCaseInsensitive error:nil];
                
                NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:title
                                                                     options:0
                                                                       range:NSMakeRange(0, [title length])];
                if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                    // Move range up 1 to ignore 'V'
                    NSRange range = NSMakeRange(rangeOfFirstMatch.location + 1, rangeOfFirstMatch.length - 1);
                    version = [title substringWithRange:range];
                }
            }
        }
    }
    return version;
}

- (NSString*)determineInstrumentVersion {
    return self.instrumentVersion ? self.instrumentVersion : self.determineInstrumentVersionFromSurveyTitle;
}

- (BOOL)isProviderBasedSamplingScreener {
    return INSTRUMENT_TYPE_ID_PROVIDER_BASED_SAMPLING_ELIGIBILITY_SCREENER == self.instrumentTypeId.integerValue;
}

- (NSArray*)surveyResponseSetRelationshipsWithSurveyContext:(NSDictionary*)ctx {
    NSArray* surveys = [[self.instrumentPlan.instrumentTemplates array] collect:^id(InstrumentTemplate* tmpl){
        return tmpl.survey;
    }];
    
    NSMutableArray* assoc = [NSMutableArray new];
    for (NUSurvey* s in surveys) {
        ResponseSet* found = [self.responseSets detect:^BOOL(ResponseSet* rs) {
            NSString* rsSurveyId = [rs valueForKey:@"survey"];
            return [rsSurveyId isEqualToString:s.uuid];
        }];
        
        if (!found) {
            NCSLog(@"No response set found for survey: %@", s.uuid);
            NSDictionary* surveyDict = [[SBJSON new] objectWithString:s.jsonString];
            found = [ResponseSet newResponseSetForSurvey:surveyDict withModel:[RKObjectManager sharedManager].objectStore.managedObjectModel inContext:[RKObjectManager sharedManager].objectStore.managedObjectContextForCurrentThread];
            [self addResponseSetsObject:found];
            
            NCSLog(@"Creating new response set: %@", found.uuid);
        }
        
        ResponseGenerator* g = [[ResponseGenerator alloc] initWithSurvey:s context:ctx];
        for (NUResponse* resp in [g responses]) {
            NSArray* existing = [found responsesForQuestion:[resp valueForKey:@"question"]];
            for (NUResponse* e in existing) {
                [e deleteEntity];
            }
            [found newResponseForQuestion:[resp valueForKey:@"question"] Answer:[resp valueForKey:@"answer"] responseGroup:nil Value:[resp valueForKey:@"value"]];
        }
        
        if (![found valueForKey:@"pId"]) {
            [found setValue:self.event.pId forKey:@"pId"];
        }
        
        if (![found valueForKey:@"personId"]) {
            [found setValue:self.event.contact.personId forKey:@"personId"];
        }
        
        SurveyResponseSetRelationship* srsr = [[SurveyResponseSetRelationship alloc] initWithSurvey:s responseSet:found];
        [assoc addObject:srsr];
    }

    [[ResponseSet currentContext] save:nil];

    return assoc;
}

@end
