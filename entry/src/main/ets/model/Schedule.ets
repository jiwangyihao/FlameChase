import { util } from '@kit.ArkTS';

export enum ScheduleCategory {
  CHAOS = 'Chaos',
  STUDY = 'Study',
  WORK = 'Work',
  EXERCISE = 'Exercise',
  PONDER = 'Ponder',
}

@ObservedV2
export class Schedule {
  id: string = '';
  @Trace title: string = '';
  @Trace description: string = '';
  @Trace createdAt: number = 0;
  @Trace total: number = 0;
  @Trace progress: number = 0;
  @Trace category: ScheduleCategory = ScheduleCategory.CHAOS;

  constructor(
    title: string,
    description: string,
    createdAt: number,
    total: number,
    category: ScheduleCategory,
    progress: number = 0,
    id: string = util.generateRandomUUID(false)
  ) {
    this.title = title;
    this.description = description;
    this.createdAt = createdAt;
    this.total = total;
    this.category = category;
    this.progress = progress;
    this.id = id;
  }

  toESObject(): ESObject {
    return {
      title: this.title,
      description: this.description,
      createdAt: this.createdAt,
      total: this.total,
      category: this.category,
      progress: this.progress,
      id: this.id,
    };
  }
}

export class ScheduleList extends Array<Schedule> {
  constructor(...schedules: Schedule[]) {
    super(
      ...schedules
        .map(schedule => new Schedule(
          schedule.title,
          schedule.description,
          schedule.createdAt,
          schedule.total,
          schedule.category,
          schedule.progress,
          schedule.id
        ))
    );
  }

  ongoingSchedules(): Schedule[] {
    return this.filter(schedule => schedule.progress < schedule.total);
  }

  completedSchedules(): Schedule[] {
    return this.filter(schedule => schedule.progress >= schedule.total && schedule.total > 0);
  }

  addSchedule(schedule: Schedule) {
    this.push(schedule);
  }

  removeSchedule(schedule: Schedule) {
    const index = this.indexOf(schedule);
    if (index > -1) {
      this.splice(index, 1);
    }
  }

  findByTitle(title: string): Schedule | undefined {
    return this.find(schedule => schedule.title === title);
  }

  findById(id: string): Schedule | undefined {
    return this.find(schedule => schedule.id === id);
  }

  toESObject(): ESObject[] {
    return this.map((schedule: Schedule): ESObject => {
      return schedule.toESObject();
    });
  }
}


export const scheduleCategoryIcons: Map<string, Resource> = new Map<string, Resource>([
  [ScheduleCategory.CHAOS, $r('app.media.codicon__sparkle')],
  [ScheduleCategory.STUDY, $r('app.media.ant_design__read_outlined')],
  [ScheduleCategory.WORK, $r('app.media.mdi__work_outline')],
  [ScheduleCategory.EXERCISE, $r('app.media.material_symbols__directions_run_rounded')],
  [ScheduleCategory.PONDER, $r('app.media.mdi__think_outline')]
]);