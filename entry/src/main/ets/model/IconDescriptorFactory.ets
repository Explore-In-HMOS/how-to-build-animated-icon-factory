import { common } from '@kit.AbilityKit';
import image from '@ohos.multimedia.image';
import {
  AnimatedDrawableDescriptor,
  AnimationController,
  AnimationOptions,
  DrawableDescriptor,
  LayeredDrawableDescriptor
} from '@ohos.arkui.drawableDescriptor';

export type DrawableDescriptorModule = DrawableDescriptor;
export type AnimatedDrawableDescriptorModule = AnimatedDrawableDescriptor;
export type LayeredDrawableDescriptorModule = LayeredDrawableDescriptor;
export type AnimationControllerModule = AnimationController;
export type AnimationOptionsModule = AnimationOptions;

export class IconLayerOption {
  id: string;
  label: string;
  resourceName: string;
  color: string;

  constructor(id: string, label: string, resourceName: string, color: string) {
    this.id = id;
    this.label = label;
    this.resourceName = resourceName;
    this.color = color;
  }
}

export class IconStudioSelection {
  backgroundIndex: number;
  foregroundIndex: number;
  badgeIndex: number;
  frameCount: number;
  durationMs: number;
  iterations: number;
  autoPlay: boolean;

  constructor(backgroundIndex: number, foregroundIndex: number, badgeIndex: number, frameCount: number,
    durationMs: number, iterations: number, autoPlay: boolean) {
    this.backgroundIndex = backgroundIndex;
    this.foregroundIndex = foregroundIndex;
    this.badgeIndex = badgeIndex;
    this.frameCount = frameCount;
    this.durationMs = durationMs;
    this.iterations = iterations;
    this.autoPlay = autoPlay;
  }
}

export class IconDescriptorSet {
  base: DrawableDescriptorModule;
  foreground: DrawableDescriptorModule;
  background: DrawableDescriptorModule;
  badge: DrawableDescriptorModule;
  layered: LayeredDrawableDescriptorModule;
  animated: AnimatedDrawableDescriptorModule;
  maskPath: string;
  loadSummary: string;
  frameSummary: string;

  constructor(base:DrawableDescriptorModule,foreground:DrawableDescriptorModule,background:DrawableDescriptorModule,
    badge: DrawableDescriptorModule, layered: LayeredDrawableDescriptorModule,
    animated: AnimatedDrawableDescriptorModule, maskPath: string, loadSummary: string, frameSummary: string) {
    this.base = base;
    this.foreground = foreground;
    this.background = background;
    this.badge = badge;
    this.layered = layered;
    this.animated = animated;
    this.maskPath = maskPath;
    this.loadSummary = loadSummary;
    this.frameSummary = frameSummary;
  }
}

export class IconDescriptorFactory {
  static backgrounds(): Array<IconLayerOption> {
    return [
      new IconLayerOption('aurora', 'Aurora', 'icon_background_aurora', '#20D6A8'),
      new IconLayerOption('solar', 'Solar', 'icon_background_solar', '#F4C542'),
      new IconLayerOption('pulse', 'Pulse', 'icon_background_pulse', '#7C5CFF')
    ];
  }

  static foregrounds(): Array<IconLayerOption> {
    return [
      new IconLayerOption('bolt', 'Bolt', 'icon_foreground_bolt', '#F95D6A'),
      new IconLayerOption('orbit', 'Orbit', 'icon_foreground_orbit', '#45C7FF'),
      new IconLayerOption('route', 'Route', 'icon_foreground_route', '#F8FAFC')
    ];
  }

  static badges(): Array<IconLayerOption> {
    return [
      new IconLayerOption('star', 'Star', 'icon_badge_star', '#FFE66D'),
      new IconLayerOption('heart', 'Heart', 'icon_badge_heart', '#FF6B9A'),
      new IconLayerOption('check', 'Check', 'icon_badge_check', '#8BEA7C')
    ];
  }

  static buildDescriptorSet(context: common.UIAbilityContext, selection: IconStudioSelection): IconDescriptorSet {
    const manager = context.resourceManager;
    const backgroundOption = IconDescriptorFactory.backgrounds()[selection.backgroundIndex];
    const foregroundOption = IconDescriptorFactory.foregrounds()[selection.foregroundIndex];
    const badgeOption = IconDescriptorFactory.badges()[selection.badgeIndex];

    let foreground: DrawableDescriptorModule;
    let background: DrawableDescriptorModule;
    let badge: DrawableDescriptorModule;
    let mask: DrawableDescriptorModule;
    try {
      foreground = manager.getDrawableDescriptorByName(foregroundOption.resourceName);
      background = manager.getDrawableDescriptorByName(backgroundOption.resourceName);
      badge = manager.getDrawableDescriptorByName(badgeOption.resourceName);
      mask = manager.getDrawableDescriptorByName('icon_mask_watch');
    } catch (error) {
      throw new Error(`DrawableDescriptor resource load failed: ${foregroundOption.resourceName}`);
    }
    const layered = new LayeredDrawableDescriptor(foreground, background, mask);
    const animated = IconDescriptorFactory.createAnimatedDescriptor(selection, foreground, background, badge);
    const loaded = IconDescriptorFactory.describeLoad(foreground);
    const frameSummary = `${selection.frameCount} frames / ${selection.durationMs} ms / ${selection.iterations}x`;

    return new IconDescriptorSet(foreground, foreground, background, badge, layered, animated,
      LayeredDrawableDescriptor.getMaskClipPath(), loaded, frameSummary);
  }

  static createAnimatedDescriptor(selection: IconStudioSelection, foreground: DrawableDescriptorModule,
    background: DrawableDescriptorModule, badge: DrawableDescriptorModule): AnimatedDrawableDescriptorModule {
    const sourceFrames: Array<DrawableDescriptorModule> = [foreground, background, badge, foreground];
    const pixelMaps: Array<image.PixelMap> = [];
    for (let index = 0; index < selection.frameCount; index++) {
      pixelMaps.push(sourceFrames[index % sourceFrames.length].getPixelMap());
    }

    const perFrame = Math.max(80, Math.floor(selection.durationMs / Math.max(1, selection.frameCount)));
    const frameDurations: Array<number> = [];
    for (let index = 0; index < selection.frameCount; index++) {
      frameDurations.push(perFrame);
    }

    const options: AnimationOptionsModule = {
      duration: selection.durationMs,
      iterations: selection.iterations,
      frameDurations: frameDurations,
      autoPlay: selection.autoPlay
    };
    return new AnimatedDrawableDescriptor(pixelMaps, options);
  }

  static describeLoad(descriptor: DrawableDescriptorModule): string {
    try {
      const loaded = descriptor.loadSync();
      return `${loaded.imageWidth}x${loaded.imageHeight}px`;
    } catch (error) {
      return 'loadSync unavailable';
    }
  }

  static nextIndex(current: number, length: number): number {
    if (length <= 0) {
      return 0;
    }
    return (current + 1) % length;
  }
}