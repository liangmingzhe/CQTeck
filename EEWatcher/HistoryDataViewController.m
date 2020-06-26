//
//  HistoryDataViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/26.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "HistoryDataViewController.h"
#import "HistoryTimePickViewController.h"
#import "AFNetworking.h"
#import "EEMainPageView.h"
#import "HisDataCell.h"
#import "cqtekHeader.pch"
#import "DateValueFormatter.h"
#import "Language.h"

#define kBoundWidth  [UIScreen mainScreen].bounds.size.width
#define kBoundHeight  [UIScreen mainScreen].bounds.size.height
@interface HistoryDataViewController ()<IChartAxisValueFormatter,
IChartValueFormatter,
ChartViewDelegate,
UITableViewDelegate,UITableViewDataSource>{
    AFHTTPSessionManager *manager;
    NSUserDefaults* defaults;
    NSString* testString;
    NSString* endString;
    NSMutableDictionary* Data;
    UITableView* itemTableView;
    NSMutableArray* time;
    NSMutableArray* temp;
    NSMutableArray* humi;
    UIScrollView* thScrollView;
    UISegmentedControl* chartSegment;
    UIView* chartView;
    UIView* listView;
    UIView* backView;
    UIButton* change;
}
@property(nonatomic, assign) BOOL yIsPercent; //y轴是否为百分比显示
@property (nonatomic,strong)LineChartView *linechartView;
@property (nonatomic,strong)LineChartView *linehumiChartView;
@property (nonatomic,strong) UILabel * markY;
@property (nonatomic,strong) UILabel * timeY;
@property (nonatomic,strong) UILabel * humiMarkY;
@property (nonatomic,strong) UILabel * humiTimeY;


@end

