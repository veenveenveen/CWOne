//
//  ONEHomeRadioCell.m
//  CWOne
//
//  Created by Coulson_Wang on 2017/8/2.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//

#import "ONEHomeRadioCell.h"
#import "ONEHomeViewModel.h"
#import "ONEHomeItem.h"
#import "ONEUserItem.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "ONELikeView.h"
#import "ONERadioTool.h"
#import "ONERadioItem.h"

@interface ONEHomeRadioCell ()
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIView *playButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *authorIconView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *unActiveTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unActivePlayStatusView;

@property (weak, nonatomic) ONELikeView *likeView;

@end

@implementation ONEHomeRadioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.authorIconView.layer.cornerRadius = self.authorIconView.width * 0.5;
    self.authorIconView.layer.masksToBounds = YES;
    
    self.unActivePlayStatusView.userInteractionEnabled = YES;
    UIImage *aniImg1 = [UIImage imageNamed:@"voice-0"];
    UIImage *aniImg2 = [UIImage imageNamed:@"voice-1"];
    UIImage *aniImg3 = [UIImage imageNamed:@"voice-2"];
    [self.unActivePlayStatusView setAnimationImages:@[aniImg1,aniImg2,aniImg3]];
    [self.unActivePlayStatusView setAnimationDuration:2.0];
    [self.unActivePlayStatusView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unActivePlayViewClick)]];
    
    // 添加点赞控件
    ONELikeView *likeView = [ONELikeView likeView];
    [self.contentView addSubview:likeView];
    [likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.shareButton.mas_left).with.offset(-4);
        make.centerY.equalTo(self.shareButton);
        make.height.equalTo(@28);
        make.width.equalTo(@60);
    }];
    self.likeView = likeView;
    
    // 给播放按钮绘制圆形背景
    UIImage *circleImage = [self getCircleImageViewWithRadius:16 lineWidth:1.5];
    UIImageView *circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    circleView.contentMode = UIViewContentModeCenter;
    circleView.image = circleImage;
    [self.playButtonView insertSubview:circleView atIndex:0];
}

- (void)setViewModel:(ONEHomeViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    // 获取当前电台是否活跃
    BOOL isActive = [ONERadioTool sharedInstance].radioItem.isActive;
    
    // 确定控件是否隐藏
    self.logoImageView.hidden = !isActive;
    self.playButtonView.hidden = !isActive;
    self.titleLabel.hidden = !isActive;
    self.volumeLabel.hidden = !isActive;
    self.authorNameLabel.hidden = !isActive;
    self.unActiveTitleLabel.hidden = isActive;
    self.authorIconView.hidden = !isActive;
    self.unActivePlayStatusView.hidden = isActive;
    
    // 赋值
    NSURL *imgUrl = [NSURL URLWithString:viewModel.homeItem.img_url];
    [self.coverView sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"center_diary_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            self.coverView.image = [UIImage imageNamed:@"networkingErrorPlaceholderIcon"];
        }
    }];
    NSURL *authorIconUrl = [NSURL URLWithString:viewModel.homeItem.authorItem.web_url];
    [self.authorIconView sd_setImageWithURL:authorIconUrl placeholderImage:[UIImage imageNamed:@"UpdateInfoPlaceholdImage"] completed:nil];
    self.authorNameLabel.text = viewModel.homeItem.authorItem.user_name;
    self.titleLabel.text = viewModel.homeItem.title;
    self.unActiveTitleLabel.text = viewModel.homeItem.title;
    self.likeView.viewModel = viewModel;
    self.volumeLabel.text = viewModel.homeItem.volume;
}


// 事件响应
- (IBAction)playButtonClick:(UIButton *)sender {
    self.playButton.selected = !self.playButton.isSelected;
}

- (void)unActivePlayViewClick {
    if (self.unActivePlayStatusView.isAnimating) {
        [self.unActivePlayStatusView stopAnimating];
        // 停止播放音乐
        [[ONERadioTool sharedInstance] stopCurrentMusic];
    } else {
        [self.unActivePlayStatusView startAnimating];
        // 开始播放默认音乐
        [[ONERadioTool sharedInstance] playDefaultMusicWithMusicUrls:self.viewModel.homeItem.default_audios];
    }
    
}

#pragma mark - 私有工具方法
- (UIImage *)getCircleImageViewWithRadius:(CGFloat)radius lineWidth:(CGFloat)lineWidth{
    CGFloat rect = radius * 2+ lineWidth * 2;
    UIGraphicsBeginImageContext(CGSizeMake(rect, rect));
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(lineWidth, lineWidth, radius * 2, radius * 2)];
    [[UIColor whiteColor] setStroke];
    path.lineWidth = lineWidth;
    [path stroke];
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circle;
}

@end