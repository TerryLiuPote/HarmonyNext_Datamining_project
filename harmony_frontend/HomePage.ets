import http from '@ohos.net.http';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

// 服务端API基础URL
const BASE_URL = 'http://192.168.1.100:8080/api';

export default struct HomePage {
  @State userInfo: any = AppStorage.Get('userInfo') || {};
  @State recommendations: any[] = [];
  @State loading: boolean = true;

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(`欢迎, ${this.userInfo.username || '用户'}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 20 })
        
        Blank()
        
        Button('退出登录')
          .width(100)
          .height(40)
          .backgroundColor('#FF3B30')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ right: 20 })
          .onClick(() => {
            this.logout();
          })
      }
      .width('100%')
      .height(60)
      .backgroundColor('#007AFF')
      .alignItems(VerticalAlign.Center)

      // 功能导航
      Row({\space: Direction.Horizontal,space: 20}) {
        Button('数据录入')
          .width(150)
          .height(80)
          .backgroundColor('#5AC8FA')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DataEntryPage' });
          })
        
        Button('我的数据')
          .width(150)
          .height(80)
          .backgroundColor('#5AC8FA')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/MyDataPage' });
          })
      }
      .width('100%')
      .padding(20)
      .justifyContent(FlexAlign.Center)

      // 推荐内容
      Column() {
        Text('为您推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        if (this.loading) {
          Text('加载中...')
            .fontSize(16)
            .color('#999999')
        } else if (this.recommendations.length === 0) {
          Text('暂无推荐内容')
            .fontSize(16)
            .color('#999999')
        } else {
          List() {
            ForEach(this.recommendations, (item) => {
              ListItem() {
                Column() {
                  Text(item.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 10 })
                  
                  Text(item.description || '暂无描述')
                    .fontSize(14)
                    .color('#666666')
                    .margin({ bottom: 10 })
                  
                  Text(`类别: ${item.category || '未分类'}`)
                    .fontSize(14)
                    .color('#666666')
                    .margin({ bottom: 10 })
                  
                  Text(`价格: ${item.price ? `¥${item.price.toFixed(2)}` : '免费'}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .color('#FF3B30')
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
          .padding({ left: 20, right: 20 })
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .flexGrow(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onPageShow(() => {
      this.loadRecommendations();
    })
  }

  async loadRecommendations() {
    if (!this.userInfo.id) {
      return;
    }

    this.loading = true;
    
    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        `${BASE_URL}/recommendations/${this.userInfo.id}`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string);
        this.recommendations = result.recommendations;
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`加载推荐失败: ${err.message}`);
    } finally {
      this.loading = false;
    }
  }

  logout() {
    // 清除用户信息
    AppStorage.Delete('userInfo');
    
    // 跳转到登录页面
    router.replaceUrl({ url: 'pages/MainPage' });
  }
}