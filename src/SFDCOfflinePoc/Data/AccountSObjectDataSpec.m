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
//  AccountSObjectDataSpec.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 5/1/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "AccountSObjectDataSpec.h"
#import "AccountSObjectData.h"

NSString * const kAccountHCPIdField             = ADD_NAMESPACE(@"HCP_Id__c");
NSString * const kAccountHospitalField          = ADD_NAMESPACE(@"Hospital_Clinic__c");
NSString * const kAccountSpecialtyField         = ADD_NAMESPACE(@"Speciality__c");
NSString * const kAccountAccountQuery           = ADD_NAMESPACE(@"Account__r.Name");
NSString * const kAccountAccountQueryField      = ADD_NAMESPACE(@"Account__r");
NSString * const kAccountAccountField           = ADD_NAMESPACE(@"Account__c");

@implementation AccountSObjectDataSpec

- (id)init {
    NSString *objectType = ADD_NAMESPACE(@"GLBL_HCP_Customer__c");
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kAccountHCPIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kAccountHospitalField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kAccountSpecialtyField searchable:NO]
                                   ];

    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kAccountHCPIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kAccountHospitalField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kAccountSpecialtyField searchable:NO]
                                   ];
    
    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kObjectNameField indexType:kSoupIndexTypeString
                                                    columnName:kObjectNameField],
                             [[SFSoupIndex alloc] initWithPath:kAccountHCPIdField indexType:kSoupIndexTypeString
                                                    columnName:kAccountHCPIdField]
                             ];

    self.whereClause = [NSString stringWithFormat:@"OwnerId = '%@'", [self.class currentUserID]];

    NSString *soupName = @"GLBL_HCP_Customer";
    NSString *orderByFieldName = kObjectNameField;
    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[AccountSObjectData alloc] initWithSoupDict:soupDict];
}

@end
