//
//  Configuration.h
//  NCSMobile
//
//  Created by John Dzak on 1/16/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationConfiguration : NSObject {
    @private
    NSString* _coreURL;
    NSString* _clientId;
}

#pragma mark properties

@property(nonatomic,retain) NSString* coreURL;

@property(nonatomic,retain) NSString* clientId;


#pragma Methods

+ (ApplicationConfiguration*) instance;


@end
