//
//  AccountDetailViewController.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountSObjectData.h"
#import "SObjectDataManager.h"

@interface AccountDetailViewController : UITableViewController <UITableViewDataSource>

/**
 Initialize a new contact detail view controller.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initForNewAccountWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

/**
 Initialize with an existing contact detail view controller.
 @param contact the current contact.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initWithAccount:(AccountSObjectData *)contact dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

@end
