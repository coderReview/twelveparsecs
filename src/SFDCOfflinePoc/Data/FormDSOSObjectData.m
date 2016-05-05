//
//  FormDSOSObjectData.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "FormDSOSObjectData.h"
#import "FormDSOSObjectDataSpec.h"
#import "SObjectData+Internal.h"
#import <SmartSync/SFSmartSyncConstants.h>

@implementation FormDSOSObjectData

+ (SObjectDataSpec *)dataSpec {
    static FormDSOSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[FormDSOSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSString *)name {
    return [self nonNullFieldValue:kFormDSONameField];
}

- (void)setName:(NSString *)name {
    [self updateSoupForFieldName:kFormDSONameField fieldValue:name];
}

- (NSString *)code {
    return [self nonNullFieldValue:kFormDSOCodeField];
}

- (void)setCode:(NSString *)code {
    [self updateSoupForFieldName:kFormDSOCodeField fieldValue:code];
}

- (NSString *)locationName {
    return [self nonNullFieldValue:kFormDSOLocationNameField];
}

- (void)setLocationName:(NSString *)locationName {
    [self updateSoupForFieldName:kFormDSOLocationNameField fieldValue:locationName];
}

- (NSString *) shipTo {
    return [self nonNullFieldValue:kFormDSOShipToField];
}

- (void)setShipTo:(NSString *)shipTo {
    [self updateSoupForFieldName:kFormDSOShipToField fieldValue:shipTo];
}


@end
