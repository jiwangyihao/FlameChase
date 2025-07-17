import { createCubicBezier } from '../utils/Bezier';
import { Design, DesignSystem } from '../utils/DesignSystem';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { parseTimeText, TimeDownState } from '../model/TimeDownState';
import { CoreflameGroup, CoreflameGroupList } from '../model/Coreflame';
import { NumberObject } from '../utils/BaseObjects';
import { AppStorageV2 } from '@kit.ArkUI';

const MAX_TIME_DOWN = 3600; // 最大倒计时，单位为秒

@AnimatableExtend(Path)
function progressStrokeDashOffset(progress: number) {
  .strokeDashOffset((30 - 240 * (progress % 1)) * Math.PI) // 调用系统属性接口，逐帧回调函数每帧修改可动画属性的值，实现逐帧布局的效果。
}


function parseScaleProgress(progress: number): number {
  progress = (progress + 0.25) % 1;
  const ease = createCubicBezier(0.25, 0.1, 0.25, 1.0)
  if (progress < 0.5) {
    return (0.8 + 0.2 * ease(progress * 2));
  } else {
    return (0.8 + 0.2 * (1 - ease((progress - 0.5) * 2)));
  }
}

@AnimatableExtend(Shape)
function progressScale(progress: number) {
  .scale({
    x: parseScaleProgress(progress),
    y: parseScaleProgress(progress)
  })
}

@ComponentV2
export struct CoreflamesPage {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local timeDownState: TimeDownState =
    AppStorageV2.connect<TimeDownState>(TimeDownState, () => new TimeDownState())!;
  @Local coreflameGroups: CoreflameGroupList =
    AppStorageV2.connect<CoreflameGroupList>(CoreflameGroupList, () => new CoreflameGroupList())!;
  @Local strokeDashOffsetProgress: number = 0;
  @Local scaleProgress: number = 0;
  @Local ringRotate: number = 0;
  @Local selectedTime: number = 0;
  private ringPath: string =
    'M 104.3368 1.0266 A 120 120 0 0 0 9.1344 165.922 ' +
      'M 24.7975 193.0513 A 120 120 0 0 0 215.2024 193.0513 ' +
      'M 230.8655 165.922 A 120 120 0 0 0 135.6631 1.0266';
  private startSelectedTime: number = 0;

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

    this.getUIContext()?.keyframeAnimateTo({
      iterations: -1,
      delay: -250
    }, [
      {
        duration: 10000,
        curve: Curve.Linear,
        event: () => {
          this.scaleProgress = 1;
        }
      },
      {
        duration: 0,
        event: () => {
          this.scaleProgress = 0;
        }
      }
    ]);

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

  build() {
    Column() {
      Text($r('app.string.Coreflames'))
        .fontSize(this.ds.getSize(1.5))
        .textAlign(TextAlign.Start)
        .lineHeight(this.ds.getSize(2))
        .fontWeight(FontWeight.Bolder)
        .width('100%')
      Column() {
        Progress({ value: this.coreflameGroups.recycledCoreflames.length, total: 12, type: ProgressType.Linear })
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
          value: 0,
          total: this.timeDownState.started
            ? this.timeDownState.total * 1.5
            : MAX_TIME_DOWN * 1.5,
          type: ProgressType.Ring
        })
          .width('85%')
          .height('85%')
          .color(new LinearGradient([
            {
              color: this.ds.getColor(this.ccm, 'primary'),
              offset: 0.5
            },
            {
              color: this.ds.getColor(this.ccm, 'primary', 500),
              offset: 1
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
              .stroke(this.ds.getColor(this.ccm, 'surface', 200, 0.25))
            Path()
              .commands(this.parsePath(this.ringPath))
              .stroke(this.ds.getColor(this.ccm, 'surface', 900))
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
          .progressScale(this.scaleProgress + 0.25 * index)
          .rotate({
            angle: this.ringRotate + 90 * index
          })
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
            if (event) {
              this.selectedTime = Math.max(
                0,
                Math.min(
                  MAX_TIME_DOWN,
                  this.startSelectedTime + Math.floor(
                    (event.offsetX - event.offsetY)
                  )
                )
              );
            }
          })
      )

      Button(
        this.timeDownState.started ? $r('app.string.CaughtInTheDarkTide') : $r('app.string.ChooseToChaseFlame'),
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
          } else {
            if (this.selectedTime > 0) {
              this.timeDownState.start(this.selectedTime).then(() => {
                const unrecycledCoreflames = this.coreflameGroups
                  .flatMap((coreflameGroup: CoreflameGroup) => coreflameGroup.unrecycledCoreflames);
                if (unrecycledCoreflames.length > 0) {
                  const randomIndex = Math.floor(Math.random() * unrecycledCoreflames.length);
                  const selectedCoreflame = unrecycledCoreflames[randomIndex];
                  selectedCoreflame.recycledTime = new Date().getTime();
                }
              }).catch((reason: string) => {
                console.error(reason);
              });
            }
            this.selectedTime = 0;
          }
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
}