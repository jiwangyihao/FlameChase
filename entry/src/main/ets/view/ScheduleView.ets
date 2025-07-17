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
  KnowledgeBlockLine(schedule: Schedule) {
    Row() {
      Image(scheduleCategoryIcons.get(schedule.category))
        .width(this.ds.getSize(1.5))
        .height(this.ds.getSize(1.5))
      Column() {
        Text(schedule.title)
          .fontSize(this.ds.getSize(1.2))
          .fontWeight(FontWeight.Regular)
        Text(schedule.description)
          .fontSize(this.ds.getSize(1))
          .fontWeight(FontWeight.Normal)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 18 })

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
        .fontSize(14)
        .fontWeight(500)
        .margin({ bottom: 8 })

      List({ space: 12 }) {
        ForEach(this.schedules.filter(schedule => schedule.type === this.type),
          (item: Schedule, index: number) => {
            ListItem() {
              this.KnowledgeBlockLine(item)
            }
          }, (item: Schedule, index: number) => item.title)
      }
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding({ left: 12, right: 12 })
      .divider({
        strokeWidth: 0.5,
        startMargin: 38,
        endMargin: 0,
        color: '#F2F2F2'
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