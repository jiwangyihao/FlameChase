import { NumberObject } from '../utils/BaseObjects';
import { Design, DesignSystem } from '../utils/DesignSystem';
import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { Schedule, ScheduleCategory, scheduleCategoryIcons, ScheduleList } from '../model/Schedule';
import { ScheduleView } from '../view/ScheduleView';


@ComponentV2
export struct SchedulePage {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local schedules: ScheduleList = AppStorageV2.connect<ScheduleList>(ScheduleList, () => new ScheduleList())!;
  @Local showDialog: boolean = false;
  @Local selectedCategory: ScheduleCategory = ScheduleCategory.CHAOS;
  @Local scheduleName: string = "";
  @Local scheduleDescription: string = "";
  @Local scheduleDuration: number = 0;

  @Builder
  dialogBuilder() {
    Column({ space: this.ds.getSize(0.25) }) {
      Text("选择计划类别")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .margin({
          bottom: this.ds.getSize(0.25),
        })
      Row() {
        ForEach([
          ScheduleCategory.CHAOS,
          ScheduleCategory.STUDY,
          ScheduleCategory.WORK,
          ScheduleCategory.EXERCISE,
          ScheduleCategory.PONDER
        ], (category: ScheduleCategory) => {
          Column({ space: this.ds.getSize(0.5) }) {
            Image(scheduleCategoryIcons.get(category))
              .width(this.ds.getSize(1.5))
              .height(this.ds.getSize(1.5))
              .fillColor(
                this.selectedCategory === category
                  ? this.ds.getColor(this.ccm, 'primary')
                  : this.ds.getColor(this.ccm, 'surface', 800, 0.6)
              )
            Text($r(`app.string.${category}`))
              .fontSize(this.ds.getSize(1))
              .fontWeight(FontWeight.Bold)
              .fontColor(
                this.selectedCategory === category
                  ? this.ds.getColor(this.ccm, 'primary')
                  : this.ds.getColor(this.ccm, 'surface', 800, 0.6)
              )
          }
          .backgroundColor(
            this.selectedCategory === category
              ? this.ds.getColor(this.ccm, 'primary', 100, 0.2)
              : this.ds.getColor(this.ccm, 'surface', 100, 0.2)
          )
          .borderColor(
            this.selectedCategory === category
              ? this.ds.getColor(this.ccm, 'primary', Design.DefaultVariation, 0.5)
              : this.ds.getColor(this.ccm, 'surface', 800, 0.3)
          )
          .borderWidth(this.ds.getSize(0.15))
          .width(this.ds.getSize(4))
          .height(this.ds.getSize(5))
          .borderRadius(this.ds.getSize(1))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.selectedCategory = category;
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        bottom: this.ds.getSize(1),
      })

      Text("计划名称")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      TextInput({
        text: this.scheduleName!!,
        placeholder: "请输入计划名称",
      })
        .type(InputType.Normal)
        .margin({
          bottom: this.ds.getSize(1),
        })
        .backgroundColor(this.ds.getColor(this.ccm, 'surface', 100, 0.2))
        .borderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.3))
        .borderWidth(this.ds.getSize(0.1))
        .borderRadius(this.ds.getSize(0.5))
        .placeholderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.5))

      Text("计划描述")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      TextArea({
        text: this.scheduleDescription!!,
        placeholder: "请输入计划描述\n\n",
      })
        .margin({
          bottom: this.ds.getSize(1),
        })
        .backgroundColor(this.ds.getColor(this.ccm, 'surface', 100, 0.2))
        .borderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.3))
        .borderWidth(this.ds.getSize(0.1))
        .borderRadius(this.ds.getSize(0.5))
        .placeholderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.5))

      Row() {
        Text("计划时长")
          .fontSize(this.ds.getSize(1))
          .fontWeight(FontWeight.Bold)
        Text(this.scheduleDuration.toFixed(0) + " 分钟")
          .fontSize(this.ds.getSize(1))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({
        value: this.scheduleDuration,
        step: 30,
        style: SliderStyle.InSet,
        max: 600,
      })
        .trackColor(this.ds.getColor(this.ccm, 'surface', 100, 0.2))
        .blockColor(this.ds.getColor(this.ccm, 'surface', 800, 0.3))
        .selectedColor(this.ds.getColor(this.ccm, 'primary', 500, 0.8))
        .showSteps(true)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.scheduleDuration = value;
          console.info('value:' + value + 'mode:' + mode.toString());
        })
        .margin({
          bottom: this.ds.getSize(1),
        })

      Button(
        '提交',
        { type: ButtonType.Normal, stateEffect: true }
      )
        .linearGradient({
          angle: 150,
          colors: [
            [
              this.ds.getColor(this.ccm, 'primary', 500),
              0
            ],
            [
              this.ds.getColor(this.ccm, 'primary', 600),
              0.5
            ],
          ]
        })
        .opacity(this.scheduleDuration && this.scheduleName && this.scheduleName ? 1 : 0.5)
        .borderRadius(8)
        .width(this.ds.getSize(6))
        .height(this.ds.getSize(2.5))
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          if (this.scheduleDuration && this.scheduleName && this.scheduleName) {
            this.schedules.push(new Schedule(
              this.scheduleName,
              this.scheduleDescription,
              new Date().getTime(),
              this.scheduleDuration,
              this.selectedCategory
            ));
            this.showDialog = false;
            this.scheduleName = "";
            this.scheduleDescription = "";
            this.scheduleDuration = 0;
          } else {
            console.warn("请填写完整的计划信息");
          }
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: this.ds.getSize(1),
      right: this.ds.getSize(1),
    })
  }

  build() {
    Column() {
      Text($r('app.string.Schedule'))
        .fontSize(this.ds.getSize(1.5))
        .textAlign(TextAlign.Start)
        .lineHeight(this.ds.getSize(2))
        .fontWeight(FontWeight.Bolder)
        .width('100%')

      Stack() {
        if (this.schedules.length === 0) {
          Text("还没有计划，快创建一个吧！")
            .fontSize(this.ds.getSize(1.5))
            .fontColor(this.ds.getColor(this.ccm, 'surface', 900, 0.5))
            .textAlign(TextAlign.Center)
            .lineHeight('100%')
            .fontWeight(FontWeight.Bolder)
            .width('100%')
            .height('100%')
        } else {
          ScheduleView()
          ScheduleView({
            type: 'completed'
          })
        }

        Button() {
          Image($r('app.media.material_symbols__add_rounded'))
            .width(this.ds.getSize(3))
            .height(this.ds.getSize(3))
            .fillColor(this.ds.getColor(this.ccm, 'primary', 0))
        }
        .linearGradient({
          angle: 150,
          colors: [
            [
              this.ds.getColor(this.ccm, 'primary', 500),
              0
            ],
            [
              this.ds.getColor(this.ccm, 'primary', 600),
              0.5
            ],
          ]
        })
        .width(this.ds.getSize(4))
        .height(this.ds.getSize(4))
        .position({
          right: this.ds.getSize(1),
          bottom: this.ds.getSize(0)
        })
        .onClick(() => {
          this.showDialog = true;
        })
        .bindSheet($$this.showDialog, this.dialogBuilder(), {
          backgroundColor: this.ds.getColor(this.ccm, 'surface', 50, 0.2),
          detents: [this.ds.getSize(20), SheetSize.MEDIUM, SheetSize.LARGE],
          blurStyle: BlurStyle.Thick,
          maskColor: this.ds.getColor(this.ccm, 'surface', 950, 0.2),
          showClose: true,
          title: { title: "新建计划" },
          width: '95%',
          borderWidth: this.ds.getSize(0.15),
          borderColor: this.ds.getColor(this.ccm, 'surface', 950, 0.25)
        })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
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
