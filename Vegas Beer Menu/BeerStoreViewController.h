// Developed by: Steven Aten
// GitHub MIT License
//

#import <UIKit/UIKit.h>
#import "BeerAppDelegate.h"

@interface BeerStoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) BeerAppDelegate *app;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *randBtn;

@end
