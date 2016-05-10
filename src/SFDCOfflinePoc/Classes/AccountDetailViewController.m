//
//  AccountDetailViewController.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "AccountDetailViewController.h"
#import "AccountSObjectDataSpec.h"

@interface AccountDetailViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) AccountSObjectData *contact;
@property (nonatomic, strong) SObjectDataManager *dataMgr;
@property (nonatomic, copy) void (^saveBlock)(void);

@property (nonatomic, strong) NSArray *dataRows;
@property (nonatomic, strong) NSArray *contactDataRows;
@property (nonatomic, strong) NSArray *deleteButtonDataRow;

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL contactUpdated;
@property (nonatomic, assign) BOOL isNewAccount;

@end

@implementation AccountDetailViewController

- (id)initForNewAccountWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    return [self initWithAccount:nil dataManager:dataMgr saveBlock:saveBlock];
}

- (id)initWithAccount:(AccountSObjectData *)contact dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (contact == nil) {
            self.isNewAccount = YES;
            self.contact = [[AccountSObjectData alloc] init];
        } else {
            self.isNewAccount = NO;
            self.contact = contact;
        }
        self.dataMgr = dataMgr;
        self.saveBlock = saveBlock;
        self.isEditing = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.dataRows = [self dataRowsFromAccount];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self configureInitialBarButtonItems];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView setAllowsSelection:NO];

    if (self.isNewAccount) {
        [self editAccount];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.contactUpdated && self.saveBlock != NULL) {
        dispatch_async(dispatch_get_main_queue(), self.saveBlock);
    }
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataRows count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AccountDetailCellIdentifier";
    
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section < [self.contactDataRows count]) {
        if (self.isEditing) {
            cell.textLabel.text = nil;
            UITextField *editField = self.dataRows[indexPath.section][3];
            editField.frame = cell.contentView.bounds;
            [self contactTextFieldAddLeftMargin:editField];
            [cell.contentView addSubview:editField];
        } else {
            UITextField *editField = self.dataRows[indexPath.section][3];
            [editField removeFromSuperview];
            NSString *rowValueData = self.dataRows[indexPath.section][2];
            cell.textLabel.text = rowValueData;
        }
    } else {
        UIButton *deleteButton = self.dataRows[indexPath.section][1];
        deleteButton.frame = cell.contentView.bounds;
        [cell.contentView addSubview:deleteButton];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataRows[section][0];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self deleteAccount];
    }
}

#pragma mark - Private methods

- (void)configureInitialBarButtonItems {
    if (self.isNewAccount) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAccount)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAccount)];
    }
    self.navigationItem.leftBarButtonItem = nil;
}

- (NSArray *)dataRowsFromAccount {
    
    self.contactDataRows = @[ @[ @"Name",
                                 kObjectNameField,
                                 [[self class] emptyStringForNullValue:self.contact.name],
                                 [self contactTextField:self.contact.name] ],
                              @[ @"HCP Id",
                                 kAccountHCPIdField,
                                 [[self class] emptyStringForNullValue:self.contact.hcpId],
                                 [self contactTextField:self.contact.hcpId] ],
                              @[ @"Hospital / Clinic",
                                 kAccountHospitalField,
                                 [[self class] emptyStringForNullValue:self.contact.hospitalClinic],
                                 [self contactTextField:self.contact.hospitalClinic] ],
                              @[ @"Specialty",
                                 kAccountSpecialtyField,
                                 [[self class] emptyStringForNullValue:self.contact.specialty],
                                 [self contactTextField:self.contact.specialty] ]
                              ];
    self.deleteButtonDataRow = @[ @"", [self deleteButtonView] ];
    
    NSMutableArray *workingDataRows = [NSMutableArray array];
    [workingDataRows addObjectsFromArray:self.contactDataRows];
    if (!self.isNewAccount) {
        [workingDataRows addObject:self.deleteButtonDataRow];
    }
    return workingDataRows;
}

- (void)editAccount {
    self.isEditing = YES;
    if (!self.isNewAccount) {
        // Buttons will already be set for new contact case.
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditAccount)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAccount)];
    }
    [self.tableView reloadData];
    __weak AccountDetailViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.dataRows[0][3] becomeFirstResponder];
    });
}

- (void)cancelEditAccount {
    self.isEditing = NO;
    [self configureInitialBarButtonItems];
    [self.tableView reloadData];
}

- (void)saveAccount {
    [self configureInitialBarButtonItems];
    
    self.contactUpdated = NO;
    for (NSArray *fieldArray in self.contactDataRows) {
        NSString *fieldName = fieldArray[1];
        NSString *origFieldData = fieldArray[2];
        NSString *newFieldData = ((UITextField *)fieldArray[3]).text;
        if (![newFieldData isEqualToString:origFieldData]) {
            [self.contact updateSoupForFieldName:fieldName fieldValue:newFieldData];
            self.contactUpdated = YES;
        }
    }
    
    if (self.contactUpdated) {
        if (self.isNewAccount) {
            [self.dataMgr createLocalData:self.contact];
        } else {
            [self.dataMgr updateLocalData:self.contact];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.tableView reloadData];
    }
    
}

- (void)deleteAccountConfirm {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this contact?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)deleteAccount {
    [self.dataMgr deleteLocalData:self.contact];
    self.contactUpdated = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextField *)contactTextField:(NSString *)propertyValue {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.text = propertyValue;
    return textField;
}

- (UIButton *)deleteButtonView {
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setTitle:@"Delete Account" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    deleteButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [deleteButton addTarget:self action:@selector(deleteAccountConfirm) forControlEvents:UIControlEventTouchUpInside];
    return deleteButton;
}

- (void)contactTextFieldAddLeftMargin:(UITextField *)textField {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, textField.frame.size.height)];
    leftView.backgroundColor = textField.backgroundColor;
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (NSString *)emptyStringForNullValue:(id)origValue {
    if (origValue == nil || origValue == [NSNull null]) {
        return @"";
    } else {
        return origValue;
    }
}

@end
