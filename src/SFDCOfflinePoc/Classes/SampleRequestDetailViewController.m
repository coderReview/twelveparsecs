//
//  SampleRequestDetailViewController.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestDetailViewController.h"
#import "SampleRequestSObjectDataSpec.h"
#import "SampleRequestSObjectData.h"
#import "ProductSObjectData.h"
#import "AccountSObjectData.h"
#import "Helper.h"

#define kTagAccount 1000
#define kTagProduct 1001
#define kTagStatus 1002
#define kTagDeliveryDate 1003

@interface SampleRequestDetailViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) SampleRequestSObjectData *sampleRequest;
@property (nonatomic, strong) SObjectDataManager *dataMgr;
@property (nonatomic, copy) void (^saveBlock)(void);
@property (nonatomic, strong) NSArray *dataRows;
@property (nonatomic, strong) NSArray *sampleRequestDataRows;
@property (nonatomic, strong) NSArray *deleteButtonDataRow;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL sampleRequestUpdated;
@property (nonatomic, assign) BOOL isNewSampleRequest;

@property (nonatomic, assign) NSInteger editTextTag;
@property (nonatomic, strong) NSArray *statusArray;
@property (nonatomic, strong) AccountSObjectData *accountObject;
@property (nonatomic, strong) ProductSObjectData *productObject;

@property (nonatomic, strong) NSPredicate *accountPredicate;
@property (nonatomic, strong) NSPredicate *productPredicate;

// View / UI properties
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePickerView;
@property (nonatomic, strong) UIView *toastView;
@property (nonatomic, strong) UILabel *toastViewMessageLabel;

@end

@implementation SampleRequestDetailViewController {
    BOOL isCurrentUser;
}

@synthesize accountMgr, productMgr;

