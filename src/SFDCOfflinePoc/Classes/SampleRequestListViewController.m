//
//  SampleRequestListViewController.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestListViewController.h"

#import "ActionsPopupController.h"
#import "SObjectDataManager.h"
#import "SampleRequestDetailViewController.h"
#import "SampleRequestSObjectDataSpec.h"
#import "SampleRequestSObjectData.h"
#import "FormRequestSObjectDataSpec.h"
#import "FormRequestSObjectData.h"
#import "FormDSOSObjectDataSpec.h"
#import "FormDSOSObjectData.h"
#import "AccountSObjectData.h"
#import "ProductSObjectData.h"
#import "DSOPopupController.h"
#import "WYPopoverController.h"
#import <SalesforceSDKCore/SFDefaultUserManagementViewController.h>
#import <SmartStore/SFSmartStoreInspectorViewController.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceSDKCore/SFSecurityLockout.h>
#import <SmartSync/SFSmartSyncSyncManager.h>
#import <SmartSync/SFSyncState.h>

static NSString * const kNavBarTitleText                = @"Sample Requests";
static NSUInteger const kProductTitleTextColor          = 0x696969;
static CGFloat    const kProductTitleFontSize           = 15.0;
static CGFloat    const kProductDetailFontSize          = 13.0;

@interface SampleRequestListViewController () <UISearchBarDelegate>

@property (nonatomic, strong) WYPopoverController *popOverController;
@property (nonatomic, strong) UIActionSheet *logoutActionSheet;

// View / UI properties
@property (nonatomic, strong) UILabel *navBarLabel;
@property (nonatomic, strong) UIBarButtonItem *syncButton;
@property (nonatomic, strong) UIBarButtonItem *addButton;

// Data properties
@property (nonatomic, strong) NSMutableArray *filtereDataRows;
@property (nonatomic, strong) FormRequestSObjectData *formRequestObject;
@property (nonatomic, strong) FormDSOSObjectData *dsoObject;

@end

