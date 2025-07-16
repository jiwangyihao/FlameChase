import { resourceManager } from '@kit.LocalizationKit';

/**
 * Design system utility for managing colors and their variations.
 */
interface ColorRGB {
  r: number;
  g: number;
  b: number;
  a: number
}

interface ColorHSL {
  h: number; // Hue: 0-1
  s: number; // Saturation: 0-1
  l: number; // Lightness: 0-1
  a: number
}

export class DesignSystem {
  private context: Context | undefined;

  /**
   * Converts an RGB color object to HSL.
   * Conversion formula adapted from http://en.wikipedia.org/wiki/HSL_color_space.
   * @param color The RGB color object {r, g, b} with values from 0-255.
   * @returns The HSL representation {h, s, l} with values from 0-1.
   */
  private static rgbToHsl(color: ColorRGB): ColorHSL {
    let r = color.r;
    let g = color.g;
    let b = color.b;
    r /= 255;
    g /= 255;
    b /= 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h = 0, s = 0, l = (max + min) / 2;

    if (max === min) {
      // achromatic (grayscale)
      h = s = 0;
    } else {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        case b:
          h = (r - g) / d + 4;
          break;
      }
      h /= 6;
    }

    return {
      h,
      s,
      l,
      a: color.a
    }; // Include alpha channel
  }

  /**
   * Converts an HSL color value to RGB.
   * Conversion formula adapted from http://en.wikipedia.org/wiki/HSL_color_space.
   * @param color The HSL color object {h, s, l} with values from 0-1.
   * @returns The RGB representation {r, g, b} with values from 0-255.
   */
  private static hslToRgb(color: ColorHSL): ColorRGB {
    let h = color.h;
    let s = color.s;
    let l = color.l;
    let r: number, g: number, b: number;

    if (s === 0) {
      r = g = b = l; // achromatic
    } else {
      const hue2rgb = (p: number, q: number, t: number): number => {
        if (t < 0) {
          t += 1;
        }
        if (t > 1) {
          t -= 1;
        }
        if (t < 1 / 6) {
          return p + (q - p) * 6 * t;
        }
        if (t < 1 / 2) {
          return q;
        }
        if (t < 2 / 3) {
          return p + (q - p) * (2 / 3 - t) * 6;
        }
        return p;
      };

      const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      const p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return {
      r: Math.round(r * 255),
      g: Math.round(g * 255),
      b: Math.round(b * 255),
      a: color.a // Include alpha channel
    };
  }

  /**
   * Converts a color resource to an RGB object.
   * Note: This is a simplified implementation for demonstration.
   */
  private static resourceToRgb(resource: number): ColorRGB | null {
    // In a real application, you would need a more robust way to get the hex value.
    const hex = resource.toString(16);

    if (hex.length !== 8) {
      console.error("Failed to parse color resource string:", resource);
      return null;
    }

    return {
      r: parseInt(hex.substring(2, 4), 16),
      g: parseInt(hex.substring(4, 6), 16),
      b: parseInt(hex.substring(6, 8), 16),
      a: parseInt(hex.substring(0, 2), 16)
    };
  }

  /**
   * Converts an RGB color object to a color resource.
   */
  private static rgbToHex(color: ColorRGB): string {
    const toHex = (n: number): string => {
      // Clamp the value between 0 and 255
      const clamped = Math.max(0, Math.min(255, n));
      const hex = clamped.toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    };

    const hexColor = `#${toHex(color.a)}${toHex(color.r)}${toHex(color.g)}${toHex(color.b)}`;
    // This assumes a resource naming convention like 'app.color.ff0000' for red.
    // You might need to adjust this based on your project's resource structure.
    return hexColor;
  }

  register(context: Context | undefined): void {
    this.context = context;
  }

  /**
   * Get color from resources with light variation based on HSL color model.
   * @param resourceStr Color resource from app, e.g., 'app.color.my_color'.
   * @param variation Lightness value (0-1000), where 0 is white and 1000 is black.
   * @returns Color with applied light variation.
   */
  getColor(_darkHint: number, resourceStr: string, variation: number = 600, alpha: number = 1): string | Resource {
    if (this.context === undefined) {
      throw new Error('DesignSystem context is not registered. Call register() first.');
    }

    if (variation < 0 || variation > 1000) {
      throw new Error('Light value must be between 0 and 1000');
    }

    if (this.context.resourceManager.getConfigurationSync().colorMode ===
    resourceManager.ColorMode.DARK) {
      // If the color mode is dark, we invert the lightness variation
      variation = 1000 - variation;
    }

    // Convert resource color to RGB
    const baseColorRgb = DesignSystem.resourceToRgb(this.context.resourceManager.getColorByNameSync(resourceStr));
    if (!baseColorRgb) {
      // Return original resource if conversion fails
      return $r(resourceStr);
    }

    // Convert the base RGB color to HSL
    const baseColorHsl = DesignSystem.rgbToHsl(baseColorRgb);

    // Create a new HSL color.
    // We keep the original hue and saturation, but replace the lightness.
    // The 'light' parameter (0-1000) is mapped to the HSL 'l' property (1-0).
    const newLightness = (1000 - variation) / 1000;
    const newColorHsl: ColorHSL = {
      h: baseColorHsl.h,
      s: baseColorHsl.s,
      l: newLightness,
      a: Math.floor(baseColorHsl.a * alpha)
    };

    // Convert the new HSL color back to RGB
    const adjustedRgb = DesignSystem.hslToRgb(newColorHsl);

    // Convert the final RGB color back to a resource format
    return DesignSystem.rgbToHex(adjustedRgb);
  }

  getSize(size: number): number {
    return 16 * size
  }
}
