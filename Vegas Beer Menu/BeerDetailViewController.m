// Developed by: Nestor Santiago
// GitHub MIT License
//

#import "BeerDetailViewController.h"
#import <Social/Social.h>

@interface BeerDetailViewController ()

@end

@implementation BeerDetailViewController

@synthesize beerPhoto, alcoholVolumeLabel, brewerNameLabel, beerDescriptionTextView;
@synthesize beer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.beerDetailScrollView setScrollEnabled:YES];
    [self.beerDetailScrollView setContentSize:(CGSizeMake(320, 800))];
    
    // Set the title of the view to the beer name
    self.title = [beer beerName];
    
    // Set the beer photo
    NSURL *imageURL = [NSURL URLWithString: [beer beerImageURL]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    self.beerPhoto.image = [UIImage imageWithData:imageData];
    
    // Set the alcohol volume
    self.alcoholVolumeLabel.text = [beer alcoholVolume];
    
    // Set the brewer name
    self.brewerNameLabel.text = [beer brewerName];
    
    // Set the beer description
    self.beerDescriptionTextView.text = [beer beerDescription];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Facebook Share FH
-(IBAction)shareButtonTouched:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController * controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Check out my Beer! "];
        NSURL *imageURL = [NSURL URLWithString:[beer beerImageURL]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        [controller addImage:[UIImage imageWithData:imageData]];
        
        [self presentViewController:controller animated:YES completion:NO];
        
    }
    [self.shareButton setStyle:UIBarButtonItemStylePlain];
}

@end