@implementation HistoryDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    defaults= [NSUserDefaults standardUserDefaults];
    self.navigationItem.title = [defaults objectForKey:@"snaddr"];
    
    change = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [change setTitle:LocalizedString(@"l_list") forState:UIControlStateNormal];
    [change setBackgroundColor:[UIColor clearColor]];
    [change setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    change.titleLabel.font = [UIFont fontWithName:@"Arial" size:15];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:change];
    self.navigationItem.rightBarButtonItem = rightButton;
    [change addTarget:self action:@selector(changeForm) forControlEvents:UIControlEventTouchUpInside];


    backView = [[UIView alloc]initWithFrame:CGRectMake(0, 120, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 120)];
    [self.view addSubview:backView];

    chartView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, backView.frame.size.height)];
    chartView.backgroundColor = [UIColor whiteColor];
    listView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, backView.frame.size.height)];
    
    UIView* subView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    subView1.backgroundColor = [UIColor whiteColor];
    [listView addSubview:subView1];
    UIImageView* imageLine1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 29, [UIScreen mainScreen].bounds.size.width, 1)];
    imageLine1.backgroundColor = [UIColor lightGrayColor];
    [subView1 addSubview:imageLine1];
    
    UILabel* tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, subView1.frame.size.height/2 -10, 120, 20)];
    tempLabel.text = [NSString stringWithFormat:@"%@(℃)",LocalizedString(@"temperature")];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.font = [UIFont fontWithName:@"Arial" size:15];
    tempLabel.textAlignment =NSTextAlignmentCenter;
    [subView1 addSubview:tempLabel];
    
    UILabel* humiLabel = [[UILabel alloc]initWithFrame:CGRectMake(subView1.frame.size.width/2 - 60, subView1.frame.size.height/2 - 10, 120, 20)];
    humiLabel.text = [NSString stringWithFormat:@"%@(%%RH)",LocalizedString(@"humidity")];
    humiLabel.textColor = [UIColor blackColor];
    humiLabel.font = [UIFont fontWithName:@"Arial" size:15];
    humiLabel.textAlignment =NSTextAlignmentCenter;
    [subView1 addSubview:humiLabel];
    UILabel* timeLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 150, subView1.frame.size.height/2 -10, 150, 20)];
    timeLabel.text = LocalizedString(@"l_time");
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.textAlignment =NSTextAlignmentCenter;
    timeLabel.font = [UIFont fontWithName:@"Arial" size:15];
    [subView1 addSubview:timeLabel];

    listView.backgroundColor = [UIColor whiteColor];
    
    [backView insertSubview:listView atIndex:0];
    [backView insertSubview:chartView atIndex:1];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)changeForm{
    if (change.titleLabel.text == LocalizedString(@"l_list")) {
        [change setTitle:LocalizedString(@"t_chart") forState:UIControlStateNormal];
    }else{
        [change setTitle:LocalizedString(@"l_list") forState:UIControlStateNormal];
    }
    [self animationWithView:backView WithAnimationTransition:UIViewAnimationTransitionFlipFromRight];
}
- (UIView*)displayTimeView{
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kBoundWidth, 120)];
    view.alpha = 0.8;
    //起始时间
    UIView* subView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kBoundWidth, 30)];
    [view addSubview:subView1];
    //起始时间
    UILabel* subTimeLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, kBoundWidth - 10, 30)];
    subTimeLabel1.textAlignment = NSTextAlignmentLeft;
    subTimeLabel1.text = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"l_start_time"),[HistoryTimePickViewController sharedInstanceFive].teststring];
    subTimeLabel1.textColor = [UIColor blackColor];
    subTimeLabel1.font = [UIFont fontWithName:@"Arial" size:15];
    [subView1 addSubview:subTimeLabel1];

    UIView* subView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 30, kBoundWidth, 30)];
    [view addSubview:subView2];
    //结束时间
    UILabel* subTimeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, kBoundWidth - 10, 30)];
    subTimeLabel2.textColor = [UIColor blackColor];
    subTimeLabel2.text = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"l_end_time"),[HistoryTimePickViewController sharedInstanceFive].endString];
    subTimeLabel2.font = [UIFont fontWithName:@"Arial" size:15];
    subTimeLabel2.textAlignment = NSTextAlignmentLeft;
    [subView2 addSubview:subTimeLabel2];
    
    UILabel* RangeTime = [[UILabel alloc]initWithFrame:CGRectMake(kBoundWidth/3*2, 0, kBoundWidth/3, 30)];
    RangeTime.text = [NSString stringWithFormat:@"%@:%@%@",LocalizedString(@"l_interval"),[[HistoryTimePickViewController sharedInstanceFive]rangeTime],LocalizedString(@"l_minute")];
    RangeTime.font = [UIFont fontWithName:@"Arial" size:15];
    [subView2 addSubview:RangeTime];

    //线
    UIImageView* imageLine1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 119, kBoundWidth, 1)];
    imageLine1.backgroundColor = [UIColor lightGrayColor];
    [subView1 addSubview:imageLine1];

    UIView* subView3 = [[UIView alloc]initWithFrame:CGRectMake(0, 60, kBoundWidth, 30)];
    [view addSubview:subView3];
    
    UILabel* MaxTemp = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, kBoundWidth/3, 30)];
    MaxTemp.text = [NSString stringWithFormat:@"%@:%@℃",LocalizedString(@"t_maxTemp"),[[[HistoryTimePickViewController sharedInstanceFive]historyDic] objectForKey:@"tempMax"]];
    MaxTemp.font = [UIFont fontWithName:@"Arial" size:15];
    [subView3 addSubview:MaxTemp];
    
    UILabel* MaxHumi = [[UILabel alloc]initWithFrame:CGRectMake(kBoundWidth/3, 0, kBoundWidth/3, 30)];
    MaxHumi.text = [NSString stringWithFormat:@"%@:%@%%",LocalizedString(@"t_maxHumi"),[[[HistoryTimePickViewController sharedInstanceFive]historyDic] objectForKey:@"humiMax"]];
    MaxHumi.font = [UIFont fontWithName:@"Arial" size:15];
    [subView3 addSubview:MaxHumi];


    
    UIView* subView4 = [[UIView alloc]initWithFrame:CGRectMake(0, 90, kBoundWidth, 30)];
    [view addSubview:subView4];
    
    UILabel* MinTemp = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, kBoundWidth/3, 30)];
    MinTemp.text = [NSString stringWithFormat:@"%@:%@℃",LocalizedString(@"t_minTemp"),[[[HistoryTimePickViewController sharedInstanceFive]historyDic] objectForKey:@"tempMin"]];
    MinTemp.font = [UIFont fontWithName:@"Arial" size:15];
    [subView4 addSubview:MinTemp];

    UILabel* MinHumi = [[UILabel alloc]initWithFrame:CGRectMake(kBoundWidth/3, 0, kBoundWidth/3, 30)];
    MinHumi.text = [NSString stringWithFormat:@"%@:%@%%",LocalizedString(@"t_minHumi"),[[[HistoryTimePickViewController sharedInstanceFive]historyDic] objectForKey:@"humiMin"]];
    MinHumi.font = [UIFont fontWithName:@"Arial" size:15];
    [subView4 addSubview:MinHumi];
    