@implementation SampleRequestListViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filtereDataRows = [NSMutableArray array];

        self.dataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[SampleRequestSObjectData dataSpec]];
        self.formRequestDataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[FormRequestSObjectData dataSpec]];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.filtereDataRows = [NSMutableArray array];

        if (!self.dataMgr) {
            self.dataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[SampleRequestSObjectData dataSpec]];
            self.formRequestDataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[FormRequestSObjectData dataSpec]];
            self.formDSODataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[FormDSOSObjectData dataSpec]];
        }
        [self.dataMgr refreshLocalData];
        [self.formRequestDataMgr refreshLocalData];
        [self.formDSODataMgr refreshLocalData];

        if ([self.dataMgr.dataRows count] == 0)
            [self.dataMgr refreshRemoteData];

        [self.formRequestDataMgr refreshRemoteData];

        [self.formDSODataMgr refreshRemoteData:^(SFSyncState* sync) {
            if ([sync isDone] || [sync hasFailed]) {
                [self updateDSO];
            }
        }];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    self.formHeader.hidden = NO;

    [self updateDSO];

    self.navigationController.navigationBar.barTintColor = [[self class] colorFromRgbHexValue:kNavBarTintColor];

    // Nav bar label
    self.navBarLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.navBarLabel.text = kNavBarTitleText;
    self.navBarLabel.textAlignment = NSTextAlignmentLeft;
    self.navBarLabel.textColor = [UIColor whiteColor];
    self.navBarLabel.backgroundColor = [UIColor clearColor];
    self.navBarLabel.font = [UIFont systemFontOfSize:kNavBarTitleFontSize];
    self.navigationItem.titleView = self.navBarLabel;

    // Navigation bar buttons
    self.addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addSampleRequest)];
    self.syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync"] style:UIBarButtonItemStylePlain target:self action:@selector(syncUpDown)];
    self.navigationItem.rightBarButtonItems = @[ self.syncButton, self.addButton ];
    for (UIBarButtonItem *bbi in self.navigationItem.rightBarButtonItems) {
        bbi.tintColor = [UIColor whiteColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.formRequestObject = [[FormRequestSObjectData alloc] init];
    self.formRequestObject.formLines = [NSMutableArray array];
    [self addSampleRequest];

    [self updateDSO];

    [self reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {

}

#pragma mark - Overload methods

/*!
 Reload all data.
 */
- (void)reloadData {
    [self.filtereDataRows removeAllObjects];
    [self.tableView reloadData];

    for (SampleRequestSObjectData *object in self.dataMgr.dataRows) {
        if (!object.ownerId || [object.ownerId isEqualToString:[SObjectDataSpec currentUserID]]) {
            [self.filtereDataRows addObject:object];
        } else {
            /*for (NSDictionary *user in object.userRecords) {
                NSString *userId = [user objectForKey:@"User__c"];
                if ([userId isEqualToString:[SObjectDataSpec currentUserID]]) {
                    [self.filtereDataRows addObject:object];
                    break;
                }
            }*/
        }
    }

    [super reloadData];
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.formRequestObject.formLines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SampleRequestListCellIdentifier";

    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    SampleRequestSObjectData *obj = [self.formRequestObject.formLines objectAtIndex:indexPath.row];
    cell.textLabel.text = @"Form line";
    cell.textLabel.font = [UIFont systemFontOfSize:kProductTitleFontSize];
    cell.detailTextLabel.text = @"Form line";
    cell.detailTextLabel.font = [UIFont systemFontOfSize:kProductDetailFontSize];
    cell.detailTextLabel.textColor = [[self class] colorFromRgbHexValue:kProductTitleTextColor];
    cell.imageView.image = nil;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // cell.accessoryView = [self accessoryViewForObject:obj];

    return cell;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return self.formRequestObject.formLines.count > 1;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.formRequestObject.formLines removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*SampleRequestSObjectData *account = [self.filtereDataRows objectAtIndex:indexPath.row];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kNavBarTitleText style:UIBarButtonItemStylePlain target:nil action:nil];
    SampleRequestDetailViewController *detailVc = [[SampleRequestDetailViewController alloc]
                                                   initWithSampleRequest:account dataManager:self.dataMgr
                                                   saveBlock:^{
                                                       [self.tableView beginUpdates];
                                                       [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                                                       [self.tableView endUpdates];
                                                   }];
    detailVc.accountMgr = self.accountDataMgr;
    detailVc.productMgr = self.productDataMgr;

    [self.navigationController pushViewController:detailVc animated:YES];*/
}

#pragma mark - Popover delegate

- (void)showOtherActions:(UIButton *)sender {
    if([self.popOverController isPopoverVisible]){
        [self.popOverController dismissPopoverAnimated:YES];
        return;
    }

    DSOPopupController *popoverContent = [[DSOPopupController alloc] initWithAppViewController:self
                                                                                              dsos:self.formDSODataMgr.dataRows];
    popoverContent.preferredContentSize = CGSizeMake(200,500);
    self.popOverController = [[WYPopoverController alloc] initWithContentViewController:popoverContent];

    [self.popOverController presentPopoverFromRect:sender.frame
                                            inView:sender.superview
                          permittedArrowDirections:WYPopoverArrowDirectionAny
                                          animated:YES
                                           options:WYPopoverAnimationOptionFade];
}

- (void)popoverOptionObjectSelected:(SObjectData *)object {
    self.dsoObject = (FormDSOSObjectData *) object;
    [self.popOverController dismissPopoverAnimated:YES];
    [self updateDSO];
}

#pragma mark - Private methods

- (void)addSampleRequest {
    [self.formRequestObject.formLines addObject:[[SampleRequestSObjectData alloc] init]];
    [self.tableView reloadData];
    /*self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kNavBarTitleText style:UIBarButtonItemStylePlain target:nil action:nil];
    SampleRequestDetailViewController *detailVc = [[SampleRequestDetailViewController alloc] initForNewSampleRequestWithDataManager:self.dataMgr saveBlock:^{
        [self.dataMgr refreshLocalData];
    }];
    detailVc.accountMgr = self.accountDataMgr;
    detailVc.productMgr = self.productDataMgr;

    [self.navigationController pushViewController:detailVc animated:YES];*/
}

- (void)updateDSO {
    for (UIView *view in self.formHeader.subviews) {
        [view removeFromSuperview];
    }

    FormDSOSObjectData *dsoObject = self.dsoObject ? self.dsoObject : [self.formDSODataMgr.dataRows firstObject];

    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20.0, 10.0, 200.0, 30.0);
    [btn1 setTitle:[NSString stringWithFormat:@"DSO: %@", dsoObject ? dsoObject.name : @""] forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor clearColor];
    btn1.titleLabel.font = [UIFont systemFontOfSize:kFormHeaderFontSize];
    [btn1 addTarget:self action:@selector(showOtherActions:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 10.0, 200.0, 30.0)];
    label2.text = [NSString stringWithFormat:@"Code: %@", dsoObject ? dsoObject.code : @""];
    label2.textAlignment = NSTextAlignmentLeft;
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.font = [UIFont systemFontOfSize:kFormHeaderFontSize];

    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(440.0, 10.0, 200.0, 30.0)];
    label3.text = [NSString stringWithFormat:@"Ship To: %@", dsoObject ? dsoObject.shipTo : @""];
    label3.textAlignment = NSTextAlignmentLeft;
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.font = [UIFont systemFontOfSize:kFormHeaderFontSize];

    [self.formHeader addSubview:btn1];
    [self.formHeader addSubview:label2];
    [self.formHeader addSubview:label3];
}

- (NSString *)formatSubtitle:(SampleRequestSObjectData *)sampleRequest {
    NSString *quantity = [sampleRequest.quantity stringValue];
    NSString *status = [sampleRequest.status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [NSString stringWithFormat:@"Account: %@ / Product: %@ / Qty: %@ / Status: %@ / Date: -",
            [self formatAccount:sampleRequest], [self formatProduct:sampleRequest], quantity, status];
}

- (NSString *)formatProduct:(SampleRequestSObjectData *) sampleRequest {
    ProductSObjectData *product = (ProductSObjectData *) [self.productDataMgr findById:sampleRequest.productId];
    return product ? product.name : (sampleRequest.productName ? sampleRequest.productName : @"");
}

- (NSString *)formatAccount:(SampleRequestSObjectData *) sampleRequest {
    AccountSObjectData *account = (AccountSObjectData *) [self.accountDataMgr findById:sampleRequest.accountId];
    return account ? account.name : (sampleRequest.accountName ? sampleRequest.accountName : @"");    
}

@end
