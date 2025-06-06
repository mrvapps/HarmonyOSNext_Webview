import webview from '@ohos.web.webview';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';

interface GeneratedObjectLiteralInterface_1 {
  statusBarColor: string;
  navigationBarColor: string;
  statusBarContentColor: string;
  navigationBarContentColor: string;
}

@Entry
@Component
struct Index {
  private webController: webview.WebviewController = new webview.WebviewController();
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.enableScreenRotation();
    this.enableFullScreen(); // Enable full screen mode
  }

  // Add this method to control the back button
  onBackPress() {
    if (this.webController.accessBackward()) {
      this.webController.backward(); // Go back to the previous page in WebView
      return true; // Indicates that the event has been handled
    }
    return false; // Enable default behavior (exit the app)
  }

  // Enable screen rotation - check module.json5
  private async enableScreenRotation() {
    try {
      const win = await window.getLastWindow(this.context);
      win.setPreferredOrientation(window.Orientation.AUTO_ROTATION);
    } catch (err) {}
  }

  // Full screen mode to fill the top bar...
  private async enableFullScreen() {
    try {
      const win = await window.getLastWindow(this.context);
      // Set full screen layout
      win.setWindowLayoutFullScreen(true);

      // Set system bars to transparent
      const systemBarProps: GeneratedObjectLiteralInterface_1 = {
        statusBarColor: '#00000000', // Transparent color
        navigationBarColor: '#00000000', // Transparent color
        statusBarContentColor: '#FF000000', // Dark content color
        navigationBarContentColor: '#FF000000'
      };
      win.setWindowSystemBarProperties(systemBarProps);
    } catch (err) {}
  }

  build() {
    Column() {
      Web({
        src: "https://www.qwant.com/", // Insert any url here
        controller: this.webController
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}