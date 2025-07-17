import { DesignSystem } from '../utils/DesignSystem';

@ComponentV2
export struct ChroniclePage {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();

  build() {
    Column() {
      Text($r('app.string.Chronicle'))
        .fontSize(this.ds.getSize(1.5))
        .textAlign(TextAlign.Start)
        .lineHeight(this.ds.getSize(2))
        .fontWeight(FontWeight.Bolder)
        .width('100%')
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