/**
 Initialize a new sample request detail view controller.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initForNewSampleRequestWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    return [self initWithSampleRequest:nil dataManager:dataMgr saveBlock:saveBlock];
}

/**
 Initialize with an existing sample request detail view controller.
 @param ample request the current product.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initWithSampleRequest:(SampleRequestSObjectData *)sampleRequest dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (sampleRequest == nil) {
            self.isNewSampleRequest = YES;
            self.sampleRequest = [[SampleRequestSObjectData alloc] init];
        } else {
            self.isNewSampleRequest = NO;
            self.sampleRequest = sampleRequest;
        }
        self.dataMgr = dataMgr;
        self.saveBlock = saveBlock;
        self.isEditing = NO;

        self.statusArray = @[ @"Requested", @"Scheduled", @"Delivered" ];

        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        self.pickerView.showsSelectionIndicator = YES;

        self.datePickerView = [[UIDatePicker alloc] init];
        self.datePickerView.datePickerMode = UIDatePickerModeDate;
        self.datePickerView.minimumDate = [NSDate date];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    // Toast view
    self.toastView = [[UIView alloc] initWithFrame:CGRectZero];
    self.toastView.backgroundColor = [UIColor colorWithRed:(38.0 / 255.0) green:(38.0 / 255.0) blue:(38.0 / 255.0) alpha:0.7];
    self.toastView.layer.cornerRadius = 10.0;
    self.toastView.alpha = 0.0;

    self.toastViewMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.toastViewMessageLabel.font = [UIFont systemFontOfSize:kToastMessageFontSize];
    self.toastViewMessageLabel.textColor = [UIColor whiteColor];
    [self.toastView addSubview:self.toastViewMessageLabel];
    [self.view addSubview:self.toastView];

    self.accountPredicate = [NSPredicate predicateWithBlock:^BOOL(AccountSObjectData *obj, NSDictionary *bindings) {
        return ![self.accountMgr dataLocallyCreated:obj];
    }];
    self.productPredicate = [NSPredicate predicateWithBlock:^BOOL(ProductSObjectData *obj, NSDictionary *bindings) {
        return ![self.productMgr dataLocallyCreated:obj];
    }];

    self.dataRows = [self dataRowsFromSampleRequest];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self configureInitialBarButtonItems];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    isCurrentUser = self.isNewSampleRequest || [self.sampleRequest.ownerId isEqualToString:[SObjectDataSpec currentUserID]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView setAllowsSelection:NO];

    self.accountObject = self.isNewSampleRequest ? [self.accountMgr.dataRows objectAtIndex:0] : [self.accountMgr findById:self.sampleRequest.accountId];
    self.productObject = self.isNewSampleRequest ? [self.productMgr.dataRows objectAtIndex:0] : [self.productMgr findById:self.sampleRequest.productId];

    if (self.isNewSampleRequest) {
        [self editSampleRequest];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.sampleRequestUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateRecord object:nil];

        if (self.saveBlock != NULL) {
            dispatch_async(dispatch_get_main_queue(), self.saveBlock);
        }
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
    static NSString *CellIdentifier = @"SampleRequestDetailCellIdentifier";

    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSArray *sampleRequestData = self.dataRows[indexPath.section];
    if (indexPath.section < [self.sampleRequestDataRows count]) {
        if (self.isEditing) {
            cell.textLabel.text = nil;
            UITextField *editField = sampleRequestData[3];
            editField.frame = cell.contentView.bounds;
            if (sampleRequestData[1] == kSampleRequestNameField) {
                editField.delegate = self; // will disable the text field
            } else if (sampleRequestData[1] == kSampleRequestQuantityField) {
                editField.keyboardType = UIKeyboardTypeNumberPad;
            }
            [self textFieldAddLeftMargin:editField];
            [cell.contentView addSubview:editField];
        } else {
            UITextField *editField = sampleRequestData[3];
            [editField removeFromSuperview];
            NSString *rowValueData = sampleRequestData[2];
            cell.textLabel.text = rowValueData;
        }
    } else {
        UIButton *deleteButton = sampleRequestData[1];
        deleteButton.frame = cell.contentView.bounds;
        [cell.contentView addSubview:deleteButton];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataRows[section][0];
}

#pragma mark - UIPickerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *value = nil;

    if (self.editTextTag == kTagAccount) {
        self.accountObject = [[self.accountMgr.dataRows filteredArrayUsingPredicate:self.accountPredicate] objectAtIndex:row];
        value = [self formatNameFromAccount:self.accountObject];
    } else if (self.editTextTag == kTagProduct) {
        self.productObject = [[self.productMgr.dataRows filteredArrayUsingPredicate:self.productPredicate] objectAtIndex:row];
        value = [self formatNameFromProduct:self.productObject];
    } else if (self.editTextTag == kTagStatus) {
        value = [self.statusArray objectAtIndex:row];
    }

    UITextField *textField = (UITextField *) [self.view viewWithTag:self.editTextTag];
    textField.text = value;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.editTextTag == kTagAccount) {
        return [self.accountMgr.dataRows filteredArrayUsingPredicate:self.accountPredicate].count;
    } else if (self.editTextTag == kTagProduct) {
        return [self.productMgr.dataRows filteredArrayUsingPredicate:self.productPredicate].count;
    } else if (self.editTextTag == kTagStatus) {
        return self.statusArray.count;
    }

    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow: (NSInteger)row forComponent:(NSInteger)component {
    if (self.editTextTag == kTagAccount) {
        AccountSObjectData *obj = [[self.accountMgr.dataRows filteredArrayUsingPredicate:self.accountPredicate] objectAtIndex:row];
        return [self formatNameFromAccount:obj];
    } else if (self.editTextTag == kTagProduct) {
        return [[[self.productMgr.dataRows filteredArrayUsingPredicate:self.productPredicate] objectAtIndex:row] name];
    } else if (self.editTextTag == kTagStatus) {
        return [self.statusArray objectAtIndex:row];
    }

    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return (isCurrentUser && textField.tag >= kTagAccount) && !(self.isNewSampleRequest && textField.tag == kTagDeliveryDate);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag < kTagAccount) {
        [textField resignFirstResponder];
    }

    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (![self textFieldShouldBeginEditing:textField]) {
        return;
    }

    self.editTextTag = textField.tag;
    if (self.editTextTag == kTagDeliveryDate) {
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        if (textField.text && textField.text.length > 0) {
            [self.datePickerView setDate:[f dateFromString:textField.text]];
        } else {
            [self.datePickerView setDate:[NSDate date]];
        }
        return;
    }

    NSInteger row = 0;
    [self.pickerView reloadAllComponents];
    [textField reloadInputViews];

    if (self.editTextTag == kTagAccount) {
        row = [[self.accountMgr.dataRows filteredArrayUsingPredicate:self.accountPredicate] indexOfObject:self.accountObject];
    } else if (self.editTextTag == kTagProduct) {
        row = [[self.productMgr.dataRows filteredArrayUsingPredicate:self.productPredicate] indexOfObject:self.productObject];
    } else if (self.editTextTag == kTagStatus) {
        row = [self.statusArray indexOfObject:textField.text];
    } else {
        return;
    }

    row = row == NSNotFound ? 0 : row;

    [self.pickerView selectRow:row inComponent:0 animated:NO];
    [self pickerView:self.pickerView didSelectRow:row inComponent:0];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self deleteSampleRequest];
    }
}

#pragma mark - Private methods

- (void)configureInitialBarButtonItems {
    if (self.isNewSampleRequest) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSampleRequest)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editSampleRequest)];
    }
    self.navigationItem.leftBarButtonItem = nil;
}

- (NSArray *)dataRowsFromSampleRequest {
    if (self.isNewSampleRequest) {
        self.sampleRequestDataRows = @[
                                  @[ @"Product",
                                     kSampleRequestProductField,
                                     [[self class] emptyStringForNullValue:[self formatNameFromProduct:self.productObject]],
                                     [self dataTextFieldPicker:[self formatNameFromProduct:self.productObject] tag:kTagProduct] ],
                                  @[ @"Quantity",
                                     kSampleRequestQuantityField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.quantity.stringValue],
                                     [self dataTextField:self.sampleRequest.quantity.stringValue] ],
                                  @[ @"Status",
                                     kSampleRequestStatusField,
                                     [[self class] emptyStringForNullValue:@"Requested"],
                                     [self dataTextField:@"Requested"] ]
                                  ];
    } else {
        self.sampleRequestDataRows = @[ @[ @"Name",
                                     kSampleRequestNameField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.name ? self.sampleRequest.name : @"Please sync"],
                                     [self dataTextField:self.sampleRequest.name ? self.sampleRequest.name : @"Please sync"] ],
                                  @[ @"Account",
                                     kSampleRequestAccountField,
                                     [[self class] emptyStringForNullValue:[self formatNameFromAccount:self.accountObject]],
                                     [self dataTextFieldPicker:[self formatNameFromAccount:self.accountObject] tag:kTagAccount] ],
                                  @[ @"Product",
                                     kSampleRequestProductField,
                                     [[self class] emptyStringForNullValue:[self formatNameFromProduct:self.productObject]],
                                     [self dataTextFieldPicker:[self formatNameFromProduct:self.productObject] tag:kTagProduct] ],
                                  @[ @"Quantity",
                                     kSampleRequestQuantityField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.quantity.stringValue],
                                     [self dataTextField:self.sampleRequest.quantity.stringValue] ],
                                  @[ @"Status",
                                     kSampleRequestStatusField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.status],
                                     [self dataTextFieldPicker:self.sampleRequest.status tag:kTagStatus] ]
                                 ];
    }

    self.deleteButtonDataRow = @[ @"", [self deleteButtonView] ];

    NSMutableArray *workingDataRows = [NSMutableArray array];
    [workingDataRows addObjectsFromArray:self.sampleRequestDataRows];
    if (!self.isNewSampleRequest) {
        [workingDataRows addObject:self.deleteButtonDataRow];
    }
    return workingDataRows;
}

- (void)editSampleRequest {
    self.isEditing = YES;
    if (!self.isNewSampleRequest) {
        // Buttons will already be set for new account case.
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditSampleRequest)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSampleRequest)];
    }

    [self.tableView setAllowsSelection:YES];
    [self.tableView reloadData];
    __weak SampleRequestDetailViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.accountObject) {
            UITextField *field = [self.view viewWithTag:kTagAccount];
            field.text = [self formatNameFromAccount:self.accountObject];
        }
        if (self.productObject) {
            UITextField *field = [self.view viewWithTag:kTagProduct];
            field.text = self.productObject.name;
        }

        [weakSelf.dataRows[0][3] becomeFirstResponder];
    });
}

- (void)cancelEditSampleRequest {
    [self.tableView setAllowsSelection:NO];
    self.isEditing = NO;
    [self configureInitialBarButtonItems];
    [self.tableView reloadData];
}

- (void)saveSampleRequest {
    [self configureInitialBarButtonItems];

    self.sampleRequestUpdated = NO;
    for (NSArray *fieldArray in self.sampleRequestDataRows) {
        NSString *fieldName = fieldArray[1];
        NSString *origFieldData = fieldArray[2];
        id newFieldData = ((UITextField *)fieldArray[3]).text;
        if ((self.isNewSampleRequest && newFieldData) || ![newFieldData isEqualToString:origFieldData]) {
            if ([fieldName isEqualToString:kSampleRequestAccountField]) {
                newFieldData = self.accountObject.objectId;
                if (!newFieldData) {
                    [Helper showToast:self.toastView message:@"Please select a account" label:self.toastViewMessageLabel];
                    return;
                }
            } else if ([fieldName isEqualToString:kSampleRequestProductField]) {
                newFieldData = self.productObject.objectId;
                if (!newFieldData) {
                    [Helper showToast:self.toastView message:@"Please select a product" label:self.toastViewMessageLabel];
                    return;
                }
            } else if ([fieldName isEqualToString:kSampleRequestQuantityField]) {
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                newFieldData = [f numberFromString:newFieldData];
                if (!newFieldData) {
                    [Helper showToast:self.toastView message:@"Please select a quantity" label:self.toastViewMessageLabel];
                    return;
                }
            }/* else if ([fieldName isEqualToString:kSampleRequestDeliveryDateField]) {
                NSString *date = newFieldData;
                if (!date || date.length == 0) {
                    continue;
                }
            }*/
            [self.sampleRequest updateSoupForFieldName:fieldName fieldValue:newFieldData];
            self.sampleRequestUpdated = YES;
        }
    }

    if (self.sampleRequestUpdated) {
        if (self.isNewSampleRequest) {
            [self.dataMgr createLocalData:self.sampleRequest];
        } else {
            [self.dataMgr updateLocalData:self.sampleRequest];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.tableView reloadData];
    }
}

