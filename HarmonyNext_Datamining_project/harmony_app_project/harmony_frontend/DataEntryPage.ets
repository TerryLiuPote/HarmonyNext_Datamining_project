import http from '@ohos.net.http';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

// 服务端API基础URL
const BASE_URL = 'http://192.168.1.100:8080/api';

export default struct DataEntryPage {
  @State userInfo: any = AppStorage.Get('userInfo') || {};
  @State dataType: string = '';
  @State dataContent: string = '';
  @State entryStatus: string = '';

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
        
        Text('数据录入')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 20 })
        
        Blank()
      }
      .width('100%')
      .height(60)
      .backgroundColor('#007AFF')
      .alignItems(VerticalAlign.Center)

      Column({\space: Direction.Vertical,space: 20}) {
        // 数据类型选择
        Column() {
          Text('数据类型:')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })
          
          Row({\space: Direction.Horizontal,space: 10}) {
            Radio({ value: 'text', group: 'dataType' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.dataType = 'text';
                }
              })
            Text('文本')
              .fontSize(16)
              
            Radio({ value: 'number', group: 'dataType' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.dataType = 'number';
                }
              })
            Text('数字')
              .fontSize(16)
              
            Radio({ value: 'json', group: 'dataType' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.dataType = 'json';
                }
              })
            Text('JSON')
              .fontSize(16)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 数据内容输入
        Column() {
          Text('数据内容:')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })
          
          TextArea({
            placeholder: '请输入数据内容',
            text: this.dataContent
          })
            .width('100%')
            .height(200)
            .borderRadius(8)
            .border({ width: 1, color: '#007AFF' })
            .padding(15)
            .onChange((value: string) => {
              this.dataContent = value;
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 提交按钮
        Button('提交数据')
          .width('90%')
          .height(50)
          .backgroundColor('#007AFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            this.submitData();
          })

        // 状态提示
        Text(this.entryStatus)
          .fontSize(16)
          .margin({ bottom: 20 })
      }
      .width('100%')
      .padding({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  async submitData() {
    if (!this.dataType) {
      this.entryStatus = '请选择数据类型';
      return;
    }

    if (!this.dataContent) {
      this.entryStatus = '请输入数据内容';
      return;
    }

    if (!this.userInfo.id) {
      this.entryStatus = '用户未登录';
      setTimeout(() => {
        router.replaceUrl({ url: 'pages/MainPage' });
      }, 1500);
      return;
    }

    try {
      // 解析数据内容
      let parsedContent;
      if (this.dataType === 'json') {
        parsedContent = JSON.parse(this.dataContent);
      } else if (this.dataType === 'number') {
        parsedContent = parseFloat(this.dataContent);
      } else {
        parsedContent = this.dataContent;
      }

      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        `${BASE_URL}/data/entry`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            user_id: this.userInfo.id,
            data_type: this.dataType,
            data_content: parsedContent
          }
        }
      );

      if (response.responseCode === 201) {
        let result = JSON.parse(response.result as string);
        this.entryStatus = result.message;
        
        // 清空表单
        this.dataType = '';
        this.dataContent = '';
      } else {
        let result = JSON.parse(response.result as string);
        this.entryStatus = result.error;
      }
    } catch (error) {
      let err = error as BusinessError;
      this.entryStatus = `提交失败: ${err.message}`;
    }
  }
}