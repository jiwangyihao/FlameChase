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
      Column() {
        Text(schedule.title)
          .fontSize(this.ds.getSize(1.2))
          .fontWeight(FontWeight.Regular)
        Text(schedule.description)
          .fontSize(this.ds.getSize(1))
          .fontWeight(FontWeight.Normal)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.ds.getSize(1) })

      Blank()
      // Image($r('app.media.ic_arrow'))
      //   .width(12)
      //   .height(24)
    }
    .width('100%')
    .height(this.ds.getSize(5))
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      Text("进行中")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: this.ds.getSize(0.5) })

      List({ space: this.ds.getSize(1) }) {
        ForEach(
          this.schedules
            .filter(schedule => Number(this.type === 'ongoing') ^ Number(schedule.progress >= schedule.total)),
          (item: Schedule, index: number) => {
            ListItem() {
              this.ScheduleBlockLine(item)
            }
          }, (item: Schedule, index: number) => item.title)
      }
      .backgroundColor(this.ds.getColor(this.ccm, 'surface', 100, 0.5))
      .borderRadius(this.ds.getSize(1))
      .padding({ left: this.ds.getSize(1), right: this.ds.getSize(1) })
      .divider({
        strokeWidth: this.ds.getSize(0.1),
        color: this.ds.getColor(this.ccm, 'surface', 800, 0.25)
      })
      .lanes(new BreakpointType<number>({
        sm: 1,
        md: 1,
        lg: 2,
        xl: 2
      }).getValue(this.currentBreakpoint.value))
    }
    .width('100%')
    .margin({ top: 28 })
    .alignItems(HorizontalAlign.Start)
  }
}