import { NumberObject } from '../utils/BaseObjects';
import { DesignSystem } from '../utils/DesignSystem';
import { Header } from '../view/Header';
import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import web_webview from '@ohos.web.webview';
import { DayTaskStats, TaskList } from '../model/Task';
import { ScheduleList } from '../model/Schedule';
import { CoreflameGroupList } from '../model/Coreflame';

// 定义数据点类型
interface DataPoint {
  value: number;
  name: string;
}

// 定义坐标轴标签格式
interface AxisLabel {
  formatter?: string;
}

// 定义坐标轴类型
interface Axis {
  type: string;
  data?: string[];
  axisLabel?: AxisLabel;
}

// 定义网格配置
interface Grid {
  left: string;
  right?: string;
  top?: string;
  bottom: string;
  containLabel: boolean;
}

// 定义提示框配置
interface Tooltip {
  trigger: string;
  formatter?: string;
}

// 定义标签配置
interface Label {
  show: boolean;
  position: string;
  formatter?: string;
  color?: string;
}

// 定义颜色函数参数类型
interface ColorParams {
  dataIndex: number;
}

// 定义系列样式
interface ItemStyle {
  color?: string | ((params: ColorParams) => string);
  barBorderRadius?: number | number[];
}

// 定义条形图系列
interface BarSeries {
  name: string;
  type: 'bar';
  data: DataPoint[];
  barWidth?: string;
  itemStyle?: ItemStyle;
  label?: Label;
}

// 定义 ECharts 配置
interface EChartsOption {
  tooltip?: Tooltip;
  grid?: Grid;
  xAxis?: Axis;
  yAxis?: Axis;
  series: BarSeries[];
}

@ComponentV2
export struct ChroniclePage {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local tasks: TaskList =
    AppStorageV2.connect<TaskList>(TaskList, () => new TaskList(new ScheduleList(), new CoreflameGroupList()))!;

  @Computed
  get total() {
    return this.tasks.calculateStats().reduce((prev: number, cur: DayTaskStats): number => {
      return prev + cur.general.total
    }, 0)
  }

  @Computed
  get totalTime() {
    return this.tasks.calculateStats().reduce((prev: number, cur: DayTaskStats): number => {
      return prev + cur.general.totalTime
    }, 0)
  }

  @Event openSetting: () => void = () => {
  };

  @Builder
  voidDescriptionBuilder() {
  }

