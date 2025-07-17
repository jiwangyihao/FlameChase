import { createCubicBezier } from '../utils/Bezier';
import { Design, DesignSystem } from '../utils/DesignSystem';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { parseTimeText, TimeDownState } from '../model/TimeDownState';
import { Coreflame, CoreflameGroup, CoreflameGroupList } from '../model/Coreflame';
import { NumberObject } from '../utils/BaseObjects';
import { AppStorageV2, display, ImmersiveMode, promptAction } from '@kit.ArkUI';
import { Schedule, ScheduleCategory, scheduleCategoryIcons, ScheduleList } from '../model/Schedule';
import { Task, TaskList } from '../model/Task';

const MAX_TIME_DOWN = 3600; // 最大倒计时，单位为秒

@AnimatableExtend(Path)
function progressStrokeDashOffset(progress: number) {
  .strokeDashOffset((30 - 240 * (progress % 1)) * Math.PI) // 调用系统属性接口，逐帧回调函数每帧修改可动画属性的值，实现逐帧布局的效果。
}

function parseScaleProgress(progress: number, scale: number): number {
  progress = (progress + 0.25) % 1;
  const ease = createCubicBezier(0.25, 0.1, 0.25, 1.0)
  if (progress < 0.5) {
    return (0.8 + 0.2 * ease(progress * 2) / scale);
  } else {
    return (0.8 + 0.2 * (1 - ease((progress - 0.5) * 2)) / scale);
  }
}

class ProgressScaleParam implements AnimatableArithmetic<ProgressScaleParam> {
  progress: number;
  scale: number;

  constructor(progress: number, scale: number) {
    this.progress = progress;
    this.scale = scale;
  }

  plus(rhs: ProgressScaleParam): ProgressScaleParam {
    return new ProgressScaleParam(
      this.progress + rhs.progress,
      this.scale + rhs.scale
    );
  }

  subtract(rhs: ProgressScaleParam): ProgressScaleParam {
    return new ProgressScaleParam(
      this.progress - rhs.progress,
      this.scale - rhs.scale
    );
  }

  multiply(scale: number): ProgressScaleParam {
    return new ProgressScaleParam(
      this.progress * scale,
      this.scale * scale
    );
  }

  equals(rhs: ProgressScaleParam): boolean {
    return this.progress === rhs.progress && this.scale === rhs.scale;
  }
}

@AnimatableExtend(Shape)
function progressScale(param: ProgressScaleParam) {
  .scale({
    x: parseScaleProgress(param.progress, param.scale) * param.scale,
    y: parseScaleProgress(param.progress, param.scale) * param.scale
  })
}

