import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  AnimationControllerModule,
  IconDescriptorFactory,
  IconDescriptorSet,
  IconLayerOption,
  IconStudioSelection
} from '../model/IconDescriptorFactory';

@Entry
@Component
struct Index {
  @State modeIndex: number = 0;
  @State backgroundIndex: number = 0;
  @State foregroundIndex: number = 0;
  @State badgeIndex: number = 0;
  @State frameCount: number = 3;
  @State durationMs: number = 720;
  @State iterations: number = 4;
  @State autoPlay: boolean = true;
  @State descriptorReady: boolean = false;
  @State loadState: string = 'Loading descriptors';
  @State controllerState: string = 'Controller pending';
  @State revision: number = 0;

  private descriptorSet?: IconDescriptorSet;
  private readonly modes: Array<string> = ['Base', 'Layered', 'Animated'];

  aboutToAppear(): void {
    this.refreshDescriptors();
  }

  refreshDescriptors(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const selection = new IconStudioSelection(this.backgroundIndex, this.foregroundIndex, this.badgeIndex,
      this.frameCount, this.durationMs, this.iterations, this.autoPlay);

    try {
      this.descriptorSet = IconDescriptorFactory.buildDescriptorSet(context, selection);
      this.descriptorReady = true;
      this.revision += 1;
      this.loadState = `${this.foregroundOption().label} loaded ${this.descriptorSet.loadSummary}`;
      this.controllerState = this.autoPlay ? 'AnimatedDrawableDescriptor auto play' : 'Animation paused at first frame';
    } catch (error) {
      this.descriptorReady = false;
      this.loadState = this.errorMessage(error, 'Descriptor load failed');
    }
  }

  cycleBackground(): void {
    this.backgroundIndex = IconDescriptorFactory.nextIndex(this.backgroundIndex, 
    IconDescriptorFactory.backgrounds().length);
    this.refreshDescriptors();
  }

  cycleForeground(): void {
    this.foregroundIndex = IconDescriptorFactory.nextIndex(this.foregroundIndex, 
    IconDescriptorFactory.foregrounds().length);
    this.refreshDescriptors();
  }

  cycleBadge(): void {
    this.badgeIndex = IconDescriptorFactory.nextIndex(this.badgeIndex, IconDescriptorFactory.badges().length);
    this.refreshDescriptors();
  }

  cycleMode(): void {
    this.modeIndex = IconDescriptorFactory.nextIndex(this.modeIndex, this.modes.length);
    this.refreshDescriptors();
  }

  adjustFrames(): void {
    this.frameCount = this.frameCount >= 5 ? 2 : this.frameCount + 1;
    this.refreshDescriptors();
  }

  adjustDuration(): void {
    this.durationMs = this.durationMs >= 1320 ? 480 : this.durationMs + 240;
    this.refreshDescriptors();
  }

  adjustIterations(): void {
    this.iterations = this.iterations >= 6 ? 1 : this.iterations + 1;
    this.refreshDescriptors();
  }

  toggleAutoPlay(): void {
    this.autoPlay = !this.autoPlay;
    this.refreshDescriptors();
  }

  startAnimation(): void {
    const controller = this.animationController();
    if (!controller) {
      this.controllerState = 'Controller not attached yet';
      return;
    }
    controller.start();
    this.controllerState = `Animation started: ${controller.getStatus()}`;
  }

  pauseAnimation(): void {
    const controller = this.animationController();
    if (!controller) {
      this.controllerState = 'Controller not attached yet';
      return;
    }
    controller.pause();
    this.controllerState = `Animation paused: ${controller.getStatus()}`;
  }

  resumeAnimation(): void {
    const controller = this.animationController();
    if (!controller) {
      this.controllerState = 'Controller not attached yet';
      return;
    }
    controller.resume();
    this.controllerState = `Animation resumed: ${controller.getStatus()}`;
  }

