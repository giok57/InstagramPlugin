/*
    The MIT License (MIT)
    Copyright (c) 2013 - 2014 Vlad Stirbu
    
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cordova/CDV.h>
#import "CDVInstagramPlugin.h"

static NSString *InstagramId = @"com.burbn.instagram";

@implementation CDVInstagramPlugin

@synthesize toInstagram;
@synthesize callbackId;
@synthesize interactionController;

-(void)isInstalled:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"Finished saving video: %@", videoPath);
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@", [videoPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]];
    [[UIApplication sharedApplication] openURL:instagramURL];
}

- (void)share:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    self.toInstagram = FALSE;
    NSString    *objectAtIndex0 = [command argumentAtIndex:0];
    NSString    *caption = [command argumentAtIndex:1];
    
    CDVPluginResult *result;
    NSURL *instagrammm = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagrammm]) {
        NSLog(@"open in instagram");
        
        NSData *imageObj = [NSData dataFromBase64String:objectAtIndex0];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *tmpDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *path = [tmpDir stringByAppendingPathComponent:@"instagram.mp4"];
        
        [imageObj writeToFile:path atomically:YES];
        
        self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSLog(@"Path: %@", path);
       // UISaveVideoAtPathToSavedPhotosAlbum(path, self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
        
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:fileURL
                completionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
                        NSLog(@"Error: %@", error);
                    }else{
                        NSLog(@"Finished saving video: %@", assetURL.absoluteString);
                        NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@&InstagramCaption=%@", [assetURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], caption]];
                        [[UIApplication sharedApplication] openURL:instagramURL];
                                            
                    }
                }];
        }else{
            NSLog(@"Error: else");
        }
        
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application {
    if ([application isEqualToString:InstagramId]) {
        self.toInstagram = TRUE;
    }
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller {
    CDVPluginResult *result;
    
    if (self.toInstagram) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}



@end
