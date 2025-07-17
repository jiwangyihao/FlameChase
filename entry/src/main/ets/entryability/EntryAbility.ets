import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, ThemeControl, window } from '@kit.ArkUI';
import { DesignSystem } from '../utils/DesignSystem';
import { CoreflameGroup, CoreflameGroupList, getCoreflamesFromJSON } from '../model/Coreflame';
import { preferences } from '@kit.ArkData';
import { NumberObject } from '../utils/BaseObjects';
import { Schedule, ScheduleList } from '../model/Schedule';
import { TaskESObject, TaskList } from '../model/Task';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;


export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(this.context.config.colorMode!));

    // Initialize the Coreflames
    const coreflames = getCoreflamesFromJSON(this.context)
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);
    const startOfTodayTimestamp = startOfToday.getTime();
    const coreflamesPreferences = preferences.getPreferencesSync(this.context, { name: 'Coreflames' });
    const coreflameGroups: CoreflameGroup[] = []
    for (const coreflame of coreflames) {
      if (coreflamesPreferences.hasSync(coreflame.name)) {
        coreflame.recycledTime = coreflamesPreferences.getSync(coreflame.name, 0) as number - startOfTodayTimestamp;
      }
      if (coreflameGroups.find(group => group.type === coreflame.type) === undefined) {
        coreflameGroups.push(new CoreflameGroup([coreflame]));
      } else {
        const group = coreflameGroups.find(group => group.type === coreflame.type);
        if (group) {
          group.coreflames.push(coreflame);
        }
      }
    }
    const coreflameGroupList =
      AppStorageV2.connect<CoreflameGroupList>(CoreflameGroupList, () => new CoreflameGroupList(...coreflameGroups));

    //Initialize Schedule
    const schedulePreferences = preferences.getPreferencesSync(this.context, { name: 'Schedule' });
    const schedules =
      new ScheduleList(...(JSON.parse(schedulePreferences.getSync('schedules', "[]") as string) as Schedule[]));
    AppStorageV2.connect<ScheduleList>(ScheduleList, () => schedules);

    //Initialize Task
    const taskPreferences = preferences.getPreferencesSync(this.context, { name: 'Task' });
    const tasks = new TaskList(schedules, coreflameGroupList!,
      ...(JSON.parse(taskPreferences.getSync('tasks', "[]") as string) as TaskESObject[]));
    AppStorageV2.connect<TaskList>(TaskList, () => tasks);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }

      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // 1. 设置窗口全屏
      let isLayoutFullScreen = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
        console.info('Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
      });
      let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 此处以导航条避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);
      AppStorageV2.connect<NumberObject>(NumberObject, 'bottomRectHeight',
        () => new NumberObject(avoidArea.bottomRect.height))!;

      type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      avoidArea = windowClass.getWindowAvoidArea(type);
      AppStorageV2.connect<NumberObject>(NumberObject, 'topRectHeight',
        () => new NumberObject(avoidArea.topRect.height))!;

      // windowClass.on('avoidAreaChange', (data) => {
      //   if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
      //     topRectHeight.value = data.area.topRect.height;
      //   } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      //     bottomRectHeight.value = data.area.bottomRect.height;
      //   }
      // });

      const ds = new DesignSystem();
      ds.register(this.context)
      ThemeControl.setDefaultTheme({
        colors: {
          brand: ds.getColor(new NumberObject(0), 'primary'),
          fontPrimary: ds.getColor(new NumberObject(0), 'surface', 900),
          backgroundPrimary: ds.getColor(new NumberObject(0), 'surface', 25),
        }
      });
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');

    const coreflamesPreferences = preferences.getPreferencesSync(this.context, { name: 'Coreflames' });
    const coreflameGroupList =
      AppStorageV2.connect<CoreflameGroupList>(CoreflameGroupList, () => new CoreflameGroupList())!;
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);
    const startOfTodayTimestamp = startOfToday.getTime();
    for (const group of coreflameGroupList) {
      for (const coreflame of group.coreflames) {
        if (coreflame.recycledTime > startOfTodayTimestamp) {
          coreflamesPreferences.putSync(coreflame.name.toString(), coreflame.recycledTime);
        }
      }
    }
    coreflamesPreferences.flushSync();

    const schedulePreferences = preferences.getPreferencesSync(this.context, { name: 'Schedule' });
    const schedules =
      AppStorageV2.connect<ScheduleList>(ScheduleList, () => new ScheduleList())!;
    schedulePreferences.putSync('schedules', JSON.stringify(schedules.toESObject()));
    schedulePreferences.flushSync();

    const taskPreferences = preferences.getPreferencesSync(this.context, { name: 'Task' });
    const tasks =
      AppStorageV2.connect<TaskList>(TaskList, () => new TaskList(schedules, coreflameGroupList))!;
    taskPreferences.putSync('tasks', JSON.stringify(tasks.toESObject()));
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
