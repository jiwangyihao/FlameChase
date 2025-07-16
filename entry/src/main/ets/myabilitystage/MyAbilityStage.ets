import { AbilityStage, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DesignSystem } from '../utils/DesignSystem';
import { ThemeControl } from '@kit.ArkUI';

export default class MyAbilityStage extends AbilityStage {
  onConfigurationUpdate(config: Configuration) {
    AppStorage.setOrCreate('currentColorMode', config.colorMode);
    hilog.info(0x0000, 'testTag', 'the newConfig.colorMode is %{public}s',
      JSON.stringify(AppStorage.get('currentColorMode')) ?? '');

    const ds = new DesignSystem();
    ds.register(this.context)
    ThemeControl.setDefaultTheme({
      colors: {
        brand: ds.getColor(0, 'primary'),
        fontPrimary: ds.getColor(0, 'surface', 900),
        backgroundPrimary: ds.getColor(0, 'surface', 25),
      }
    });
  }
}