import http from '@ohos.net.http';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

// 服务端API基础URL
const BASE_URL = 'http://192.168.1.100:8080/api';

export default struct MyDataPage {
  @State userInfo: any = AppStorage.Get('userInfo') || {};
  @State dataEntries: any[] = [];
  @State loading: boolean = true;
  @State errorMessage: string = '';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button('返回')
          .width(80)
          .height(40)
          .backgroundColor('#FFFFFF')
          .fontColor('#007AFF')
          .borderRadius(8)
          .margin({ left: 20 })
          .onClick(() => {
            router.back();
          })
        
        Text('我的数据')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 20 })
        
        Blank()
      }
      .width('100%')
      .height(60)
      .backgroundColor('#007AFF')
      .alignItems(VerticalAlign.Center)

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#007AFF')
          
          Text('加载数据中...')
            .fontSize(16)
            .margin({ top: 10 })
        }
        .width('100%')
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage) {
        Column() {
          Text(this.errorMessage)
            .fontSize(16)
            .color('#FF3B30')
            .margin({ bottom: 20 })
          
          Button('重试')
            .width(120)
            .height(40)
            .backgroundColor('#007AFF')
            .fontColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => {
              this.loadDataEntries();
            })
        }
        .width('100%')
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.dataEntries.length === 0) {
        Column() {
          Text('暂无数据记录')
            .fontSize(16)
            .color('#999999')
            .margin({ bottom: 20 })
          
          Button('去录入')
            .width(120)
            .height(40)
            .backgroundColor('#007AFF')
            .fontColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({ url: 'pages/DataEntryPage' });
            })
        }
        .width('100%')
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.dataEntries, (item) => {
            ListItem() {
              Column() {
                Row() {
                  Text(`类型: ${item.data_type}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .color('#007AFF')
                  
                  Blank()
                  
                  Text(this.formatDate(item.created_at))
                    .fontSize(12)
                    .color('#999999')
                }
                .width('100%')
                .margin({ bottom: 10 })
                
                Text(this.formatContent(item.data_content, item.data_type))
                  .fontSize(14)
                  .color('#333333')
                  .textAlign(TextAlign.Start)
                  .maxLines(3)
                  .overflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding(20)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({
                color: '#00000020',
                radius: 8,
                offsetX: 0,
                offsetY: 4
              })
            }
            .margin({ bottom: 20 })
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onPageShow(() => {
      this.loadDataEntries();
    })
  }

  async loadDataEntries() {
    if (!this.userInfo.id) {
      this.errorMessage = '用户未登录';
      this.loading = false;
      setTimeout(() => {
        router.replaceUrl({ url: 'pages/MainPage' });
      }, 1500);
      return;
    }

    this.loading = true;
    this.errorMessage = '';
    
    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        `${BASE_URL}/data/entries/${this.userInfo.id}`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string);
        this.dataEntries = result.entries;
      }
    } catch (error) {
      let err = error as BusinessError;
      this.errorMessage = `加载失败: ${err.message}`;
    } finally {
      this.loading = false;
    }
  }

  formatDate(dateString: string): string {
    if (!dateString) return '';
    
    let date = new Date(dateString);
    return `${date.getFullYear()}-${this.padZero(date.getMonth() + 1)}-${this.padZero(date.getDate())} ${this.padZero(date.getHours())}:${this.padZero(date.getMinutes())}`;
  }

  padZero(num: number): string {
    return num < 10 ? `0${num}` : `${num}`;
  }

  formatContent(content: any, type: string): string {
    if (!content) return '';
    
    if (type === 'json') {
      return JSON.stringify(content, null, 2);
    } else if (typeof content === 'object') {
      return JSON.stringify(content);
    } else {
      return String(content);
    }
  }
}