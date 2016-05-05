//
//  FormRequestSObjectData.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SObjectData.h"

/**
 * Object to hold Form Request information.
 *
 * @author pvmagacho
 * @version 1.0
 */
@interface FormRequestSObjectData : SObjectData

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *dsoId;
@property (nonatomic, copy) NSString *rejectionReason;
@property (nonatomic, copy) NSString *requestDate;
@property (nonatomic, copy) NSString *approvalTime;
@property (nonatomic, copy) NSString *reviewerTime;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSNumber *totalAmount;
@property (nonatomic, copy) NSString *approverId;
@property (nonatomic, copy) NSString *reviewerId;
@property (nonatomic, strong) NSMutableArray *formLines;

@end
