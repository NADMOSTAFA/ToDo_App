//
//  DoneViewController.m
//  ToDoList
//
//  Created by JETSMobileLabMini2 on 17/04/2024.
//

#import "DoneViewController.h"
#import "Task.h"
#import "DetailsViewController.h"

@interface DoneViewController ()
@property (weak, nonatomic) IBOutlet UITableView *doneTable;
@property NSUserDefaults *userDefault;
@property NSMutableArray *taskList;
@property NSMutableArray *highList;
@property NSMutableArray *mediumList;
@property NSMutableArray *lowList;
@property Task* task ;
@property NSData *decoded;
@property Boolean *clickFilter;
@property NSInteger numberOfSections;

@property (weak, nonatomic) IBOutlet UIImageView *emptyImage;

@end

@implementation DoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userDefault = [NSUserDefaults standardUserDefaults];
    _doneTable.delegate = self;
    _doneTable.dataSource = self;
    _userDefault = [NSUserDefaults standardUserDefaults];
    _taskList = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated{
    printf("enter done viewWillAppear\n");
    _clickFilter = NO;
    _numberOfSections = 1;
    UIViewController * view = self.navigationController.visibleViewController;
    view.navigationItem.rightBarButtonItem.hidden = YES;
    view.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
     target:self
     action:@selector(performFilter:)];
    view.navigationItem.title = @"Done";
    _decoded = [_userDefault objectForKey:@"doneList"];
    _taskList = [NSKeyedUnarchiver unarchiveObjectWithData:_decoded];
    _highList = [NSMutableArray new];
    _mediumList = [NSMutableArray new];
    _lowList = [NSMutableArray new];
    _task = [Task new];
    [_doneTable reloadData];
}

- (void) performFilter:(id)paramSender{
        _clickFilter = !_clickFilter;
        if(_clickFilter == NO){
            _numberOfSections = 1;
        }else{
            _numberOfSections = 3;
            [_highList removeAllObjects];
            [_lowList removeAllObjects];
            [_mediumList removeAllObjects];
        }
    for (int i = 0; i<_taskList.count; i++) {
        _task =[_taskList objectAtIndex: i];
        NSLog(@"%@" , _task.taskPriority);
        if([_task.taskPriority  isEqual: @"High"]){
            [_highList addObject:_task];
        }else if ([_task.taskPriority  isEqual: @"Medium"]){
            [_mediumList addObject:_task];
        }else{
            [_lowList addObject:_task];
        }
    }
    printf("medium arr %lu\n" , _mediumList.count);
    printf("low arr %lu\n" , _lowList.count);
    printf("high arr %lu\n" , _highList.count);
    [_doneTable reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(_clickFilter == YES){
        switch (indexPath.section) {
            case 0:
                _task = [_highList objectAtIndex:indexPath.row];
                break;
            case 1:
                _task = [_mediumList objectAtIndex:indexPath.row];
                break;
                
            case 2:
                _task = [_lowList objectAtIndex:indexPath.row];
                break;
        }
    }else{
        _task = [_taskList objectAtIndex:indexPath.row];
    }
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    UILabel *title = (UILabel*) [cell viewWithTag:2];
    UIImageView  *taskImage = (UIImageView*) [cell viewWithTag:1];
    if([_task.taskPriority  isEqual: @"Low"]){
        taskImage.image = [UIImage imageNamed:@"green"];
    }else if ([_task.taskPriority  isEqual: @"High"]){
        taskImage.image = [UIImage imageNamed:@"red"];
    }else{
        taskImage.image = [UIImage imageNamed:@"blue"];
    }
    title.text = _task.taskTitle;
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    printf("hide");
    if (_clickFilter == YES) {
        switch (section) {
            case 0:
                if(_highList.count == 0){
                    printf("hide");
                    return  @"";
                }else{
                    return @"High";
                }
                break;
            case 1:
                if(_mediumList.count == 0){
                    return  @"";
                }else{
                    return @"Medium";
                }
                break;
                
            case 2:
                if(_lowList.count == 0){
                    return  @"";
                }else{
                    return @"Low";
                }
                break;
                
            default:
                return 0;
                break;
        }
    }else{
        return @"";
    }
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_clickFilter == NO){
        return _taskList.count;
    }else{
        switch (section) {
            case 0:
                return _highList.count;
                break;
            case 1:
                return _mediumList.count;
                break;
                
            case 2:
                return _lowList.count;
                break;
                
            default:
                return 0;
                break;
        }
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_taskList.count == 0){
        _emptyImage.image = [UIImage imageNamed:@"toDoImage2"];
    }else{
        _emptyImage.image = nil;
       
    }
    return _numberOfSections;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController *detailsViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"addTask"];
    printf("enter from todo to edit\n");
    if(_clickFilter == YES){
        switch (indexPath.section) {
            case 0:
                _task = [_highList objectAtIndex:indexPath.row];
                break;
            case 1:
                _task = [_mediumList objectAtIndex:indexPath.row];
                break;
                
            case 2:
                _task = [_lowList objectAtIndex:indexPath.row];
                break;
        }
        for (int i = 0 ; i< _taskList.count; i++) {
            Task * realTask = [_taskList objectAtIndex:i];
            if (realTask == _task) {
                detailsViewController.objectIndex = i;
                break;
            }
        }
    }else{
      detailsViewController.objectIndex = indexPath.row;
    }
    detailsViewController.source = 3;
    detailsViewController.process = 0;
    
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction *btnDelete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self confirmationAlert:indexPath];
       
        
    }];
    btnDelete.image = [UIImage systemImageNamed:@"trash"];
    UISwipeActionsConfiguration *cellConfigration  = [UISwipeActionsConfiguration configurationWithActions:@[btnDelete/*,btnEdit]*/]];
    cellConfigration.performsFirstActionWithFullSwipe = NO;
    return cellConfigration;
}

-(void) confirmationAlert:(NSIndexPath *) customeIndexPath{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Deletion" message:@"Are you sure you wantto delete?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if(self->_clickFilter == YES){
            switch (customeIndexPath.section) {
                case 0:
                    self->_task = [self->_highList objectAtIndex:customeIndexPath.row];
                    [_highList removeObjectAtIndex:customeIndexPath.row];
                    break;
                case 1:
                    self->_task = [_mediumList objectAtIndex:customeIndexPath.row];
                    [_mediumList removeObjectAtIndex:customeIndexPath.row];
                    break;
                    
                case 2:
                    self->_task = [self->_lowList objectAtIndex:customeIndexPath.row];
                    [_lowList removeObjectAtIndex:customeIndexPath.row];
                    break;
            }
            for (int i = 0 ; i< _taskList.count; i++) {
                Task * realTask = [_taskList objectAtIndex:i];
                if (realTask == _task) {
                    [_taskList removeObjectAtIndex:i];
                    break;
                }
            }
        }else{
            [_taskList removeObjectAtIndex:customeIndexPath.row];
        }
        
//      [_taskList removeObjectAtIndex:globalIndex];
//      [_highList removeObjectAtIndex:localIndex];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_taskList];
        [_userDefault setObject:data forKey:@"doneList"];
        [_doneTable reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