- (void)deleteSampleRequestConfirm {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this sample request?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)deleteSampleRequest {
    [self.dataMgr deleteLocalData:self.sampleRequest];
    self.sampleRequestUpdated = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextField *)dataTextField:(NSString *)propertyValue {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.text = propertyValue;
    return textField;
}

- (UITextField *)dataTextFieldPicker:(NSString *)propertyValue tag:(NSInteger) tag {
    if (tag == kTagDeliveryDate) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.delegate = self;
        textField.tag = tag;
        textField.text = propertyValue;

        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone
                                                                      target:self action:@selector(pickerDone:)];
        UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                              CGRectMake(0, self.view.frame.size.height - self.datePickerView.frame.size.height - 50, 320, 50)];
        [toolBar setBarStyle:UIBarStyleDefault];
        [toolBar setItems:[NSArray arrayWithObjects:doneButton, nil]];

        textField.inputView = self.datePickerView;
        textField.inputAccessoryView = toolBar;

        return textField;
    }

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.delegate = self;
    textField.tag = tag;
    textField.text = propertyValue;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone
                                                                  target:self action:@selector(pickerDone:)];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, self.view.frame.size.height - self.pickerView.frame.size.height - 50, 320, 50)];
    [toolBar setBarStyle:UIBarStyleDefault];
    [toolBar setItems:[NSArray arrayWithObjects:doneButton, nil]];

    textField.inputView = self.pickerView;
    textField.inputAccessoryView = toolBar;

    return textField;
}

- (UIButton *)deleteButtonView {
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setTitle:@"Delete Sample Request" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    deleteButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [deleteButton addTarget:self action:@selector(deleteSampleRequestConfirm) forControlEvents:UIControlEventTouchUpInside];
    return deleteButton;
}

- (void)pickerDone:(id) sender {
    UITextField *textField = [self.view viewWithTag:self.editTextTag];
    if (self.editTextTag == kTagDeliveryDate) {
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        textField.text = [f stringFromDate:self.datePickerView.date];
    }

    [textField resignFirstResponder];
}

- (void)textFieldAddLeftMargin:(UITextField *)textField {
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

- (NSString *)formatNameFromProduct:(ProductSObjectData *)product {
    return product ? product.name : (self.sampleRequest.productName ? self.sampleRequest.productName : @"");
}

- (NSString *)formatNameFromAccount:(AccountSObjectData *)account {
    return account ? account.name : (self.sampleRequest.accountName ? self.sampleRequest.accountName : @"");
}

@end