@ComponentV2
export struct CoreflamesPage {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local topRectHeight: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'topRectHeight',
    () => new NumberObject(0))!;
  @Local bottomRectHeight: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'bottomRectHeight',
    () => new NumberObject(0))!;
  @Local timeDownState: TimeDownState =
    AppStorageV2.connect<TimeDownState>(TimeDownState, () => new TimeDownState())!;
  @Local coreflameGroups: CoreflameGroupList =
    AppStorageV2.connect<CoreflameGroupList>(CoreflameGroupList, () => new CoreflameGroupList())!;
  @Local schedules: ScheduleList = AppStorageV2.connect<ScheduleList>(ScheduleList, () => new ScheduleList())!;
  @Local tasks: TaskList =
    AppStorageV2.connect<TaskList>(TaskList, () => new TaskList(this.schedules, this.coreflameGroups))!;
  @Local strokeDashOffsetProgress: number = 0;
  @Local scaleProgress: number = 0;
  @Local ringRotate: number = 0;
  @Local selectedTime: number = 0;
  @Local showDialog: boolean = false;
  @Local coreflameGroupsCompletedFlag: boolean[] = this.coreflameGroupsCompleted;
  @Local showFinishProgress: boolean = false;
  private ringPath: string =
    'M 104.3368 1.0266 A 120 120 0 0 0 9.1344 165.922 ' +
      'M 24.7975 193.0513 A 120 120 0 0 0 215.2024 193.0513 ' +
      'M 230.8655 165.922 A 120 120 0 0 0 135.6631 1.0266';
  private startSelectedTime: number = 0;

  @Computed
  get coreflameGroupsCompleted(): boolean[] {
    return this.coreflameGroups.map((group: CoreflameGroup) => {
      return group.coreflames.every((coreflame: Coreflame) => coreflame.recycledTime > 0);
    });
  }

  onDidBuild(): void {
    this.getUIContext()?.keyframeAnimateTo({
      iterations: -1
    }, [
      {
        duration: 30000,
        curve: Curve.Linear,
        event: () => {
          this.strokeDashOffsetProgress = 1;
        }
      },
      {
        duration: 0,
        event: () => {
          this.strokeDashOffsetProgress = 0;
        }
      }
    ]);

    const scaleAnimation = () => {
      if (this.scaleProgress === 1) {
        this.getUIContext()?.animateTo({
          iterations: 1,
          duration: 0,
          onFinish: () => {
            scaleAnimation();
          }
        }, () => {
          this.scaleProgress = 0;
        })
      } else {
        this.getUIContext()?.animateTo({
          iterations: 1,
          duration: 5000,
          curve: Curve.Linear,
          onFinish: () => {
            scaleAnimation();
          }
        }, () => {
          this.scaleProgress = this.scaleProgress + 0.5;
          this.coreflameGroupsCompletedFlag = this.coreflameGroupsCompleted;
        })
      }
    }
    scaleAnimation()

    this.getUIContext()?.keyframeAnimateTo({
      iterations: -1
    }, [
      {
        duration: 16000,
        curve: Curve.Linear,
        event: () => {
          this.ringRotate = 360;
        }
      },
      {
        duration: 0,
        event: () => {
          this.ringRotate = 0;
        }
      }
    ]);
  }

  @Builder
  customDialogComponent(coreflame: Coreflame, dialogController: promptAction.DialogController) {
    Column() {
      if (coreflame.name == "坏火") {
        Text("收集失败.")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })
      } else {
        Text("收集成功！")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })
      }
      Text(coreflame.description)
        .fontSize(20)     //改size
        .fontWeight(FontWeight.Normal)
        .fontColor('#666666')
        .margin({ bottom: 36 })
      Button('好的')
      // .backgroundColor('#E0E0E0')
        .fontColor('#333333')
        .width(120)
        .height(45)
        .borderRadius(8)
    }
    .backgroundColor(this.ds.getColor(this.ccm, 'surface', 0, 0))
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({
      top: px2vp(this.topRectHeight.value),
      bottom: px2vp(this.bottomRectHeight.value),
    })
    .onClick(() => {
      dialogController.close() // 使用控制器关闭
    })
  }

  @Builder
  startPanelBuilder() {
    Column({ space: this.ds.getSize(0.25) }) {
      Text("- 选择类别快速开始 - ")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor(
          this.ds.getColor(this.ccm, 'surface', 900, 0.6)
        )
        .width('100%')
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
                this.ds.getColor(this.ccm, 'surface', 800, 0.6)
              )
            Text($r(`app.string.${category}`))
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
          .width(this.ds.getSize(4))
          .height(this.ds.getSize(5))
          .borderRadius(this.ds.getSize(1))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            let selectedCoreflame: Coreflame | null = null;
            if (category === ScheduleCategory.CHAOS) {
              selectedCoreflame = this.coreflameGroups.getRandomCoreflame();
            } else {
              selectedCoreflame = this.coreflameGroups.getRandomCoreflameByCategory(category);
            }
            this.startTask(new Task(this.selectedTime, -1, null, selectedCoreflame, category));
            this.showDialog = false;
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        bottom: this.ds.getSize(1),
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: this.ds.getSize(1),
      right: this.ds.getSize(1),
    })

    Text("- OR 继续计划 - ")
      .fontSize(this.ds.getSize(1))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .fontColor(
        this.ds.getColor(this.ccm, 'surface', 900, 0.6)
      )
      .width('100%')
      .margin({
        bottom: this.ds.getSize(0.25),
      })
    if (this.schedules.ongoingSchedules().length > 0) {
      ForEach(this.schedules.ongoingSchedules(), (schedule: Schedule, index: number) => {
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
        .backgroundColor(
          this.ds.getColor(this.ccm, 'surface', 100, 0.2)
        )
        .borderColor(
          this.ds.getColor(this.ccm, 'surface', 800, 0.3)
        )
        .borderWidth(this.ds.getSize(0.15))
        .width('100%')
        .height(this.ds.getSize(4))
        .borderRadius(this.ds.getSize(1))
        .justifyContent(FlexAlign.Center)
        .padding({
          left: this.ds.getSize(1),
          right: this.ds.getSize(1),
        })
        .margin({
          bottom: this.ds.getSize(0.5),
        })
        .onClick(() => {
          let selectedCoreflame: Coreflame | null = null;
          if (schedule.category === ScheduleCategory.CHAOS) {
            selectedCoreflame = this.coreflameGroups.getRandomCoreflame();
          } else {
            selectedCoreflame = this.coreflameGroups.getRandomCoreflameByCategory(schedule.category);
          }
          this.startTask(new Task(this.selectedTime, -1, schedule, selectedCoreflame));
          this.showDialog = false;
        })
      }, (item: Schedule, index: number) => item.id);
    } else {
      Row({ space: this.ds.getSize(0.5) }) {
        Text('暂无计划')
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
    }
  }

  build() {
    Column() {
      Text($r('app.string.Coreflames'))
        .fontSize(this.ds.getSize(1.5))
        .textAlign(TextAlign.Start)
        .lineHeight(this.ds.getSize(2))
        .fontWeight(FontWeight.Bolder)
        .width('100%')
      Column() {
        Progress({
          value: this.coreflameGroups.recycledCoreflames.length,
          total: this.coreflameGroups.flatMap(group => group.coreflames).length,
          type: ProgressType.Linear
        })
          .color(this.ds.getColor(this.ccm, 'primary'))
          .backgroundColor(this.ds.getColor(this.ccm, 'primary', 200, 0.15))
          .style({
            strokeWidth: this.ds.getSize(1)
          })
          .border({
            color: this.ds.getColor(this.ccm, 'primary', 200),
            width: this.ds.getSize(0.1)
          })
          .borderRadius(this.ds.getSize(100))
        Text(this.coreflameGroups.recycledCoreflames.length >= 12 ? $r('app.string.HasRecycledCoreflames') :
        $r('app.string.ToRecycleCoreflames'))
          .fontSize(this.ds.getSize(1))
          .lineHeight(this.ds.getSize(2))
          .fontWeight(FontWeight.Bolder)
          .textAlign(TextAlign.Center)
          .fontColor(this.ds.getColor(this.ccm, 'primary', Design.DefaultVariation, 0.6))
          .width('100%')

      }

      Stack() {
        // Core time-down component
        Progress({
          value: MAX_TIME_DOWN,
          total: MAX_TIME_DOWN * 1.5,
          type: ProgressType.Ring
        })
          .width('85%')
          .height('85%')
          .color(this.ds.getColor(this.ccm, 'primary', 200, 0.15))
          .style({
            strokeWidth: this.ds.getSize(1)
          })
          .backgroundColor(this.ds.getColor(this.ccm, 'surface', 0, 0))
          .rotate({
            angle: -120
          })

        Progress({
          value: this.showFinishProgress ? MAX_TIME_DOWN : 0,
          total: MAX_TIME_DOWN * 1.5,
          type: ProgressType.Ring
        })
          .width('85%')
          .height('85%')
          .color(new LinearGradient([
            {
              color: this.ds.getColor(
                this.ccm,
                'primary',
                500
              ),
              offset: 0
            },
            {
              color: this.ds.getColor(
                this.ccm,
                'primary',
                600
              ),
              offset: 0.5
            }
          ]))
          .style({
            strokeWidth: this.ds.getSize(1)
          })
          .backgroundColor(this.ds.getColor(this.ccm, 'surface', 0, 0))
          .rotate({
            angle: -120
          })

        Progress({
          value: this.timeDownState.started
            ? this.timeDownState.timeDown / this.timeDownState.total * MAX_TIME_DOWN
            : this.selectedTime,
          total: MAX_TIME_DOWN * 1.5,
          type: ProgressType.Ring
        })
          .width('85%')
          .height('85%')
          .color(new LinearGradient([
            {
              color: this.ds.getColor(
                this.ccm,
                'surface',
                this.timeDownState.started ? 800 : this.selectedTime / MAX_TIME_DOWN * 300 + 500
              ),
              offset: 0
            },
            {
              color: this.ds.getColor(
                this.ccm,
                'surface',
                this.timeDownState.started ? 900 : this.selectedTime / MAX_TIME_DOWN * 300 + 600
              ),
              offset: 0.5
            }
          ]))
          .style({
            strokeWidth: this.ds.getSize(1)
          })
          .backgroundColor(this.ds.getColor(this.ccm, 'surface', 0, 0))
          .rotate({
            angle: -120
          })

        ForEach(this.coreflameGroups, (coreflameGroup: CoreflameGroup, index: number) => {
          Shape() {
            Path()
              .commands(this.parsePath(this.ringPath))
              .stroke(
                this.coreflameGroupsCompleted[index]
                  ? this.ds.getColor(this.ccm, 'primary', 200, 0.25)
                  : this.ds.getColor(this.ccm, 'surface', 200, 0.25)
              )
            Path()
              .commands(this.parsePath(this.ringPath))
              .stroke(
                this.coreflameGroupsCompleted[index]
                  ? this.ds.getColor(this.ccm, 'primary')
                  : this.ds.getColor(this.ccm, 'surface', 900)
              )
              .strokeDashArray([10, 240 * Math.PI])
              .progressStrokeDashOffset((this.strokeDashOffsetProgress) * 4 + 0.25 * index)
            Path()
              .commands(this.parsePath("M 120 -18 Q 120 0 108 0 Q 120 0 120 18 Q 120 0 132 0 Q 120 0 120 -18 Z"))
              .stroke(
                coreflameGroup.coreflames[0].recycledTime > 0
                  ? this.ds.getColor(this.ccm, 'primary')
                  : this.ds.getColor(this.ccm, 'surface', 900)
              )
              .strokeWidth(1)
              .strokeDashArray([30 * Math.PI, 240 * Math.PI])
              .progressStrokeDashOffset(this.strokeDashOffsetProgress + 0.25 * index + 0.1)
              .fill(
                coreflameGroup.coreflames[0].recycledTime > 0
                  ? this.ds.getColor(this.ccm, 'primary', 400)
                  : this.ds.getColor(this.ccm, 'surface', 200)
              )
              .fillOpacity(1)
            Path()
              .commands(this.parsePath("M 235.7941 186.5229 Q 223.9231 180 217.9231 190.3923 Q 223.9231 180 208.3346 171 Q 223.9231 180 229.9231 169.6076 Q 223.9231 180 235.7941 186.5229 Z"))
              .stroke(
                coreflameGroup.coreflames[1].recycledTime > 0
                  ? this.ds.getColor(this.ccm, 'primary')
                  : this.ds.getColor(this.ccm, 'surface', 900)
              )
              .strokeWidth(1)
              .strokeDashArray([30 * Math.PI, 240 * Math.PI])
              .progressStrokeDashOffset(this.strokeDashOffsetProgress + 0.25 * index + 0.1)
              .fill(
                coreflameGroup.coreflames[1].recycledTime > 0
                  ? this.ds.getColor(this.ccm, 'primary', 400)
                  : this.ds.getColor(this.ccm, 'surface', 200)
              )
              .fillOpacity(1)
            Path()
              .commands(this.parsePath("M 3.6328 186.5229 Q 16.0769 180 10.0769 169.6076 Q 16.0769 180 31.6654 171 Q 16.0769 180 22.0769 190.3923 Q 16.0769 180 3.6328 186.5229 Z"))
              .stroke(
                coreflameGroup.coreflames[2].recycledTime > 0
                  ? this.ds.getColor(this.ccm, 'primary')
                  : this.ds.getColor(this.ccm, 'surface', 900)
              )
              .strokeWidth(1)
              .strokeDashArray([30 * Math.PI, 240 * Math.PI])
              .progressStrokeDashOffset(this.strokeDashOffsetProgress + 0.25 * index + 0.1)
              .fill(
                coreflameGroup.coreflames[2].recycledTime > 0
                  ? this.ds.getColor(this.ccm, 'primary', 400)
                  : this.ds.getColor(this.ccm, 'surface', 200)
              )
              .fillOpacity(1)
          }
          .viewPort({
            x: -60,
            y: -60,
            width: 360,
            height: 360
          })
          .width('100%')
          .height('100%')
          .strokeWidth(2)
          .fillOpacity(0)
          .rotate({
            angle: this.ringRotate + 90 * index
          })
          .progressScale(
            new ProgressScaleParam(
              this.scaleProgress + 0.25 * index,
              this.coreflameGroupsCompletedFlag[index] ? 1.75 : 1
            )
          )
        }, (item: number) => item.toString())

        Text(
          this.timeDownState.started
            ? this.timeDownState.timeDownText
            : parseTimeText(this.selectedTime)
        ) {
        }
        .fontSize(this.ds.getSize(3))
        .fontWeight(FontWeight.Bolder)
        .fontColor(this.ds.getColor(this.ccm, 'primary', 600))
      }
      .width('100%')
      .aspectRatio(1)
      .gesture(
        PanGesture()
          .onActionStart((event: GestureEvent | undefined) => {
            if (event) {
              this.startSelectedTime = this.selectedTime;
            }
          })
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event && !this.timeDownState.started) {
              this.showFinishProgress = false;
              this.selectedTime = Math.max(
                0,
                Math.min(
                  MAX_TIME_DOWN,
                  this.startSelectedTime + Math.floor(
                    (event.offsetX - event.offsetY) / 3
                  )
                )
              );
            }
          })
      )

      Button(
        this.timeDownState.started ? '堕入黑潮' : '选择逐火',
        { type: ButtonType.Normal, stateEffect: true }
      )
        .linearGradient({
          angle: 150,
          colors: [
            [
              this.timeDownState.started
                ? this.ds.getColor(this.ccm, 'surface', 800)
                : this.ds.getColor(this.ccm, 'primary', 500),
              0
            ],
            [
              this.timeDownState.started
                ? this.ds.getColor(this.ccm, 'surface', 900)
                : this.ds.getColor(this.ccm, 'primary', 600),
              0.5
            ],
          ]
        })
        .opacity(this.selectedTime && !this.timeDownState.started ? 1 : 0.5)
        .borderRadius(8)
        .width(this.ds.getSize(8))
        .height(this.ds.getSize(2.5))
        .onClick(() => {
          if (this.timeDownState.started) {
            this.timeDownState.stop();
          }
          if (this.selectedTime > 0) {
            this.showDialog = true;
          }
        })
        .bindSheet($$this.showDialog, this.startPanelBuilder(), {
          backgroundColor: this.ds.getColor(this.ccm, 'surface', 50, 0.2),
          detents: [this.ds.getSize(20), SheetSize.MEDIUM, SheetSize.LARGE],
          blurStyle: BlurStyle.Thick,
          maskColor: this.ds.getColor(this.ccm, 'surface', 950, 0.2),
          showClose: true,
          title: { title: "启程" },
          width: '95%',
          borderWidth: this.ds.getSize(0.15),
          borderColor: this.ds.getColor(this.ccm, 'surface', 950, 0.25),
          preferType: SheetType.BOTTOM
        })

      Row() {
        // Placeholder for space control
      }
    }
    .height('100%')
    .width('100%')
    .padding({
      left: this.ds.getSize(1),
      right: this.ds.getSize(1),
      bottom: this.ds.getSize(1.5),
      top: this.ds.getSize(2)
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  private parsePath(pathInVp: string) {
    return pathInVp.split(' ')
      .map((item) => {
        const num = parseFloat(item);
        return isNaN(num) ? item : (vp2px(num)).toString();
      })
      .join(' ');
  }

  private finishTask(task: Task) {
    this.showFinishProgress = true;
    if (task.bindCoreflame) {
      task.bindCoreflame.recycledTime = new Date().getTime();
    }
    task.finishedAt = new Date().getTime();
    this.tasks.addTask(task);
  }

  private startTask(task: Task) {
    this.timeDownState.start(this.selectedTime).then(() => {
      if (task.bindSchedule) {
        task.bindSchedule.progress += task.total;
      }
      if (task.bindCoreflame) {
        // 创建对话框控制器
        let dialogController: promptAction.DialogController = new promptAction.DialogController();
        this.getUIContext().getPromptAction().presentCustomDialog(
          () => {
            this.customDialogComponent(task.bindCoreflame!, dialogController)
          },
          dialogController,
          {
            maskColor: this.ds.getColor(this.ccm, 'surface', 950, 0.2),
            backgroundBlurStyle: BlurStyle.Thin,
            width: '100%',
            height: px2vp(display.getDefaultDisplaySync().height),
            offset: {
              dx: 0,
              dy: -px2vp(this.topRectHeight.value)
            },
            immersiveMode: ImmersiveMode.EXTEND,
            cornerRadius: 0,
            onDidDisappear: () => {
              this.finishTask(task);
            }
          }
        );
      }
    }).catch((reason: string) => {
      console.error(reason);
      const errorCoreflame = new Coreflame('坏火', '', "抱歉，逐梦火光暂时熄灭了。");
      let errorDialogController: promptAction.DialogController = new promptAction.DialogController();
      this.getUIContext().getPromptAction().presentCustomDialog(
        () => {
          this.customDialogComponent(errorCoreflame, errorDialogController)
        },
        errorDialogController,
        {
          maskColor: this.ds.getColor(this.ccm, 'surface', 950, 0.2),
          backgroundBlurStyle: BlurStyle.Thin,
          width: '100%',
          height: px2vp(display.getDefaultDisplaySync().height),
          offset: {
            dx: 0,
            dy: -px2vp(this.topRectHeight.value)
          },
          immersiveMode: ImmersiveMode.EXTEND,
          cornerRadius: 0,
        }
      );
    });
    this.selectedTime = 0;
  }
}