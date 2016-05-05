//
//  FormDSOSObjectDataSpec.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "FormDSOSObjectDataSpec.h"
#import "FormDSOSObjectData.h"

NSString * const kFormDSONameField          = @"Name";
NSString * const kFormDSOCodeField          = ADD_NAMESPACE(@"Code__c");
NSString * const kFormDSOLocationNameField  = ADD_NAMESPACE(@"Location_name__c");
NSString * const kFormDSOShipToField        = ADD_NAMESPACE(@"Ship_To__c");

@implementation FormDSOSObjectDataSpec

- (id)init {
    NSString *objectType = ADD_NAMESPACE(@"KSRA_DSO__c");
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSONameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSOCodeField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSOLocationNameField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSOShipToField searchable:YES]
                                   ];
    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSONameField searchable:YES],
                                         [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSOCodeField searchable:YES],
                                         [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSOLocationNameField searchable:NO],
                                         [[SObjectDataFieldSpec alloc] initWithFieldName:kFormDSOShipToField searchable:YES]
                                   ];

    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kFormDSONameField indexType:kSoupIndexTypeString columnName:kFormDSONameField],
                             [[SFSoupIndex alloc] initWithPath:kFormDSOCodeField indexType:kSoupIndexTypeString columnName:kFormDSOCodeField]
                             ];
    NSString *soupName = @"FormDSOs";
    NSString *orderByFieldName = kFormDSONameField;
    
    self.whereClause = [NSString stringWithFormat:@"OwnerId = '%@'", [self.class currentUserID]];

    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[FormDSOSObjectData alloc] initWithSoupDict:soupDict];
}

@end
