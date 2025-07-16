import { DesignSystem } from '../utils/DesignSystem';

@Component
export struct SchedulePage {
  @Consume('DesignSystem') ds: DesignSystem;

  build() {
    Column() {
      Text($r('app.string.Schedule'))
        .fontSize(this.ds.getSize(1.5))
        .textAlign(TextAlign.Start)
        .lineHeight(this.ds.getSize(2))
        .fontWeight(FontWeight.Bolder)
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}