//    UILabel* RangeTime = [[UILabel alloc]initWithFrame:CGRectMake(kBoundWidth/3*2, 0, kBoundWidth/3, 30)];
//    RangeTime.text = [NSString stringWithFormat:@"%@:%@%@",LocalizedString(@"l_interval"),[[HistoryTimePickViewController sharedInstanceFive]rangeTime],LocalizedString(@"l_minute")];
//    RangeTime.font = [UIFont fontWithName:@"Arial" size:15];
//    [subView4 addSubview:RangeTime];


    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    return view;
}

- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition
{
    
    [UIView animateWithDuration:0.7f animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
        [view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        
    }];
}
//分段选择器初始化
- (UISegmentedControl*)SegmentControlInit{
    chartSegment = [[UISegmentedControl alloc]init];
    NSArray* items = [NSArray arrayWithObjects:LocalizedString(@"temperature"),LocalizedString(@"humidity"), nil];
    chartSegment = [[UISegmentedControl alloc]initWithItems:items];
    chartSegment.frame = CGRectMake(kBoundWidth/2 - 80, 20, 160, 30);
    chartSegment.selectedSegmentIndex = 0;
    [chartSegment setTintColor:[UIColor colorWithRed:59/255.0 green:116/255.0 blue:169/255.0 alpha:1]];
    [chartSegment addTarget:self action:@selector(SegmentHandle) forControlEvents:UIControlEventValueChanged];
    [chartView addSubview:chartSegment];
    return chartSegment;
}
//分段选择器处理事件
- (void)SegmentHandle{
    NSInteger index = chartSegment.selectedSegmentIndex;
    [thScrollView setContentOffset:CGPointMake(index*kBoundWidth, 0) animated:YES];
}

//滚动页初始化
- (UIScrollView*)ScrollViewInit{
    thScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, chartView.frame.size.width, chartView.frame.size.height)];
    thScrollView.delegate = self;
    thScrollView.scrollEnabled = NO;
    thScrollView.showsHorizontalScrollIndicator = false;
    thScrollView.contentSize = CGSizeMake(kBoundWidth * 2, 0);
    
    thScrollView.backgroundColor = [UIColor clearColor];
    thScrollView.pagingEnabled = YES;
    thScrollView.bounces = false;
    [chartView addSubview:thScrollView];
    return thScrollView;
}

