//
//  ProductSObjectData.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "ProductSObjectData.h"
#import "ProductSObjectDataSpec.h"
#import "SObjectData+Internal.h"
#import <SmartSync/SFSmartSyncConstants.h>

@implementation ProductSObjectData

+ (SObjectDataSpec *)dataSpec {
    static ProductSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[ProductSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSNumber *)amount {
    return [self nonNullFieldValue:kProductAmountField];
}

- (void)setAmount:(NSNumber *)amount {
    [self updateSoupForFieldName:kProductAmountField fieldValue:amount];
}

- (NSString *)code {
    return [self nonNullFieldValue:kProductCodeField];
}

- (void)setCode:(NSString *)code {
    [self updateSoupForFieldName:kProductCodeField fieldValue:code];
}

- (NSNumber *)version {
    return [self nonNullFieldValue:kProductVersionField];
}

- (void)setVersion:(NSNumber *)version {
    [self updateSoupForFieldName:kProductVersionField fieldValue:version];
}

@end
