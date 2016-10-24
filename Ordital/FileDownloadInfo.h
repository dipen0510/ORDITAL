//
//  FileDownloadInfo.h
//  BGTransferDemo
//
//  Created by Gabriel Theodoropoulos on 25/3/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadInfo : NSObject

@property (nonatomic, strong) NSString *fileTitle;

@property (nonatomic, strong) NSString *fileURL;

@property (nonatomic, strong) NSString *uploadSource;

@property (nonatomic, strong) NSURLSessionDataTask *uploadTask;

@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double uploadProgress;

@property (nonatomic) BOOL isUploading;

@property (nonatomic) BOOL uploadComplete;

@property (nonatomic) unsigned long taskIdentifier;


-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source;
-(id)initWithFileTitle:(NSString *)title andFileURL:(NSString *)URL andDownloadSource:(NSString *)source;

@end