//温度线图构造函数
- (LineChartView *)linechartView {
    if (!_linechartView) {
        _linechartView = [[LineChartView alloc] initWithFrame:CGRectMake(10, 60, [UIScreen mainScreen].bounds.size.width - 10,  thScrollView.frame.size.height - 120)];
        //    _linechartView.backgroundColor = [UIColor colorWithRed:0.284 green:0.600 blue:0.738 alpha:1.000];
        _linechartView.delegate = self;//设置代理
        
        _linechartView.backgroundColor = [UIColor clearColor];
        
        _linechartView.dragEnabled = YES;
        
        _linechartView.pinchZoomEnabled = NO;   //捏合手势
        _linechartView.doubleTapToZoomEnabled = NO; //双击手势
        _linechartView.scaleYEnabled = NO;  //取消Y轴缩放
        _linechartView.legend.form = ChartLegendFormLine;   //说明图标
        _linechartView.chartDescription.enabled = NO; //不显示描述label
        
        _linechartView.rightAxis.enabled = NO;  //右Y轴
        [_linechartView animateWithXAxisDuration:1];  //赋值动画时长
        
        ChartMarkerView *markerY = [[ChartMarkerView alloc]init];
        markerY.offset = CGPointMake(-999, -8);
        markerY.chartView = _linechartView;
        _linechartView.marker = markerY;
        
        
        [markerY addSubview:self.markY];
        [markerY addSubview:self.timeY];
        
        // 设置左Y轴
        
        ChartYAxis *leftAxis = _linechartView.leftAxis;
        [leftAxis removeAllLimitLines];

        leftAxis.drawZeroLineEnabled = NO;
        leftAxis.labelFont = [UIFont systemFontOfSize:8.f];
//        leftAxis.labelCount = 4;
        leftAxis.axisMaximum = 120.0;
        leftAxis.labelCount = 4;
        leftAxis.axisMinimum = -40.0;
//        leftAxis.axisDependency
        leftAxis.axisLineWidth = 1;
        leftAxis.drawLimitLinesBehindDataEnabled = YES;
        leftAxis.gridLineDashLengths = @[@2.f, @2.f]; //虚线长度
        
        // 设置X轴
        ChartXAxis *xAxis = _linechartView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.labelFont = [UIFont systemFontOfSize:10.0f];
//        xAxis.axisMinValue = -0.3;
        xAxis.granularity = 0;
        xAxis.labelCount = 2; // 先是坐标个数
        xAxis.drawAxisLineEnabled = NO;    //是否画x轴线
        xAxis.drawGridLinesEnabled = NO;   //是否画网格
        xAxis.gridLineDashLengths = @[@40.f, @1.f];//设置虚线样式的网格线
        
        NSArray *xValues = time;
        
        if (xValues.count > 0) {
            _linechartView.xAxis.axisMaximum = (double)xValues.count - 1 + 0.3;
            _linechartView.xAxis.valueFormatter = [[DateValueFormatter alloc] initWithDateArr:xValues];
        }
    }
    
    return _linechartView;
}


//温度线图构造函数
- (LineChartView *)linehumiChartView {
    if (!_linehumiChartView) {
        _linehumiChartView = [[LineChartView alloc] initWithFrame:CGRectMake(kBoundWidth + 10, 60, [UIScreen mainScreen].bounds.size.width - 20, thScrollView.frame.size.height - 120)];
        //    _linechartView.backgroundColor = [UIColor colorWithRed:0.284 green:0.600 blue:0.738 alpha:1.000];
        _linehumiChartView.delegate = self;//设置代理
        
        _linehumiChartView.backgroundColor = [UIColor clearColor];
        
        _linehumiChartView.dragEnabled = YES;
        _linehumiChartView.pinchZoomEnabled = NO;   //捏合手势
        _linehumiChartView.doubleTapToZoomEnabled = NO; //双击手势
        _linehumiChartView.scaleYEnabled = NO;  //取消Y轴缩放
        _linehumiChartView.chartDescription.enabled = NO; //不显示描述label
        _linehumiChartView.legend.form = ChartLegendFormLine;   //说明图标
        _linehumiChartView.rightAxis.enabled = NO;  //右Y轴
        [_linehumiChartView animateWithXAxisDuration:1];  //赋值动画时长
        
        ChartMarkerView *markerY = [[ChartMarkerView alloc]init];
        markerY.offset = CGPointMake(-999, -8);
        markerY.chartView = _linehumiChartView;
        _linehumiChartView.marker = markerY;
        [markerY addSubview:self.humiMarkY];
        [markerY addSubview:self.humiTimeY];
        // 设置左Y轴
        
        ChartYAxis *left2Axis = _linehumiChartView.leftAxis;
        
        [left2Axis removeAllLimitLines];
        left2Axis.labelFont = [UIFont systemFontOfSize:8.f];
        left2Axis.axisMaximum = 99.0;
        left2Axis.labelCount = 5;
        left2Axis.axisMinimum = 0.0;
        left2Axis.axisLineWidth = 1;
        left2Axis.drawZeroLineEnabled = NO;
        left2Axis.drawLimitLinesBehindDataEnabled = YES;
        left2Axis.gridLineDashLengths = @[@2.f, @2.f];
        
        // 设置X轴
        ChartXAxis *xAxis = _linehumiChartView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.labelFont = [UIFont systemFontOfSize:12.0f];
//        xAxis.axisMinValue = -0.3;
        xAxis.granularity = 0;
        xAxis.labelCount = 2; // 先是坐标个数
        xAxis.drawAxisLineEnabled = NO;    //是否画x轴线
        xAxis.drawGridLinesEnabled = NO;   //是否画网格
        xAxis.gridLineDashLengths = @[@10.f, @1.f];
        
        // 设置X轴数据
        NSArray *xValues = time;
        if (xValues.count > 0) {
            // 这里将代理赋值为一个类的对象, 该对象需要遵循IChartAxisValueFormatter协议, 并实现其代理方法(我们可以对需要显示的值进行各种处理, 这里对日期进行格式处理)(当然下面的各代理也都可以这样写)
            _linehumiChartView.xAxis.axisMaximum = (double)xValues.count - 1 + 0.3;
            _linehumiChartView.xAxis.valueFormatter = [[DateValueFormatter alloc] initWithDateArr:xValues];
            
        }
    }
    
    return _linehumiChartView;
}


