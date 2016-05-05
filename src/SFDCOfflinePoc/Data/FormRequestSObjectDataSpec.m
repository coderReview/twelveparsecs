//
//  FormRequestSObjectDataSpec.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "FormRequestSObjectDataSpec.h"
#import "FormRequestSObjectData.h"

NSString * const kFormRequestNameField              = @"Name";
NSString * const kFormRequestDSOQuery               = ADD_NAMESPACE(@"DSO__r.Name");
NSString * const kFormRequestDSOQueryField          = ADD_NAMESPACE(@"DSO__r");
NSString * const kFormRequestDSOField               = ADD_NAMESPACE(@"DSO__c");
NSString * const kFormRequestRejectionReasonField   = ADD_NAMESPACE(@"Rejection_Reason__c");
NSString * const kFormRequestRequestDateField       = ADD_NAMESPACE(@"Request_Date__c");
NSString * const kFormRequestReviewerTimeField      = ADD_NAMESPACE(@"Reviewer_Time__c");
NSString * const kFormRequestApprovalTimeField      = ADD_NAMESPACE(@"Approval_Time__c");
NSString * const kFormRequestStatusField            = ADD_NAMESPACE(@"Status__c");
NSString * const kFormRequestTotalAmountField       = ADD_NAMESPACE(@"Total_Amount__c");
NSString * const kFormRequestApprovalField          = ADD_NAMESPACE(@"Approver__c");
NSString * const kFormRequestReviewerField          = ADD_NAMESPACE(@"Reviewer__c");

@implementation FormRequestSObjectDataSpec

- (id)init {
    NSString *objectType = ADD_NAMESPACE(@"KSRA_Form_Request__c");
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestDSOField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestDSOQuery searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestRejectionReasonField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestRequestDateField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestReviewerTimeField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestApprovalTimeField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestStatusField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestTotalAmountField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestApprovalField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestReviewerField searchable:NO]
                                   ];
    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestNameField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestStatusField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestApprovalField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kFormRequestReviewerField searchable:NO]
                                   ];

    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kFormRequestNameField indexType:kSoupIndexTypeString
                                                    columnName:kFormRequestNameField]
                             ];

    self.whereClause = nil;

    NSString *soupName = @"FormRequests";
    NSString *orderByFieldName = kFormRequestNameField;
    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[FormRequestSObjectData alloc] initWithSoupDict:soupDict];
}

@end
