/**
 * 该文件导出一个名为 createCubicBezier 的函数，
 * 它用于生成一个符合 CSS cubic-bezier() 规范的缓动函数。
 *
 * @example
 * import { createCubicBezier } from './CubicBezier';
 *
 * // 创建一个缓动函数，等同于 CSS 的 cubic-bezier(0.25, 0.1, 0.25, 1.0)
 * const ease = createCubicBezier(0.25, 0.1, 0.25, 1.0);
 *
 * // 计算时间进程为 0.5 时的动画值
 * const valueAtHalfTime = ease(0.5);
 * console.log(`动画进程在 50% 时，值为: ${valueAtHalfTime}`);
 *
 */

const NEWTON_ITERATIONS: number = 4;
const NEWTON_MIN_SLOPE: number = 0.001;
const SUBDIVISION_PRECISION: number = 0.0000001;
const SUBDIVISION_MAX_ITERATIONS: number = 10;

const kSplineTableSize: number = 11;
const kSampleStepSize: number = 1.0 / (kSplineTableSize - 1.0);

function A(aA1: number, aA2: number): number {
  return 1.0 - 3.0 * aA2 + 3.0 * aA1;
}

function B(aA1: number, aA2: number): number {
  return 3.0 * aA2 - 6.0 * aA1;
}

function C(aA1: number): number {
  return 3.0 * aA1;
}

function calcBezier(aT: number, aA1: number, aA2: number): number {
  return ((A(aA1, aA2) * aT + B(aA1, aA2)) * aT + C(aA1)) * aT;
}

function getSlope(aT: number, aA1: number, aA2: number): number {
  return 3.0 * A(aA1, aA2) * aT * aT + 2.0 * B(aA1, aA2) * aT + C(aA1);
}

function binarySubdivide(aX: number, aA: number, aB: number, mX1: number, mX2: number): number {
  let currentX: number, currentT: number;
  let i: number = 0;
  do {
    currentT = aA + (aB - aA) / 2.0;
    currentX = calcBezier(currentT, mX1, mX2) - aX;
    if (currentX > 0.0) {
      aB = currentT;
    } else {
      aA = currentT;
    }
  } while (Math.abs(currentX) > SUBDIVISION_PRECISION && ++i < SUBDIVISION_MAX_ITERATIONS);
  return currentT;
}

function newtonRaphsonIterate(aX: number, aGuessT: number, mX1: number, mX2: number): number {
  for (let i = 0; i < NEWTON_ITERATIONS; ++i) {
    const currentSlope = getSlope(aGuessT, mX1, mX2);
    if (currentSlope === 0.0) {
      return aGuessT;
    }
    const currentX = calcBezier(aGuessT, mX1, mX2) - aX;
    aGuessT -= currentX / currentSlope;
  }
  return aGuessT;
}

/**
 * 创建一个贝塞尔曲线缓动函数
 *
 * @param p1x 控制点 P1 的 x 坐标
 * @param p1y 控制点 P1 的 y 坐标
 * @param p2x 控制点 P2 的 x 坐标
 * @param p2y 控制点 P2 的 y 坐标
 * @returns 一个函数，接收一个 number (0-1)，返回计算后的 number (0-1)
 */
export function createCubicBezier(p1x: number, p1y: number, p2x: number, p2y: number): (x: number) => number {
  // 如果是线性曲线，直接返回 x，进行优化
  if (p1x === p1y && p2x === p2y) {
    return (x: number): number => x;
  }

  // 预计算样本值，用于快速估算 t
  const sampleValues = new Float32Array(kSplineTableSize);
  for (let i = 0; i < kSplineTableSize; ++i) {
    sampleValues[i] = calcBezier(i * kSampleStepSize, p1x, p2x);
  }

  let getTForX: (aX: number) => number = (aX: number): number => {
    let intervalStart = 0.0;
    let currentSample = 1;
    const lastSample = kSplineTableSize - 1;
    for (; currentSample !== lastSample && sampleValues[currentSample] <= aX; ++currentSample) {
      intervalStart += kSampleStepSize;
    }
    --currentSample;
    // 差值计算，得到 t 的一个较好的初始猜测值
    const dist = (aX - sampleValues[currentSample]) / (sampleValues[currentSample + 1] - sampleValues[currentSample]);
    const guessForT = intervalStart + dist * kSampleStepSize;
    const initialSlope = getSlope(guessForT, p1x, p2x);
    if (initialSlope >= NEWTON_MIN_SLOPE) {
      return newtonRaphsonIterate(aX, guessForT, p1x, p2x);
    } else if (initialSlope === 0.0) {
      return guessForT;
    } else {
      // 如果斜率过小，牛顿法不稳定，改用二分法
      return binarySubdivide(aX, intervalStart, intervalStart + kSampleStepSize, p1x, p2x);
    }
  };

  // 返回最终的 number => number 函数
  return (x: number): number => {
    if (x === 0.0) {
      return 0.0;
    }
    if (x === 1.0) {
      return 1.0;
    }
    // 首先找到对应的参数 t，然后用 t 计算 y
    return calcBezier(getTForX(x), p1y, p2y);
  };
}
