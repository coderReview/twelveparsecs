//
//  SampleRequestSObjectDataSpec.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestSObjectDataSpec.h"
#import "SampleRequestSObjectData.h"

NSString * const kSampleRequestAccountQuery             = ADD_NAMESPACE(@"HCP_Customer__r.Name");
NSString * const kSampleRequestAccountQueryField        = ADD_NAMESPACE(@"HCP_Customer__r");
NSString * const kSampleRequestAccountField             = ADD_NAMESPACE(@"HCP_Customer__c");
NSString * const kSampleRequestProductQuery             = ADD_NAMESPACE(@"KSRA_Product__r.Name");
NSString * const kSampleRequestProductQueryField        = ADD_NAMESPACE(@"KSRA_Product__r");
NSString * const kSampleRequestProductField             = ADD_NAMESPACE(@"KSRA_Product__c");
NSString * const kSampleRequestQuantityField            = ADD_NAMESPACE(@"Quantity__c");
NSString * const kSampleRequestStatusField              = ADD_NAMESPACE(@"Status__c");
NSString * const kSampleRequestFormRequestField         = ADD_NAMESPACE(@"Form_Request__c");

@implementation SampleRequestSObjectDataSpec

- (id)init {
    NSString *objectType = ADD_NAMESPACE(@"KSRA_Request_Line_Item__c");
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestAccountQuery searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestAccountField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestProductQuery searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestProductField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestQuantityField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestStatusField searchable:NO]
                                   ];
    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestAccountField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestProductField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestQuantityField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestFormRequestField searchable:NO]
                                   ];

    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kObjectNameField indexType:kSoupIndexTypeString
                                                    columnName:kObjectNameField]
                             ];

    self.whereClause = [NSString stringWithFormat:@"OwnerId = '%@'", [self.class currentUserID]];

    NSString *soupName = @"SampleRequests";
    NSString *orderByFieldName = kObjectNameField;
    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[SampleRequestSObjectData alloc] initWithSoupDict:soupDict];
}

@end
