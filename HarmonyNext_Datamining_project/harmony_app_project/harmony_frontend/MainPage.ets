import http from '@ohos.net.http';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

// 服务端API基础URL
const BASE_URL = 'http://192.168.1.100:8080/api';

export default struct MainPage {
  @State username: string = '';
  @State password: string = '';
  @State loginStatus: string = '';

  build() {
    Column({\space: Direction.Vertical,space: 20}) {
      Text('鸿蒙应用登录')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })

      TextInput({\ placeholder: '请输入用户名' })
        .width(300)
        .height(50)
        .borderRadius(8)
        .border({ width: 1, color: '#007AFF' })
        .margin({ top: 50 })
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

      Button('登录')
        .width(300)
        .height(50)
        .backgroundColor('#007AFF')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 30 })
        .onClick(() => {
          this.login();
        })

      Button('注册')
        .width(300)
        .height(50)
        .backgroundColor('#5AC8FA')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: 'pages/RegisterPage' });
        })

      Text(this.loginStatus)
        .fontSize(16)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  async login() {
    if (this.username === '' || this.password === '') {
      this.loginStatus = '请输入用户名和密码';
      return;
    }

    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        `${BASE_URL}/users/login`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            username: this.username,
            password: this.password
          }
        }
      );

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string);
        this.loginStatus = result.message;
        
        // 保存用户信息
        AppStorage.SetOrCreate('userInfo', result.user);
        
        // 跳转到主页面
        router.pushUrl({ url: 'pages/HomePage' });
      } else {
        let result = JSON.parse(response.result as string);
        this.loginStatus = result.error;
      }
    } catch (error) {
      let err = error as BusinessError;
      this.loginStatus = `登录失败: ${err.message}`;
    }
  }
}