import { Coreflame, CoreflameGroupList } from './Coreflame';
import { Schedule, ScheduleList } from './Schedule';

export interface TaskESObject {
  total: number;
  finishedAt: number;
  bindScheduleId: string;
  bindCoreflameName: string;
}

export class Task {
  total: number = 0;
  finishedAt: number = 0;
  bindSchedule: Schedule | null = null;
  bindCoreflame: Coreflame | null = null;

  constructor(
    total: number = 0,
    finishedAt: number = 0,
    bindSchedule: Schedule | null = null,
    bindCoreflame: Coreflame | null = null
  ) {
    this.total = total;
    this.finishedAt = finishedAt;
    this.bindSchedule = bindSchedule;
    this.bindCoreflame = bindCoreflame;
  }

  toESObject(): ESObject {
    return {
      total: this.total,
      finishedAt: this.finishedAt,
      bindScheduleId: this.bindSchedule ? this.bindSchedule.id : '',
      bindCoreflameName: this.bindCoreflame ? this.bindCoreflame.name : '',
    };
  }
}

export class TaskList extends Array<Task> {
  constructor(scheduleList: ScheduleList, coreflameGroupList:CoreflameGroupList, ...tasks: TaskESObject[]) {
    super(
      ...tasks.map(task => new Task(
        task.total,
        task.finishedAt,
        scheduleList.findById(task.bindScheduleId) || null,
        coreflameGroupList.findByName(task.bindCoreflameName) || null
      ))
    );
  }

  addTask(task: Task) {
    this.push(new Task(
      task.total,
      task.finishedAt,
      task.bindSchedule,
      task.bindCoreflame
    ));
  }
}