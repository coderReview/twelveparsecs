//
//  FormRequestSObjectDataSpec.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SObjectDataSpec.h"

extern NSString * const kFormRequestDSOField;
extern NSString * const kFormRequestRejectionReasonField;
extern NSString * const kFormRequestRequestDateField;
extern NSString * const kFormRequestReviewerTimeField;
extern NSString * const kFormRequestApprovalTimeField;
extern NSString * const kFormRequestStatusField;
extern NSString * const kFormRequestTotalAmountField;
extern NSString * const kFormRequestApprovalField;
extern NSString * const kFormRequestReviewerField;
extern NSString * const kFormRequestRequestLinesField;
extern NSString * const kFormRequestFormLinesField;

/**
 * Object to hold Form Request data specification.
 *
 * @author pvmagacho
 * @version 1.0
 */
@interface FormRequestSObjectDataSpec : SObjectDataSpec

@end
