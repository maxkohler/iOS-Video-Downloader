//
//  ViewController.m
//  InstagramDownloader
//
//  Created by max on 16/03/16.
//  Copyright © 2016 max kohler. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewForPlayer;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *saveButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *loadButtonOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *logo;



@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong)NSURLSession *backgroundSession;
@property (nonatomic, strong)NSString *getURL;
@property (strong, nonatomic) UIWebView* tempView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (nonatomic) NSInteger choice;
@property (nonatomic, strong) UIActivityIndicatorView* waitingIndicator;


- (IBAction)pasteUrlButton:(id)sender;
- (IBAction)saveButton:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _tempView = [[UIWebView alloc]init];
    _tempView.delegate = self;
    
    
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"BackgroundSessionIdentifier"];

    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    [self.progress setProgress:0 animated:NO];
    [[self saveButtonOutlet] setHidden:YES];
    [[self saveButtonOutlet] setEnabled:NO];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pasteUrlButton:(id)sender
{
    self.logo.image = nil;
    
    if(_moviePlayer != nil)
    {
        [_moviePlayer.view removeFromSuperview];
        
    }
    //in case you load a second video
    if(_saveButtonOutlet.isEnabled == YES)
    {
        [[self saveButtonOutlet] setEnabled:NO];
        [[self loadButtonOutlet] setEnabled:NO];
        
        [[self saveButtonOutlet] setHidden:YES];
    }
    
    [self showWaitingIndicator];
    [self.progress setProgress:0 animated:NO];
    
    UIPasteboard *thePasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteboardString = thePasteboard.string;
    

    if ([pasteboardString containsString:@"https://instagram.com/"])
    {
        self.choice = 0;
        NSURL *url = [NSURL URLWithString:pasteboardString];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        
        [_tempView loadRequest:(requestObj)];
        
        self.logo.image = [UIImage imageNamed: @"instagram_logo.png"];
        
        
    }
    else if ([pasteboardString containsString:@"https://vine.co/"])
    {
        self.choice = 1;
        NSURL *url = [NSURL URLWithString:pasteboardString];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        
        [_tempView loadRequest:(requestObj)];
        
        self.logo.image = [UIImage imageNamed: @"vine_logo.png"];
        
    }
    else
    {
        [self hideWaitingIndicator];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"Invalid Link" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (IBAction)saveButton:(id)sender
{
    [self.progress setProgress:0 animated:NO];
    
    //prevent other actions while saving
    if(_saveButtonOutlet.isEnabled == YES)
    {
        [[self saveButtonOutlet] setEnabled:NO];
        [[self loadButtonOutlet] setEnabled:NO];
    }
    
    self.downloadTask = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:_getURL]];
    [[self downloadTask] resume];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading)
        return;
    else
    {
        if(self.choice == 0)
        {
            NSString *js = [NSString stringWithFormat:@"($(\"[property='og:video']\").attr('content'));"];
            _getURL = [self.tempView stringByEvaluatingJavaScriptFromString:js];
        }
        else if (self.choice == 1)
        {
            NSString *js = [NSString stringWithFormat:@"($(\"[property='twitter:player:stream']\").attr('content'));"];
            _getURL = [self.tempView stringByEvaluatingJavaScriptFromString:js];
            NSRange range = [_getURL rangeOfString:@"?version"];
            NSString *newString = [_getURL substringToIndex:range.location];
            
            _getURL = newString;
        }
        
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL URLWithString:_getURL]];
        [_moviePlayer prepareToPlay];
        [_moviePlayer.view setFrame: self.viewForPlayer.bounds];
        [[self viewForPlayer] addSubview: _moviePlayer.view];
        _moviePlayer.shouldAutoplay = NO;

        [[self saveButtonOutlet] setHidden:NO];
        [[self saveButtonOutlet] setEnabled:YES];
        [[self loadButtonOutlet] setEnabled:YES];
        
        [self hideWaitingIndicator];
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestedURL = [[request URL] absoluteString];
    if([requestedURL rangeOfString:@"vine"].location==0)
    {
        return NO;
    }
    return YES;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat percentDone = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;

    [[self progress]setProgress:(percentDone) animated:(YES)];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // Either move the data from the location to a permanent location, or do something with the data at that location.
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[_getURL lastPathComponent]];
    
    NSData *data = [NSData dataWithContentsOfURL: location];
    
    [data writeToURL:tempURL atomically:YES];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempURL.path))
    {
        UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, nil, NULL, NULL);
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"Video incompatible" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }

    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"Download complete" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    //reenable actions when download complete
    if(_saveButtonOutlet.isEnabled == NO)
    {
        [[self saveButtonOutlet] setEnabled:YES];
        [[self loadButtonOutlet] setEnabled:YES];
    }
    
    [alert show];
}

-(void) showWaitingIndicator
{
    self.waitingIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
    
    self.waitingIndicator.layer.cornerRadius = 05;
    self.waitingIndicator.opaque = NO;
    self.waitingIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    self.waitingIndicator.center = self.view.center;
    self.waitingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.waitingIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    [self.view addSubview: _waitingIndicator];
    
    [_waitingIndicator startAnimating];
}

-(void) hideWaitingIndicator
{
    [_waitingIndicator removeFromSuperview];
    [_waitingIndicator stopAnimating];
}

@end