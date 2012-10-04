//
//  SurveySeries.h
//  NCSNavField
//
//  Created by John Dzak on 10/1/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResponseSet;
@class Participant;
@class NUSurvey;

@interface SurveySet : NSObject {
    NSArray* _surveys;
    NSArray* _responseSets;
    Participant* _participant;
    NSArray* _prepopulatedQuestionRefs;
}

@property(nonatomic,retain) NSArray* surveys;

@property(nonatomic,retain) NSArray* responseSets;

@property(nonatomic,retain) Participant* participant;

@property(nonatomic,retain) NSArray* prepopulatedQuestionRefs;

#pragma mark - Instance Methods

- (id)initWithSurveys:(NSArray*)s andResponseSets:(NSArray*)rs forParticipant:(Participant*)p;

- (ResponseSet*)generateResponseSetForSurveyId:(NSString*)surveyId;

- (ResponseSet*)populateResponseSet:(ResponseSet*)rs forSurveyId:sid;

- (NSDictionary*) questionDictByRefIdForSurvey:(NUSurvey*)survey;

- (NSArray*) defaultPrepopulatedQuestionRefs;

@end

#pragma mark - PrepopulatedQuestionRef

@interface PrepopulatedQuestionRef : NSObject {
    NSString* _referenceIdentifier;
    NSString* _dataExportIdentifier;
}

@property(nonatomic,retain) NSString* referenceIdentifier;

@property(nonatomic,retain) NSString* dataExportIdentifier;

- (id)initWithReferenceIdentifier:(NSString*)rid dataExportIdentifier:(NSString*)dai;

@end

#pragma mark - QuestionRef

@interface QuestionRef : NSObject {
    NSString* _attribute;
    NSString* _value;
}

@property(nonatomic,retain) NSString* attribute;

@property(nonatomic,retain) NSString* value;

- (id)initWithAttribute:(NSString*)attr value:(NSString*)value;

@end