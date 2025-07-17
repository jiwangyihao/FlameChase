import { Coreflame, CoreflameGroupList } from './Coreflame';
import { Schedule, ScheduleCategory, ScheduleList } from './Schedule';

export interface TaskESObject {
  total: number;
  finishedAt: number;
  bindScheduleId: string;
  bindCoreflameName: string;
  category: ScheduleCategory;
}

export interface TaskStats {
  total: number;
  totalTime: number;
  recycledCoreflames: Map<ScheduleCategory, number>;
}

export interface DayTaskStats {
  date: number; // Timestamp of the day
  general: TaskStats;
  byCategory: Map<ScheduleCategory, TaskStats>;
}

export class Task {
  total: number = 0;
  finishedAt: number = 0;
  bindSchedule: Schedule | null = null;
  bindCoreflame: Coreflame | null = null;
  category: ScheduleCategory = ScheduleCategory.CHAOS;

  constructor(
    total: number = 0,
    finishedAt: number = 0,
    bindSchedule: Schedule | null = null,
    bindCoreflame: Coreflame | null = null,
    category: ScheduleCategory = ScheduleCategory.CHAOS
  ) {
    this.total = total;
    this.finishedAt = finishedAt;
    this.bindSchedule = bindSchedule;
    this.bindCoreflame = bindCoreflame;
    this.category = bindSchedule ? bindSchedule.category : category;
  }

  toESObject(): TaskESObject {
    return {
      total: this.total,
      finishedAt: this.finishedAt,
      bindScheduleId: this.bindSchedule ? this.bindSchedule.id : '',
      bindCoreflameName: this.bindCoreflame ? this.bindCoreflame.name : '',
      category: this.category,
    };
  }
}

export class TaskList extends Array<Task> {
  constructor(scheduleList: ScheduleList, coreflameGroupList: CoreflameGroupList, ...tasks: TaskESObject[]) {
    super(
      ...tasks.map(task => new Task(
        task.total,
        task.finishedAt,
        scheduleList.findById(task.bindScheduleId) || null,
        coreflameGroupList.findByName(task.bindCoreflameName) || null,
        task.category || ScheduleCategory.CHAOS
      ))
    );
  }

  addTask(task: Task) {
    this.push(new Task(
      task.total,
      task.finishedAt,
      task.bindSchedule,
      task.bindCoreflame,
      task.category
    ));
  }

  toESObject(): TaskESObject[] {
    return this.map((task): TaskESObject => task.toESObject());
  }

  calculateStats(): DayTaskStats[] {
    const statsMap: Map<number, DayTaskStats> = new Map();

    for (const task of this) {
      if (task.finishedAt === 0) {
        continue;
      } // Skip unfinished tasks

      const date = new Date(task.finishedAt);
      date.setHours(0, 0, 0, 0);
      const timestamp = date.getTime();

      if (!statsMap.has(timestamp)) {
        statsMap.set(timestamp, {
          date: timestamp,
          general: { total: 0, totalTime: 0, recycledCoreflames: new Map() },
          byCategory: new Map(),
        });
      }

      const dayStats = statsMap.get(timestamp)!;
      dayStats.general.total += 1;
      dayStats.general.totalTime += task.total;

      if (!dayStats.byCategory.has(task.category)) {
        dayStats.byCategory.set(task.category, { total: 0, totalTime: 0, recycledCoreflames: new Map() });
      }
      const categoryStats = dayStats.byCategory.get(task.category)!;
      categoryStats.total += task.total;
      categoryStats.totalTime += task.total;

      if (task.bindCoreflame) {
        const recycledCount = dayStats.general.recycledCoreflames.get(task.bindCoreflame.bind) || 0;
        dayStats.general.recycledCoreflames.set(task.bindCoreflame.bind, recycledCount + task.total);
      }
    }

    return Array.from(statsMap.values());
  }
}