- (UILabel *)markY{
    if (!_markY) {
        _markY = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 58, 30)];
        _markY.font = [UIFont systemFontOfSize:14.0];
        _markY.textAlignment = NSTextAlignmentCenter;
        _markY.text =@"";
        _markY.textColor = [UIColor blackColor];
        _markY.backgroundColor = [UIColor lightGrayColor];
        _markY.alpha = 0.8;
    }
    return _markY;
}
- (UILabel *)timeY{
    if (!_timeY) {
        _timeY = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 58, 20)];
        _timeY.font = [UIFont systemFontOfSize:8];
        _timeY.numberOfLines = 2;
        _timeY.textAlignment = NSTextAlignmentCenter;
        _timeY.text =@"";
        _timeY.textColor = [UIColor blackColor];
        _timeY.backgroundColor = [UIColor lightGrayColor];
        _timeY.alpha = 0.8;
    }
    return _timeY;
}
- (UILabel *)humiTimeY{
    if (!_humiTimeY) {
        _humiTimeY = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 58, 20)];
        _humiTimeY.font = [UIFont systemFontOfSize:8];
        _humiTimeY.numberOfLines = 2;
        _humiTimeY.textAlignment = NSTextAlignmentCenter;
        _humiTimeY.text =@"";
        _humiTimeY.textColor = [UIColor blackColor];
        _humiTimeY.backgroundColor = [UIColor lightGrayColor];
        _humiTimeY.alpha = 0.8;
    }
    return _humiTimeY;
}


- (UILabel *)humiMarkY{
    if (!_humiMarkY) {
        _humiMarkY = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 58, 30)];
        _humiMarkY.font = [UIFont systemFontOfSize:14.0];
        _humiMarkY.textAlignment = NSTextAlignmentCenter;
        _humiMarkY.text =@"";
        _humiMarkY.textColor = [UIColor blackColor];
        _humiMarkY.backgroundColor = [UIColor lightGrayColor];
        _humiMarkY.alpha = 0.8;
    }
    return _humiMarkY;
}

- (LineChartDataSet *)drawLineWithArr:(NSArray *)arr title:(NSString *)title color:(UIColor *)color {
    if (arr.count == 0) {
        return nil;
    }
    // 处理折线数据 //最大值最小值
    NSMutableArray *statistics = [NSMutableArray array];
    double leftAxisMin = -20;
    double leftAxisMax = 0;
    for (int i = 0; i < arr.count; i++) {
        NSNumber *num = arr[i];
        double value = [num doubleValue];
        leftAxisMax = MAX(value, leftAxisMax);
        leftAxisMin = MIN(value, leftAxisMin);
        [statistics addObject:[[ChartDataEntry alloc] initWithX:i y:value]];
    }
    
    CGFloat topNum = leftAxisMax * (8.0/4.0);
    _linechartView.leftAxis.axisMaximum = topNum;
    if (leftAxisMin < 0) {
        CGFloat minNum = leftAxisMin * (4.0/4.0);
        _linechartView.leftAxis.axisMinimum = minNum ;
    }
    
    // 设置Y轴数据
    _linechartView.leftAxis.valueFormatter = self; //需要遵IChartAxisValueFormatter协议
    
    // 设置折线数据
    LineChartDataSet *set1 = nil;
//    set1 = [[LineChartDataSet alloc] initWithValues:statistics label:title];
    set1 = [[LineChartDataSet alloc] initWithEntries:statistics label:title];
    set1.mode = LineChartModeLinear;   // 弧度mode
    [set1 setColor:color];
    [set1 setCircleColor:color];
    set1.lineWidth = 2.0;
    set1.circleRadius = 0;
    set1.valueColors = @[color];
    set1.drawFilledEnabled = YES;//是否填充颜色
    set1.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];//填充颜色
    
    set1.valueFormatter = self; //需要遵循IChartValueFormatter协议
    set1.valueFont = [UIFont systemFontOfSize:0.f];
    return set1;
}


