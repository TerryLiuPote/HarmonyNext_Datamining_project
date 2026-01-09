import http from '@ohos.net.http';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

// 服务端API基础URL
const BASE_URL = 'http://192.168.1.100:8080/api';

export default struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State email: string = '';
  @State registerStatus: string = '';

  build() {
    Column({\space: Direction.Vertical,space: 20}) {
      Text('用户注册')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50 })

      TextInput({\ placeholder: '请输入用户名' })
        .width(300)
        .height(50)
        .borderRadius(8)
        .border({ width: 1, color: '#007AFF' })
        .margin({ top: 20 })
        .onChange((value: string) => {
          this.username = value;
        })

      TextInput({\ placeholder: '请输入密码', type: InputType.Password })
        .width(300)
        .height(50)
        .borderRadius(8)
        .border({ width: 1, color: '#007AFF' })
        .onChange((value: string) => {
          this.password = value;
        })

      TextInput({\ placeholder: '请输入邮箱' })
        .width(300)
        .height(50)
        .borderRadius(8)
        .border({ width: 1, color: '#007AFF' })
        .onChange((value: string) => {
          this.email = value;
        })

      Button('注册')
        .width(300)
        .height(50)
        .backgroundColor('#007AFF')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 30 })
        .onClick(() => {
          this.register();
        })

      Button('返回登录')
        .width(300)
        .height(50)
        .backgroundColor('#5AC8FA')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .onClick(() => {
          router.back();
        })

      Text(this.registerStatus)
        .fontSize(16)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  async register() {
    if (this.username === '' || this.password === '' || this.email === '') {
      this.registerStatus = '请输入用户名、密码和邮箱';
      return;
    }

    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        `${BASE_URL}/users/register`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            username: this.username,
            password: this.password,
            email: this.email
          }
        }
      );

      if (response.responseCode === 201) {
        let result = JSON.parse(response.result as string);
        this.registerStatus = result.message;
        
        // 注册成功后跳转到登录页面
        setTimeout(() => {
          router.back();
        }, 1500);
      } else {
        let result = JSON.parse(response.result as string);
        this.registerStatus = result.error;
      }
    } catch (error) {
      let err = error as BusinessError;
      this.registerStatus = `注册失败: ${err.message}`;
    }
  }
}