  build() {
    Column({ space: this.ds.getSize(1) }) {
      Header({
        title: $r('app.string.Chronicle'),
        openSetting: () => {
          this.openSetting();
        }
      })


      Row() {
        Gauge({ value: 1, min: 1, max: 10 }) {
          Column() {
            Text('1')
              .fontWeight(FontWeight.Bolder)
              .fontSize(this.ds.getSize(1.5))
              .width('100%')
              .fontColor(this.ds.getColor(this.ccm, 'surface', 900))
              .textAlign(TextAlign.Center)
              .margin({
                top: this.ds.getSize(0.25)
              })
          }
          .justifyContent(FlexAlign.Center)
        }
        .startAngle(210)
        .endAngle(150)
        .colors(this.ds.getColor(this.ccm, 'primary'))
        .strokeWidth(this.ds.getSize(0.5))
        .description(this.voidDescriptionBuilder)
        .margin({
          right: this.ds.getSize(1)
        })

        Column({ space: this.ds.getSize(0.5) }) {
          Row() {
            Text("您已连胜 1 天")
              .fontSize(this.ds.getSize(1.4))
              .fontWeight(FontWeight.Bold)
          }
          .justifyContent(FlexAlign.SpaceBetween)

          Text("当前连胜倍率 1x，继续加油哦！")
            .fontSize(this.ds.getSize(0.8))
            .fontWeight(FontWeight.Bolder)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .backgroundColor(
        this.ds.getColor(this.ccm, 'surface', 100, 0.2)
      )
      .borderColor(
        this.ds.getColor(this.ccm, 'surface', 800, 0.3)
      )
      .borderWidth(this.ds.getSize(0.15))
      .width('100%')
      .height(this.ds.getSize(6))
      .borderRadius(this.ds.getSize(1))
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(this.ds.getSize(1))


      Column({ space: this.ds.getSize(1) }) {
        Row() {
          Column({ space: this.ds.getSize(0.25) }) {
            Row() {
              Text("累计专注")
                .fontSize(this.ds.getSize(1))
                .fontWeight(FontWeight.Bold)

              Text("您已踏上逐火之旅 1 天")
                .fontSize(this.ds.getSize(0.8))
                .fontWeight(FontWeight.Medium)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')

        Row() {
          Column() {
            Gauge({ value: this.total, min: 1, max: this.total * 3 }) {
              Column() {
                Text(this.total.toString())
                  .fontWeight(FontWeight.Bolder)
                  .fontSize(this.ds.getSize(1.5))
                  .width('100%')
                  .fontColor(this.ds.getColor(this.ccm, 'surface', 900))
                  .textAlign(TextAlign.Center)
              }
              .justifyContent(FlexAlign.Center)
            }
            .startAngle(210)
            .endAngle(150)
            .colors(this.ds.getColor(this.ccm, 'primary'))
            .strokeWidth(this.ds.getSize(1))
            .description(this.voidDescriptionBuilder)

            Text('逐火次数')
              .fontSize(this.ds.getSize(0.8))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .margin({ top: this.ds.getSize(0.5) })
          }
          .width(this.ds.getSize(5))

          Column() {
            Gauge({ value: this.totalTime, min: 1, max: this.totalTime * 2 }) {
              Column() {
                Text(this.totalTime.toString())
                  .fontWeight(FontWeight.Bolder)
                  .fontSize(this.ds.getSize(1.5))
                  .width('100%')
                  .fontColor(this.ds.getColor(this.ccm, 'surface', 900))
                  .textAlign(TextAlign.Center)
              }
              .justifyContent(FlexAlign.Center)
            }
            .startAngle(210)
            .endAngle(150)
            .colors(this.ds.getColor(this.ccm, 'primary'))
            .strokeWidth(this.ds.getSize(1))
            .description(this.voidDescriptionBuilder)

            Text('逐火时长')
              .fontSize(this.ds.getSize(0.8))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .margin({ top: this.ds.getSize(0.5) })
          }
          .width(this.ds.getSize(5))

          Column() {
            Gauge({ value: this.total, min: 1, max: this.total * 3 }) {
              Column() {
                Text(this.total.toString())
                  .fontWeight(FontWeight.Bolder)
                  .fontSize(this.ds.getSize(1.5))
                  .width('100%')
                  .fontColor(this.ds.getColor(this.ccm, 'surface', 900))
                  .textAlign(TextAlign.Center)
              }
              .justifyContent(FlexAlign.Center)
            }
            .startAngle(210)
            .endAngle(150)
            .colors(this.ds.getColor(this.ccm, 'primary'))
            .strokeWidth(this.ds.getSize(1))
            .description(this.voidDescriptionBuilder)

            Text('火种数量')
              .fontSize(this.ds.getSize(0.8))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .margin({ top: this.ds.getSize(0.5) })
          }
          .width(this.ds.getSize(5))
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .backgroundColor(
        this.ds.getColor(this.ccm, 'surface', 100, 0.2)
      )
      .borderColor(
        this.ds.getColor(this.ccm, 'surface', 800, 0.3)
      )
      .borderWidth(this.ds.getSize(0.15))
      .width('100%')
      .borderRadius(this.ds.getSize(1))
      .padding(this.ds.getSize(1))
      .margin({
        bottom: this.ds.getSize(0.5),
      })

      // Accumulated_focus()
      // Focus_today()
      // Distribution_of_Focus_Duration()
    }
    .height('100%')
    .width('100%')
    .padding({
      left: this.ds.getSize(1),
      right: this.ds.getSize(1),
      bottom: this.ds.getSize(5.5),
      top: this.ds.getSize(2)
    })
    .alignItems(HorizontalAlign.Start)
  }
}

@Preview
@Component
struct Accumulated_focus {
  @State message: string = '累计专注';
  @State displayDate: Date = new Date();
  @State tempSelectedDate: Date = new Date();
  @State currentDate: string = '';
  @State showDatePicker: boolean = false;

  async aboutToAppear(): Promise<void> {
    this.currentDate = this.getFormattedDate(this.displayDate);
    this.tempSelectedDate = new Date(this.displayDate.getTime());
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Row() {
            Text(this.message)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(this.currentDate)
              .fontSize(14)
              .margin({ left: 5 })
          }

          Row() {

          }
        }
        .width('100%')
        .padding(16)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Column() {
            Text('次数')
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
            Gauge2()
          }.layoutWeight(1).alignItems(HorizontalAlign.Center)

          Column() {
            Text('时长')
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
            Gauge2()
          }.layoutWeight(1).alignItems(HorizontalAlign.Center)

          Column() {
            Text('日均时长')
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
            Gauge2()
          }.layoutWeight(1).alignItems(HorizontalAlign.Center)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .backgroundColor(Color.White)
      .margin({ top: 20, left: 16, right: 16 })
      .borderRadius(15)

      // 日期选择器对话框
      if (this.showDatePicker) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(0x33000000)
          .onClick(() => this.showDatePicker = false)

        Column() {
          DatePicker({
            start: new Date('1970-01-01'),
            end: new Date(),
            selected: this.tempSelectedDate
          })
            .onDateChange((value: Date) => {
              // const year = value.year ?? this.tempSelectedDate.getFullYear();
              // const month = value.month ?? this.tempSelectedDate.getMonth() + 1;
              // const day = value.day ?? this.tempSelectedDate.getDate();
              // this.tempSelectedDate = new Date(year, month - 1, day);
            })

          Row() {
            Button('取消')
              .onClick(() => this.showDatePicker = false)
              .layoutWeight(1)
              .backgroundColor(Color.White)

            Button('确定')
              .onClick(async () => {
                this.displayDate = new Date(this.tempSelectedDate.getTime());
                this.currentDate = this.getFormattedDate(this.displayDate);

                // 使用新选择的日期查询数据

                this.showDatePicker = false;
              })
              .layoutWeight(1)
              .margin({ left: 10 })
          }
          .margin(10)
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
        .backgroundColor(Color.White)
        .borderRadius(20)
        .padding(10)
        .width('90%')
      }
    }
  }

  private getFormattedDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}

@Preview
@Component
struct Focus_today {
  @State displayDate: Date = new Date();
  @State currentDate: string = '';

  async aboutToAppear(): Promise<void> {
    this.currentDate = this.getFormattedDate(this.displayDate);
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text('当日专注')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text(this.currentDate)
            .fontSize(14)
            .margin({ left: 5 })
        }

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding(16)

      Row() {
        Column() {
          Text('次数')
            .fontSize(8)
            .fontWeight(FontWeight.Medium)
          // 在SchedulePage组件中
          Gauge2()
            .width(100)  // 调整为适当宽度
            .height(100) // 调整为适当高度
        }.layoutWeight(1).alignItems(HorizontalAlign.Center)

        Column() {
          Text('时长')
            .fontSize(8)
            .fontWeight(FontWeight.Medium)
          Gauge2()
            .width(100)  // 调整为适当宽度
            .height(100) // 调整为适当高度
        }.layoutWeight(1).alignItems(HorizontalAlign.Center)
        .width('20%')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .margin({ top: 20, left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(15)
  }

  // 减少一天日期的函数
  private async decreaseDate(): Promise<void> {
    this.displayDate.setDate(this.displayDate.getDate() - 1);
    this.currentDate = this.getFormattedDate(this.displayDate);
  }

  // 增加一天日期的函数+
  private async increaseDate(): Promise<void> {
    this.displayDate.setDate(this.displayDate.getDate() + 1);
    this.currentDate = this.getFormattedDate(this.displayDate);
  }

  private getFormattedDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}

@Preview
@Component
struct Distribution_of_Focus_Duration {
  @State currentDate: string = '';
  // 【新增】使用 Date 对象来跟踪和计算日期，更易于操作
  @State displayDate: Date = new Date();
  private webController: web_webview.WebviewController = new web_webview.WebviewController();

  // aboutToAppear 生命周期钩子，在组件即将显示时执行一次
  aboutToAppear() {
    // 初始化时，根据当前日期设置显示的字符串
    this.currentDate = this.getFormattedDate(this.displayDate);
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text('专注时长分布')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text(this.currentDate)
            .fontSize(14)
            .margin({ left: 5 })
        }

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding(16)

      Web({ src: $rawfile('chart_page.html'), controller: this.webController })
        .height(300) // 为图表设置一个固定的高度
        .width('100%')
        // 4. 【关键】当网页加载完成后，执行JavaScript代码来传递数据
        .onPageEnd(() => {
          // 获取图表配置
          const option = this.getChartOption();
          // 将配置对象转换为 JSON 字符串
          const optionString = JSON.stringify(option);

          // 构造要执行的 JS 代码字符串。
          // 这会调用你在 chart_page.html 中定义的 updateChart 函数，
          // 并将图表的配置数据作为字符串参数传递过去。
          const jsCode = `updateChart('${optionString}')`;

          // 通过 webController 执行 JavaScript
          this.webController.runJavaScript(jsCode);
        })
    }
    .margin({ top: 20, left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(15)

  }

  // 【新增】减少一天日期的函数
  private decreaseDate(): void {
    this.displayDate.setDate(this.displayDate.getDate() - 1);
    // 更新日期后，重新格式化字符串以刷新UI
    this.currentDate = this.getFormattedDate(this.displayDate);
  }

  // 【新增】增加一天日期的函数
  private increaseDate(): void {
    this.displayDate.setDate(this.displayDate.getDate() + 1);
    // 更新日期后，重新格式化字符串以刷新UI
    this.currentDate = this.getFormattedDate(this.displayDate);
  }

  // 【已修改】此函数现在接收一个 Date 对象作为参数
  private getFormattedDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');

    return `${year}-${month}-${day}`;


  }

  private getChartOption(): EChartsOption {
    return {
      tooltip: {
        trigger: 'axis',
        formatter: '{b}: {c}分钟'
      },
      grid: {
        left: '50px',
        right: '20px',
        top: '10%',
        bottom: '10%',
        containLabel: true
      },
      xAxis: {
        type: 'value',
        axisLabel: {
          formatter: '{value} 分钟'
        }
      },
      yAxis: {
        type: 'category',
        data: ['任务1', '任务2', '任务3']
      },
      series: [{
        name: '任务耗时',
        type: 'bar',
        barWidth: '60%',
        data: [
          { value: 5, name: '任务1' },
          { value: 10, name: '任务2' },
          { value: 15, name: '任务3' }
        ],
        itemStyle: {
          color: (params: ColorParams) => {
            const colorList = ['#5470c6', '#91cc75', '#fac858'];
            return colorList[params.dataIndex];
          },
          barBorderRadius: [0, 10, 10, 0]
        },
        label: {
          show: true,
          position: 'right',
          formatter: '{c} 分钟',
          color: '#333'
        }
      }]
    };
  }
}

@Entry
@ComponentV2
struct Gauge2 {
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local tasks: TaskList =
    AppStorageV2.connect<TaskList>(TaskList, () => new TaskList(new ScheduleList(), new CoreflameGroupList()))!;

  @Computed
  get total() {
    return this.tasks.calculateStats().reduce((prev: number, cur: DayTaskStats): number => {
      return prev + cur.general.total
    }, 0)
  }

  @Builder
  descriptionBuilderImage() {
    Image($r('sys.media.ohos_ic_public_clock')).width(72).height(72)
  }

  build() {
    Column() {
      Gauge({ value: 50, min: 1, max: 100 }) {
        Column() {
          Text(`${this.total}`)  // ✅ 使用$$模板字符串
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .fontColor("#ff182431")
            .maxFontSize(60)        // ✅ 使用数字类型而非字符串
            .minFontSize(30)        // ✅ 使用数字类型
            .textAlign(TextAlign.Center)
            .margin({ top: '35%' })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
        }
      }
      .startAngle(210)
      .endAngle(150)
      .colors('#cca5d61d')

      .strokeWidth(18)
      .description(this.descriptionBuilderImage)
      .padding({
        top: '18.00vp',
        right: '18.00vp',
        bottom: '10.00vp',
        left: '18.00vp'
      })
    }.margin({ top: 5 }).width('100%')
  }
}