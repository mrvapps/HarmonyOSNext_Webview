import webview from '@ohos.web.webview';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { systemShare } from '@kit.ShareKit'; // [1] Importa o ShareKit
import { uniformTypeDescriptor as utd } from '@kit.ArkData'; // [2] Importa o Uniform Type Descriptor

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
  @State loadingProgress: number = 0;
  @State isPageLoading: boolean = false;

  aboutToAppear() {
    this.enableScreenRotation();
    this.enableFullScreen(); // Enable full screen mode
  }

  // Controla o botão "voltar"
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
    } catch (err) {
      console.error('Failed to set screen rotation', err);
    }
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
    Stack({ alignContent: Alignment.BottomEnd }) {
      Web({
        src: "https://www.bing.com/", // Insert any url here
        controller: this.webController
      })
        .width('100%')
        .height('100%')
        // Add the onProgressChange event to update the progress bar
        .onProgressChange((event) => {
          if (event) {
            this.loadingProgress = event.newProgress;
            // Only show the bar if loading has started and not yet finished
            this.isPageLoading = event.newProgress > 0 && event.newProgress < 100;
            if (event.newProgress < 100) {
              this.isPageLoading = true;
            } else {
              // Hide the progress bar when loading is complete
              this.isPageLoading = false;
            }
          }
        })
      // The Progress component is placed on top of the Web component
      Progress({
        value: this.loadingProgress,
        total: 100,
        type: ProgressType.Linear // 4. Tipo linear
      })
        .width('100%')
        .height(4) // 5. Altura reduzida (em vp)
        .visibility(this.isPageLoading ? Visibility.Visible : Visibility.Hidden)
        .position({ y: 0 }) // 6. Fixar no topo

      // Botão de compartilhar usando TEXTO para evitar erros de recurso
      Button('Share') // Usando texto simples
        .type(ButtonType.Capsule) // Um tipo de botão diferente para dar estilo
        .margin(20)
        .padding({ left: 20, right: 20 })
        .onClick(async () => {
          const url = this.webController.getUrl();
          if (!url) {
            console.error('Could not get URL to share.');
            return;
          }

          try {
            // Constrói os dados a serem compartilhados
            let data = new systemShare.SharedData({
              utd: utd.UniformDataType.HYPERLINK,
              content: url
            });

            // Cria o controlador de compartilhamento
            let controller = new systemShare.ShareController(data);

            // Exibe o painel de compartilhamento
            await controller.show(this.context, {
              previewMode: systemShare.SharePreviewMode.DEFAULT
            });
          } catch (error) {
            console.error('Share failed', JSON.stringify(error));
          }
        })

    }
    .expandSafeArea([SafeAreaType.SYSTEM])
    .width('100%')
    .height('100%')
    }
}