//处理湿度曲线刻度
- (LineChartDataSet *)drawHumiLineWithArr:(NSArray *)arr title:(NSString *)title color:(UIColor *)color {
    if (arr.count == 0) {
        return nil;
    }
    // 处理折线数据
    NSMutableArray *statistics = [NSMutableArray array];
    double leftAxisMin = 0;
    double leftAxisMax = 100;
    for (int i = 0; i < arr.count; i++) {
        NSNumber *num = arr[i];
        double value = [num doubleValue];
        leftAxisMax = MAX(value, leftAxisMax);
        leftAxisMin = MIN(value, leftAxisMin);
        [statistics addObject:[[ChartDataEntry alloc] initWithX:i y:value]];
    }
    
    CGFloat topNum = leftAxisMax * (4.0/4.0);
    _linehumiChartView.leftAxis.axisMaximum = topNum;
    if (leftAxisMin < 0) {
        CGFloat minNum = leftAxisMin * (4.0/4.0);
        _linehumiChartView.leftAxis.axisMinimum = minNum ;
    }
    
    // 设置Y轴数据
    _linehumiChartView.leftAxis.valueFormatter = self; //需要遵IChartAxisValueFormatter协议
    
    // 设置折线数据
    LineChartDataSet *set1 = nil;
//    set1 = [[LineChartDataSet alloc] initWithValues:statistics label:title];
    set1 = [[LineChartDataSet alloc] initWithEntries:statistics label:title];
    set1.mode = LineChartModeLinear;   // 弧度mode
    [set1 setColor:color];
    [set1 setCircleColor:color];
    set1.lineWidth = 2;
    set1.circleRadius = 0;
    set1.valueColors = @[color];
    set1.drawFilledEnabled = YES;//是否填充颜色
    set1.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];//填充颜色
    
    
    set1.valueFormatter = self; //需要遵循IChartValueFormatter协议
    set1.valueFont = [UIFont systemFontOfSize:0.f];
    return set1;
}



- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight {
    if (chartView == _linehumiChartView) {
        int x = entry.x;
        _humiTimeY.text = [NSString stringWithFormat:@"%@",[time[x] substringWithRange:NSMakeRange(5,11 )]];
        _humiMarkY.text = [NSString stringWithFormat:@"%.1f %%",entry.y];
        [_linehumiChartView centerViewToAnimatedWithXValue:entry.x yValue:entry.y axis:[_linehumiChartView.data getDataSetByIndex:highlight.dataSetIndex].axisDependency duration:1.0];
        
        
    }else{
        _markY.text = [NSString stringWithFormat:@"%.1f℃",entry.y];
        int x = entry.x;
        _timeY.text = [NSString stringWithFormat:@"%@",[time[x] substringWithRange:NSMakeRange(5,11 )]];
        //将点击的数据滑动到中间s
        [_linechartView centerViewToAnimatedWithXValue:entry.x yValue:entry.y axis:[_linechartView.data getDataSetByIndex:highlight.dataSetIndex].axisDependency duration:1.0];
    }
    
}


