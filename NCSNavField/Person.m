//
//  Person.m
//  NCSNavField
//
//  Created by John Dzak on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "NSString+Additions.h"
#import <MRCEnumerable/MRCEnumerable.h>
#import <NUSurveyor/NUUUID.h>

NSInteger const PERSON_RELATIONSHIP_CODE_SELF = 1;

@implementation Person

static const NSString* NEW_PERSON_NAME = @"New Person";

@dynamic cellPhone, city, email, firstName, homePhone, lastName, middleName, personId, prefixCode, relationshipCode, state, street, suffixCode, zipCode, participant;

+ (Person*)person {
    Person* p = [Person object];
    p.firstName = [self buildNewPersonName];
    p.personId = [NUUUID generateUuidString];
    p.relationshipCode = [NSNumber numberWithInt:PERSON_RELATIONSHIP_CODE_SELF];
    return p;
}

+ (NSString*)buildNewPersonName {
    NSInteger count = [self newPersonCount];
    return [NSString stringWithFormat:@"%@ #%d", NEW_PERSON_NAME, count + 1];
}

+ (NSInteger)newPersonCount {
    NSPredicate* p = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[c] %@", NEW_PERSON_NAME];
    return [[Person findAllWithPredicate:p] count];
}

- (NSString*)name {
    NSMutableArray* name = [NSMutableArray new];
    if (self.firstName) {
        [name addObject:self.firstName];
    }
    if (self.middleName) {
        [name addObject:self.middleName];
    }
    if (self.lastName) {
        [name addObject:self.lastName];
    }
    return [name componentsJoinedByString:@" "];
}
- (NSString*)addressLineOne {
    return [self.street isBlank] ? nil : self.street;
}

- (NSString*)addressLineTwo {
    NSArray* all = [NSArray arrayWithObjects:self.city, self.state, self.zipCode, nil];
    NSArray* filtered = [all reject:^BOOL(id obj) {
        return [obj isBlank];
    }];
    return [filtered empty] ? nil : [filtered componentsJoinedByString:@" "];
}

- (NSString*)formattedAddress {
    NSArray* all = [NSArray arrayWithObjects:[self addressLineOne], [self addressLineTwo], nil];
    NSArray* filtered = [all reject:^BOOL(id obj) {
        return [obj isBlank];
    }];
    return [filtered empty] ? nil : [filtered componentsJoinedByString:@"\n"];}

- (BOOL) isPersonSameAsParticipant {
    return [self.relationshipCode isEqualToNumber:[NSNumber numberWithInt:PERSON_RELATIONSHIP_CODE_SELF]];
}

@end