  animationController(): AnimationControllerModule | undefined {
    if (!this.descriptorSet) {
      return undefined;
    }
    return this.descriptorSet.animated.getAnimationController('factoryAnimatedPreview');
  }

  backgroundOption(): IconLayerOption {
    return IconDescriptorFactory.backgrounds()[this.backgroundIndex];
  }

  foregroundOption(): IconLayerOption {
    return IconDescriptorFactory.foregrounds()[this.foregroundIndex];
  }

  badgeOption(): IconLayerOption {
    return IconDescriptorFactory.badges()[this.badgeIndex];
  }

  activeModeLabel(): string {
    return this.modes[this.modeIndex];
  }

  modeIndexFor(label: string): number {
    const found = this.modes.indexOf(label);
    return found < 0 ? 0 : found;
  }

  shortText(value: string, maxLength: number = 34): string {
    if (value.length <= maxLength) {
      return value;
    }
    return `${value.substring(0, maxLength - 1)}...`;
  }

  errorMessage(error: Object, fallback: string): string {
    const err = error as BusinessError;
    if (err && err.code) {
      return `${fallback}: ${err.code}`;
    }
    return fallback;
  }

  @Builder
  ModeChip(label: string, modePosition: number): void {
    Text(label)
      .height(22)
      .padding({ left: 8, right: 8 })
      .fontSize(8)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.modeIndex === modePosition ? '#101318' : '#E5E7EB')
      .backgroundColor(this.modeIndex === modePosition ? '#FFE66D' : '#28303A')
      .borderRadius(11)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.modeIndex = modePosition;
      })
  }

  @Builder
  LayerButton(label: string, option: IconLayerOption, action: () => void): void {
    Row({ space: 5 }) {
      Text('')
        .width(10)
        .height(10)
        .borderRadius(5)
        .backgroundColor(option.color)
      Column({ space: 1 }) {
        Text(label)
          .fontSize(7)
          .fontColor('#9EA7B3')
          .maxLines(1)
        Text(option.label)
          .fontSize(9)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F6F7FB')
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text('>')
        .fontSize(10)
        .fontColor('#FFE66D')
    }
    .height(34)
    .width('100%')
    .padding({ left: 8, right: 8 })
    .backgroundColor('#1B222C')
    .borderRadius(8)
    .onClick(action)
  }

  @Builder
  Metric(label: string, value: string, action: () => void): void {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(7)
        .fontColor('#9EA7B3')
        .maxLines(1)
      Text(value)
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .maxLines(1)
    }
    .height(34)
    .layoutWeight(1)
    .padding({ top: 4, bottom: 4 })
    .backgroundColor('#232B35')
    .borderRadius(8)
    .onClick(action)
  }

  @Builder
  PreviewDrawable(): void {
    if (this.descriptorReady && this.descriptorSet) {
      if (this.modeIndex === 0) {
        Image(this.descriptorSet.base)
          .width(62)
          .height(62)
          .objectFit(ImageFit.Contain)
      } else if (this.modeIndex === 1) {
        Image(this.descriptorSet.layered)
          .width(72)
          .height(72)
          .objectFit(ImageFit.Contain)
      } else {
        Image(this.descriptorSet.animated)
          .id('factoryAnimatedPreview')
          .width(72)
          .height(72)
          .objectFit(ImageFit.Contain)
      }

      if (this.modeIndex !== 0) {
        Image(this.descriptorSet.badge)
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .position({ x: 71, y: 66 })
      }
    } else {
      Text('!')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF6B9A')
    }
  }

  @Builder
  WatchPreview(): void {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(142)
        .height(142)
        .fill('#101318')
        .stroke('#384250')
        .strokeWidth(2)

      Column({ space: 8 }) {
        Row({ space: 10 }) {
          Text('06')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('23')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .justifyContent(FlexAlign.Center)

        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(92)
            .height(92)
            .fill(this.backgroundOption().color)
            .opacity(0.16)
          this.PreviewDrawable()
        }
        .width(96)
        .height(96)
      }
      .alignItems(HorizontalAlign.Center)

      Text(this.activeModeLabel())
        .fontSize(8)
        .fontColor('#101318')
        .fontWeight(FontWeight.Medium)
        .height(20)
        .padding({ left: 8, right: 8 })
        .backgroundColor('#8BEA7C')
        .borderRadius(10)
        .position({ x: 55, y: 120 })
    }
    .width(150)
    .height(150)
  }

  @Builder
  ControllerButton(label: string, action: () => void): void {
    Text(label)
      .height(24)
      .layoutWeight(1)
      .fontSize(8)
      .fontWeight(FontWeight.Medium)
      .fontColor('#101318')
      .backgroundColor('#45C7FF')
      .borderRadius(12)
      .textAlign(TextAlign.Center)
      .onClick(action)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 6 }) {
        Row() {
          Column({ space: 1 }) {
            Text('Icon Factory')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(1)
            Text('DrawableDescriptor studio')
              .fontSize(7)
              .fontColor('#9EA7B3')
              .maxLines(1)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text(`${this.revision}`)
            .width(24)
            .height(24)
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101318')
            .backgroundColor('#FFE66D')
            .borderRadius(12)
            .textAlign(TextAlign.Center)
        }
        .width('58%')

        Row({ space: 5 }) {
          ForEach(this.modes, (mode: string) => {
            this.ModeChip(mode, this.modeIndexFor(mode))
          }, (mode: string) => mode)
        }
        .width('66%')
        .justifyContent(FlexAlign.Center)

        this.WatchPreview()

        Row({ space: 5 }) {
          this.Metric('Frames', `${this.frameCount}`, () => {
            this.adjustFrames();
          })
          this.Metric('Speed', `${this.durationMs}`, () => {
            this.adjustDuration();
          })
          this.Metric('Loops', `${this.iterations}`, () => {
            this.adjustIterations();
          })
        }
        .width('70%')

        Scroll() {
          Column({ space: 5 }) {
            this.LayerButton('Background', this.backgroundOption(), () => {
              this.cycleBackground();
            })
            this.LayerButton('Foreground', this.foregroundOption(), () => {
              this.cycleForeground();
            })
            this.LayerButton('Badge', this.badgeOption(), () => {
              this.cycleBadge();
            })

            Row({ space: 5 }) {
              this.ControllerButton('Mode', () => {
                this.cycleMode();
              })
              this.ControllerButton(this.autoPlay ? 'Auto' : 'Manual', () => {
                this.toggleAutoPlay();
              })
            }
            .width('100%')

            if (this.modeIndex === 2) {
              Row({ space: 5 }) {
                this.ControllerButton('Start', () => {
                  this.startAnimation();
                })
                this.ControllerButton('Pause', () => {
                  this.pauseAnimation();
                })
                this.ControllerButton('Resume', () => {
                  this.resumeAnimation();
                })
              }
              .width('100%')
            }

            Column({ space: 3 }) {
              Text(this.shortText(this.loadState))
                .fontSize(8)
                .fontColor('#F6F7FB')
                .maxLines(1)
              Text(this.shortText(this.descriptorSet ? this.descriptorSet.frameSummary : 'Frames pending'))
                .fontSize(8)
                .fontColor('#8BEA7C')
                .maxLines(1)
              Text(this.shortText(this.controllerState))
                .fontSize(8)
                .fontColor('#45C7FF')
                .maxLines(1)
            }
            .width('100%')
            .padding({ left: 8, right: 8, top: 7, bottom: 7 })
            .backgroundColor('#1B222C')
            .borderRadius(8)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('74%')
      }
      .width('100%')
      .height('100%')
      .padding({ top: 22, bottom: 20 })
      .alignItems(HorizontalAlign.Center)
      .clip(true)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#101318')
  }
}