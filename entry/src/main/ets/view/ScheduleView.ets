import { NumberObject, StringObject } from '../utils/BaseObjects';
import { DesignSystem } from '../utils/DesignSystem';
import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { Schedule, scheduleCategoryIcons, ScheduleList } from '../model/Schedule';
import { BreakpointType, BreakpointTypeEnum } from '../utils/BreakpointSystem';


@ComponentV2
export struct ScheduleView {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local currentBreakpoint: StringObject =
    AppStorageV2.connect<StringObject>(StringObject, 'currentBreakpoint',
      () => new StringObject(BreakpointTypeEnum.MD))!;
  @Local schedules: ScheduleList = AppStorageV2.connect<ScheduleList>(ScheduleList, () => new ScheduleList())!;
  @Param type: 'ongoing' | 'completed' = 'ongoing';

  @Builder
  ScheduleBlockLine(schedule: Schedule) {
    Row() {
      Image(scheduleCategoryIcons.get(schedule.category))
        .width(this.ds.getSize(1.5))
        .height(this.ds.getSize(1.5))
        .fillColor(
          this.ds.getColor(this.ccm, 'surface', 900)
        )
      Column({ space: this.ds.getSize(0.25) }) {
        Row() {
          Text(schedule.title)
            .fontSize(this.ds.getSize(1.2))
            .fontWeight(FontWeight.Bold)

          Text(`${schedule.progress}/${schedule.total}`)
            .fontSize(this.ds.getSize(1.2))
            .fontWeight(FontWeight.Regular)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')

        Progress({ value: schedule.progress, total: schedule.total, type: ProgressType.Linear })
          .color(this.ds.getColor(this.ccm, 'primary'))
          .backgroundColor(this.ds.getColor(this.ccm, 'primary', 200, 0.15))
          .style({
            strokeWidth: this.ds.getSize(0.75)
          })
          .border({
            color: this.ds.getColor(this.ccm, 'primary', 200),
            width: this.ds.getSize(0.1)
          })
          .borderRadius(this.ds.getSize(100))
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.ds.getSize(1), right: this.ds.getSize(1.5) })
      .flexGrow(1)
    }
    .width('100%')
    .height(this.ds.getSize(5))
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      Text(this.type === 'ongoing' ? "进行中" : "已完成")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: this.ds.getSize(0.5) })

      if (
        (this.type === 'ongoing'
          ? this.schedules.ongoingSchedules()
          : this.schedules.completedSchedules())
          .length === 0
      ) {
        Row() {
          Text(this.type === 'ongoing' ? "暂无进行中的计划，新建一个吧！" : "暂无已完成的计划，加油哦！")
            .fontSize(this.ds.getSize(1))
            .fontWeight(FontWeight.Bold)
            .fontColor(
              this.ds.getColor(this.ccm, 'surface', 800, 0.6)
            )
        }
        .backgroundColor(
          this.ds.getColor(this.ccm, 'surface', 100, 0.2)
        )
        .borderColor(
          this.ds.getColor(this.ccm, 'surface', 800, 0.3)
        )
        .borderWidth(this.ds.getSize(0.15))
        .width('100%')
        .height(this.ds.getSize(5))
        .borderRadius(this.ds.getSize(1))
        .justifyContent(FlexAlign.Center)
        .margin({
          bottom: this.ds.getSize(1),
        })
      } else {
        List() {
          ForEach(this.type === 'ongoing' ? this.schedules.ongoingSchedules() : this.schedules.completedSchedules(),
            (item: Schedule, index: number) => {
              ListItem() {
                this.ScheduleBlockLine(item)
              }
            }, (item: Schedule, index: number) => item.title)
        }
        .padding({ left: this.ds.getSize(1), right: this.ds.getSize(1) })
        .divider({
          strokeWidth: this.ds.getSize(0.1),
          color: this.ds.getColor(this.ccm, 'surface', 800, 0.25)
        })
        .backgroundColor(this.ds.getColor(this.ccm, 'surface', 100, 0.5))
        .borderColor(
          this.ds.getColor(this.ccm, 'surface', 800, 0.3)
        )
        .borderWidth(this.ds.getSize(0.15))
        .borderRadius(this.ds.getSize(1))
        .lanes(new BreakpointType<number>({
          sm: 1,
          md: 1,
          lg: 2,
          xl: 2
        }).getValue(this.currentBreakpoint.value))
      }
    }
    .width('100%')
    .margin({ top: 28 })
    .alignItems(HorizontalAlign.Start)
  }
}