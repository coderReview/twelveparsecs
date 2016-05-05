//
//  FormRequestSObjectData.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "FormRequestSObjectData.h"
#import "FormRequestSObjectDataSpec.h"
#import "SObjectData+Internal.h"
#import <SmartSync/SFSmartSyncConstants.h>

@implementation FormRequestSObjectData

@synthesize formLines;

+ (SObjectDataSpec *)dataSpec {
    static FormRequestSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[FormRequestSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSString *)name {
    return [self nonNullFieldValue:kFormRequestNameField];
}

- (void)setName:(NSString *)name {
    [self updateSoupForFieldName:kFormRequestNameField fieldValue:name];
}

@end
