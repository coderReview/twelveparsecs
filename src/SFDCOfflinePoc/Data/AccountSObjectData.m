/*
 Copyright (c) 2014, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  AccountSObjectData.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 5/1/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "AccountSObjectData.h"
#import "AccountSObjectDataSpec.h"
#import "SObjectData+Internal.h"
#import <SmartSync/SFSmartSyncConstants.h>

@implementation AccountSObjectData

+ (SObjectDataSpec *)dataSpec {
    static AccountSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[AccountSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSString *)hcpId {
    return [self nonNullFieldValue:kAccountHCPIdField];
}

- (void)setHcpId:(NSString *)hcpId {
    [self updateSoupForFieldName:kAccountHCPIdField fieldValue:hcpId];
}

- (NSString *)hospitalClinic {
    return [self nonNullFieldValue:kAccountHospitalField];
}

- (void)setHospitalClinic:(NSString *)hospitalClinic {
    [self updateSoupForFieldName:kAccountHospitalField fieldValue:hospitalClinic];
}

- (NSString *)specialty {
    return [self nonNullFieldValue:kAccountSpecialtyField];
}

- (void)setSpecialty:(NSString *)specialty {
    [self updateSoupForFieldName:kAccountSpecialtyField fieldValue:specialty];
}

- (NSString *)accountId {
    return [self nonNullFieldValue:kAccountSpecialtyField];
}

- (void)setAccountId:(NSString *)accountId {
    [self updateSoupForFieldName:kAccountAccountField fieldValue:accountId];
}

- (NSString *)accountName {
    return [[self nonNullFieldValue:kAccountAccountField] objectForKey:@"Name"];
}



@end
