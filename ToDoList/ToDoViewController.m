//
//  ViewController.m
//  ToDoList
//
//  Created by JETSMobileLabMini2 on 17/04/2024.
//

#import "ToDoViewController.h"
#import "DetailsViewController.h"
#import "Task.h"

@interface ToDoViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *toDoTable;
@property NSUserDefaults *userDefault;
@property NSMutableArray *taskList;
@property NSMutableArray *filteredList;
@property Task* task ;
@property NSData *decoded;
@property (weak, nonatomic) IBOutlet UIImageView *emptyImage;



@property Boolean isFiltered;

@end

@implementation ToDoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userDefault = [NSUserDefaults standardUserDefaults];
    _decoded = [_userDefault objectForKey:@"taskList"];
    _taskList = [NSMutableArray new];
  
    _task = [Task new];
    _toDoTable.delegate = self;
    _toDoTable.dataSource = self;
    _searchBar.delegate = self;


}


- (void)viewWillAppear:(BOOL)animated{
    UIViewController * view = self.navigationController.visibleViewController;
    view.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
     target:self
     action:@selector(performAdd:)];
     view.navigationItem.title = @"ToDo";
    _decoded = [_userDefault objectForKey:@"todoList"];
    _taskList = [NSKeyedUnarchiver unarchiveObjectWithData:_decoded];
    _task = [Task new];
    _isFiltered =NO;
  
    [_toDoTable reloadData];
}

//Add Task
- (void) performAdd:(id)paramSender{
    DetailsViewController *detailsViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"addTask"];
    detailsViewController.source = 1;
    detailsViewController.process = 1;
    [self.navigationController pushViewController:detailsViewController animated:YES];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    if(_isFiltered == NO) {
        _task = [_taskList objectAtIndex:indexPath.row];
    }else{
        _task = [_filteredList objectAtIndex:indexPath.row];
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
//
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    if(_isFiltered == NO){
        return  _taskList.count;
    }else{
        return _filteredList.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_taskList.count == 0){
        _emptyImage.image = [UIImage imageNamed:@"toDoImage2"];
    }else{
        _emptyImage.image = nil;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController *detailsViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"addTask"];
    printf("enter from todo to edit");
   
    if(_isFiltered == YES){
        Task * tempTask = [_filteredList objectAtIndex: indexPath.row];
        for (int i = 0; i<_taskList.count; i++) {
            if(tempTask == [_taskList objectAtIndex:i]){
                detailsViewController.objectIndex = i;
                break;
            }
        }
    }else{
        detailsViewController.objectIndex = indexPath.row;
    }
    detailsViewController.source = 1;
    detailsViewController.process = 2;
    [self.navigationController pushViewController:detailsViewController animated:YES];
    
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction *btnDelete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self confirmationAlert:indexPath.row];
    }];
    btnDelete.image = [UIImage systemImageNamed:@"trash"];

    
    UISwipeActionsConfiguration *cellConfigration  = [UISwipeActionsConfiguration configurationWithActions:@[btnDelete/*,btnEdit]*/]];
    cellConfigration.performsFirstActionWithFullSwipe = NO;
    return cellConfigration;
}

-(void) confirmationAlert:(int) index{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Deletion" message:@"Are you sure you wantto delete?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(_filteredList == YES){
            [_filteredList removeObjectAtIndex:index];
            Task * tempTask = [_filteredList objectAtIndex: index];
            for (int i = 0; i<_taskList.count; i++) {
                if(tempTask == [_taskList objectAtIndex:i]){
                    [_taskList removeObjectAtIndex:i];
                    break;
                }
            }
        }else{
            [_taskList removeObjectAtIndex:index];
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_taskList];
        [_userDefault setObject:data forKey:@"todoList"];
        [_toDoTable reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterContentForSearchText:searchText];
}

-(void) filterContentForSearchText : (NSString *) searchText{
    if(searchText.length == 0){
        _isFiltered = NO;
    }else{
        _isFiltered = YES;
        _filteredList =  [NSMutableArray new];
        for (Task *task in _taskList) {
            NSRange range = [task.taskTitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [_filteredList addObject:task];
            }
        }
    }
    [_toDoTable reloadData];
}


@end