#pragma mark - IChartValueFormatter delegate (折线值)
- (NSString *)stringForValue:(double)value entry:(ChartDataEntry *)entry dataSetIndex:(NSInteger)dataSetIndex viewPortHandler:(ChartViewPortHandler *)viewPortHandler {
    if (self.yIsPercent) {
        return [NSString stringWithFormat:@"%.2f%%", value];
        
    }
    return [NSString stringWithFormat:@"%.f", value];
}

#pragma mark - IChartAxisValueFormatter delegate (y轴值) (x轴的值写在DateValueFormatter类里, 都是这个协议方法)
- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    if (self.yIsPercent) {
        return [NSString stringWithFormat:@"%.1f%%", value];
    }
    if (ABS(value) > 1000) {
        return [NSString stringWithFormat:@"%.1fk", value/(double)1000];
    }
    
    return [NSString stringWithFormat:@"%.f", value];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self displayTimeView];
    [self ScrollViewInit];
    [self SegmentControlInit];

    Data = [[[HistoryTimePickViewController sharedInstanceFive]historyDic] objectForKey:@"array"];
    [self.view addSubview:itemTableView];
    
    temp = [[NSMutableArray alloc]initWithCapacity:0];
    temp = [Data objectForKey:@"tempList"];
    
    humi = [[NSMutableArray alloc]initWithCapacity:0];
    humi = [Data objectForKey:@"humiList"];
    
    time = [[NSMutableArray alloc]initWithCapacity:0];
    time = [Data objectForKey:@"timeList"];
    
    [thScrollView addSubview:self.linechartView];
    [thScrollView addSubview:self.linehumiChartView];
    
    
    // 设置折线数据
    // 这里模拟了2条折线
    NSArray *legendTitles = @[[NSString stringWithFormat:@"%@℃",LocalizedString(@"temperature")]];
    
    NSArray *statistics = @[temp];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init]; //数据集数组
    
    // 这样写的好处是, 无论你传多少条数据, 都可以处理展示
    for (int i = 0; i < statistics.count; i++) {
        // 循环创建数据集
        LineChartDataSet *set = [self drawLineWithArr:statistics[i]  title:legendTitles[i] color:[UIColor  colorWithRed:36.0/255.0 green:138.0/255.0 blue:240.0/255.0 alpha:1]];
        if (set) {
            [dataSets addObject:set];
        }
    }
    
    // 赋值数据集数组
    if (dataSets.count > 0) {
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        _linechartView.data = data;
    }
    
    NSArray *legendTitle2 = @[[NSString stringWithFormat:@"%@%%RH",LocalizedString(@"humidity")]];
    NSArray *statistic2 = @[humi];
    NSMutableArray *humidataSet = [[NSMutableArray alloc] init]; //数据集数组
    // 这样写的好处是, 无论你传多少条数据, 都可以处理展示
    for (int i = 0; i < statistic2.count; i++) {
        // 循环创建数据集
        LineChartDataSet *set = [self drawHumiLineWithArr:statistic2[i]  title:legendTitle2[i] color:[UIColor colorWithRed:219.0/255.0 green:101.0/255.0 blue:27.0/255.0 alpha:1]];
        if (set) {
            [humidataSet addObject:set];
        }
    }
    
    // 赋值数据集数组
    if (humidataSet.count > 0) {
        LineChartData *data = [[LineChartData alloc] initWithDataSets:humidataSet];
        _linehumiChartView.data = data;
    }
    
    //列表
    
    itemTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, listView.frame.size.width, listView.frame.size.height - 96) style:UITableViewStylePlain];
    itemTableView.delegate = self;
    itemTableView.dataSource = self;
    [listView addSubview:itemTableView];

}

- (void)viewWillDisappear:(BOOL)animated{
    [chartSegment removeFromSuperview];
    [thScrollView removeFromSuperview];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return temp.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HisDataCell* cell = [tableView dequeueReusableCellWithIdentifier:@"HisDataCell"];
    if (cell == nil) {
        cell = [[HisDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HisDataCell"];
    }
    cell.tempValue.text = temp[indexPath.row];
    cell.humiValue.text = humi[indexPath.row];
    
    NSArray* time1 = time;
    
    cell.labelTime.text = [time1[indexPath.row]substringWithRange:NSMakeRange(0, 16)];
    
    return cell;
    
}
@end

