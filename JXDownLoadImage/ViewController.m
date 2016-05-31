//
//  ViewController.m
//  JXDownLoadImage
//
//  Created by yuezuo on 16/5/30.
//  Copyright © 2016年 yuezuo. All rights reserved.
//

#import "ViewController.h"
#import "JXModel.h"
@interface ViewController ()
/** 模型数组 */
@property (nonatomic,strong) NSArray * items;
/** 缓存字典（放到沙河目录中） */
@property (nonatomic,strong) NSMutableDictionary * images;
/** 队列对象 */
@property (nonatomic,strong) NSOperationQueue * queue;
/** 缓存操作 */
@property (nonatomic,strong) NSMutableDictionary * queues;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - 懒加载
- (NSArray *)items {
    if (_items == nil) {
        _items = [NSArray array];
        
        NSArray * arrayDict = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        
        NSMutableArray * items = [NSMutableArray array];
        for (NSDictionary * dict in arrayDict) {
            [items addObject:[JXModel modelWithDict:dict]];
        }
        
        _items = items;
        
    }
    return _items;
}

- (NSMutableDictionary *)images {
    if (_images == nil) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}

- (NSOperationQueue *)queue {
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
        // 最大并发数
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

- (NSMutableDictionary *)queues {
    if (_queues == nil) {
        _queues = [NSMutableDictionary dictionary];
    }
    return _queues;
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"app";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    JXModel * item = self.items[indexPath.row];
    
    // 先判断是都存在
    UIImage * image = self.images[item.icon];
    if (image) { // 如果内存中存在
        cell.imageView.image = image;
    } else { // 如果内存中不存在
        // 缓存路劲
        NSString * filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // 需要缓存的文件名
        NSString * name = [item.icon lastPathComponent];
        // 缓存文件名
        NSString * fileName = [filePath stringByAppendingPathComponent:name];
        NSData * data = [NSData dataWithContentsOfFile:fileName];
        if (data) { // 缓存中是否存在
            
            cell.imageView.image = [UIImage imageWithData:data];
            // 加载到内存中
            self.images[item.icon] = image;
            
        } else { // 如果缓存中不存在的情况下，需要下载，并将之保存到缓存中
            
            // 先检查缓存中是否存在与下载链接对应的操作
            NSOperation * operation = self.queues[item.icon];
            if (operation == nil) { // 如果没有操作
                operation = [NSBlockOperation blockOperationWithBlock:^{
                    // 下载用多线程下载
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.icon]];
                    if (data == nil) { // 下载失败
                        [self.queues removeObjectForKey:item.icon];
                        return ;
                    }
                    UIImage * image = [UIImage imageWithData:data];
                    
                    self.images[item.icon] = image;
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        // 刷新
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }];
                    
                    // 将数据存储
                    [data writeToFile:fileName atomically:YES];

                    // 下载完成之后移除操作
                    [self.queues removeObjectForKey:item.icon];
                }];
                
                // 将操作写到队列中
                [self.queue addOperation:operation];
                // 将操作写到操作缓存中
                self.queues[item.icon] = operation;
            }
        }
        
    }
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.download;
    
    
    
    return cell;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString * identifier = @"app";
//    
//    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    
//    JXModel * item = self.items[indexPath.row];
//
//    // 先判断是都存在
//    UIImage * image = self.images[item.icon];
//    if (image) { // 如果内存中存在
//        cell.imageView.image = image;
//    } else { // 如果内存中不存在
//        // 缓存路劲
//        NSString * filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        // 需要缓存的文件名
//        NSString * name = [item.icon lastPathComponent];
//        // 缓存文件名
//        NSString * fileName = [filePath stringByAppendingPathComponent:name];
//        NSData * data = [NSData dataWithContentsOfFile:fileName];
//        if (data) { // 缓存中是否存在
//            
//            cell.imageView.image = [UIImage imageWithData:data];
//            // 加载到内存中
//            self.images[item.icon] = image;
//            
//        } else { // 如果缓存中不存在的情况下，需要下载，并将之保存到缓存中
//            
//            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.icon]];
//            UIImage * image = [UIImage imageWithData:data];
//            cell.imageView.image = image;
//            self.images[item.icon] = image;
//            
//            // 将数据存储
//            [data writeToFile:fileName atomically:YES];
//        }
//        
//    }
//    cell.textLabel.text = item.name;
//    cell.detailTextLabel.text = item.download;
//    
//
//    
//    return cell;
//}
@end
