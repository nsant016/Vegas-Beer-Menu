// Developed by: Nestor Santiago
// GitHub MIT License
//

#import <UIKit/UIKit.h>
#import "Beer.h"

@interface BeerDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *beerPhoto;
@property (weak, nonatomic) IBOutlet UILabel *alcoholVolumeLabel;
@property (weak, nonatomic) IBOutlet UITextView *brewerNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *beerDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *beerDetailScrollView;

@property (nonatomic, strong) Beer *beer;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *shareButton;
-(IBAction)shareButtonTouched:(id)sender;

@end
