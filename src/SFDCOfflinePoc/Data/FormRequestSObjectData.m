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

+ (SObjectDataSpec *)dataSpec {
    static FormRequestSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[FormRequestSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSString *)dsoId {
    return [self nonNullFieldValue:kFormRequestDSOField];
}

- (void)setDsoId:(NSString *)dsoId {
    [self updateSoupForFieldName:kFormRequestDSOField fieldValue:dsoId];
}

- (NSString *)rejectionReason {
    return [self nonNullFieldValue:kFormRequestRejectionReasonField];
}

- (void)setRejectionReason:(NSString *)rejectionReason {
    [self updateSoupForFieldName:kFormRequestRejectionReasonField fieldValue:rejectionReason];
}

- (NSString *)requestDate {
    return [self nonNullFieldValue:kFormRequestRequestDateField];
}

- (void)setRequestDate:(NSString *)requestDate {
    [self updateSoupForFieldName:kFormRequestRequestDateField fieldValue:requestDate];
}

- (NSString *)approvalTime {
    return [self nonNullFieldValue:kFormRequestApprovalTimeField];
}

- (void)setApprovalTime:(NSString *)approvalTime {
    [self updateSoupForFieldName:kFormRequestApprovalTimeField fieldValue:approvalTime];
}

- (NSString *)reviewerTime {
    return [self nonNullFieldValue:kFormRequestReviewerTimeField];
}

- (void)setReviewerTime:(NSString *)reviewerTime {
    [self updateSoupForFieldName:kFormRequestReviewerTimeField fieldValue:reviewerTime];
}

- (NSString *)status {
    return [self nonNullFieldValue:kFormRequestStatusField];
}

- (void)setStatus:(NSString *)status {
    [self updateSoupForFieldName:kFormRequestStatusField fieldValue:status];
}

- (NSString *)totalAmount {
    return [self nonNullFieldValue:kFormRequestTotalAmountField];
}

- (NSString *)approverId {
    return [self nonNullFieldValue:kFormRequestApprovalField];
}

- (void)setApproverId:(NSString *)approverId {
    [self updateSoupForFieldName:kFormRequestApprovalField fieldValue:approverId];
}

- (NSString *)reviewerId {
    return [self nonNullFieldValue:kFormRequestReviewerField];
}

- (void)setReviewerId:(NSString *)reviewerId {
    [self updateSoupForFieldName:kFormRequestReviewerField fieldValue:reviewerId];
}

- (NSMutableArray *)formLines {
    return [self nonNullFieldValue:kFormRequestFormLinesField];
}

- (void)setFormLines:(NSMutableArray *)formLines {
    [self updateSoupForFieldName:kFormRequestFormLinesField fieldValue:formLines];
}


@end
