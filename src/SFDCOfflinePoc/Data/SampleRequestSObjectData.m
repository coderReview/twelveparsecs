//
//  SampleRequestSObjectData.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestSObjectData.h"
#import "SampleRequestSObjectDataSpec.h"
#import "SObjectData+Internal.h"
#import <SmartSync/SFSmartSyncConstants.h>

@implementation SampleRequestSObjectData

+ (SObjectDataSpec *)dataSpec {
    static SampleRequestSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[SampleRequestSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSString *)accountId {
    return [self nonNullFieldValue:kSampleRequestAccountField];
}

- (void)setAccountId:(NSString *)accountId {
    [self updateSoupForFieldName:kSampleRequestAccountField fieldValue:accountId];
}

- (NSString *)accountName {
    return [[self nonNullFieldValue:kSampleRequestAccountQueryField] objectForKey:@"Name"];
}

- (NSString *)productId {
    return [self nonNullFieldValue:kSampleRequestProductField];
}

- (void)setProductId:(NSString *)productId {
    [self updateSoupForFieldName:kSampleRequestProductField fieldValue:productId];
}

- (NSString *)productName {
    return [[self nonNullFieldValue:kSampleRequestProductQueryField] objectForKey:@"Name"];
}

- (NSString *)quantity {
    return [self nonNullFieldValue:kSampleRequestQuantityField];
}

- (void)setQuantity:(NSString *)quantity {
    [self updateSoupForFieldName:kSampleRequestQuantityField fieldValue:quantity];
}

- (NSString *)status {
    return [self nonNullFieldValue:kSampleRequestStatusField];
}

- (void)setStatus:(NSString *)status {
    [self updateSoupForFieldName:kSampleRequestStatusField fieldValue:status];
}

- (NSString *)formRequestId {
    return [self nonNullFieldValue:kSampleRequestFormRequestField];
}

- (void)setFormRequestId:(NSString *)formRequestId {
    [self updateSoupForFieldName:kSampleRequestFormRequestField fieldValue:formRequestId];
}

@end
