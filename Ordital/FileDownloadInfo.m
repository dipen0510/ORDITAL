//
//  FileDownloadInfo.m
//  BGTransferDemo
//
//  Created by Gabriel Theodoropoulos on 25/3/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "FileDownloadInfo.h"

@implementation FileDownloadInfo

-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source{
    if (self == [super init]) {
        self.fileTitle = title;
        self.fileURL = @"";
        self.uploadSource = source;
        self.uploadProgress = 0.0;
        self.isUploading = NO;
        self.uploadComplete = NO;
        self.taskIdentifier = -1;
    }
    
    return self;
}

-(id)initWithFileTitle:(NSString *)title andFileURL:(NSString *)URL andDownloadSource:(NSString *)source{
    if (self == [super init]) {
        self.fileTitle = title;
        self.fileURL = URL;
        self.uploadSource = source;
        self.uploadProgress = 0.0;
        self.isUploading = NO;
        self.uploadComplete = NO;
        self.taskIdentifier = -1;
    }
    
    return self;
}

@end
