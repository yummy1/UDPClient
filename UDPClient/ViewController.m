//
//  ViewController.m
//  UDPClient
//
//  Created by MM on 2018/11/8.
//  Copyright © 2018年 MM. All rights reserved.
//

#import "ViewController.h"
#import "GCD/GCDAsyncUdpSocket.h"

@interface ViewController ()<GCDAsyncUdpSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ipContent;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextField *portContent;
@property (weak, nonatomic) IBOutlet UITextView *sendContent;
@property (weak, nonatomic) IBOutlet UITextView *receiveContent;
@property(nonatomic,strong)GCDAsyncUdpSocket* udpClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.sendContent.layer.borderWidth = 0.5;
    
    self.receiveContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.receiveContent.layer.borderWidth = 0.5;
    
    self.udpClient = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (IBAction)connectAction:(UIButton *)sender {
    if (!sender.isSelected) {
        [sender setSelected:YES];
        NSError * error = nil;
        [self.udpClient bindToPort:[self.portContent.text intValue] error:&error];
        if (error) {//监听错误打印错误信息
            NSLog(@"error:%@",error);
        }else {//监听成功则开始接收信息
            [self.udpClient beginReceiving:&error];
        }
    }else{
        [sender setSelected:NO];
        [self.udpClient close];
    }
    [self.view endEditing:YES];
}
- (IBAction)sendClearAction:(UIButton *)sender {
    self.sendContent.text = @"";
}
- (IBAction)sendAction:(UIButton *)sender {
    NSData *data = [self.sendContent.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpClient sendData:data toHost:self.ipContent.text port:[self.portContent.text intValue] withTimeout:-1 tag:0];
    [self.view endEditing:YES];
}
- (IBAction)receiveClearAction:(UIButton *)sender {
    self.receiveContent.text = @"";
}
#pragma mark - GCDAsyncUdpSocketDelegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSError *error = nil;
    NSLog(@"Message didConnectToAddress: %@",[[NSString alloc]initWithData:address encoding:NSUTF8StringEncoding]);
    [self.udpClient beginReceiving:&error];
    [self.connectBtn setTitle:@"断开连接" forState:UIControlStateNormal];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"Message didNotConnect: %@",error);
    [self.connectBtn setTitle:@"开始连接" forState:UIControlStateNormal];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"Message didNotSendDataWithTag: %@",error);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Message didReceiveData :%@", str);
    _receiveContent.text = str;
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"Message 发送成功");
}

@end
