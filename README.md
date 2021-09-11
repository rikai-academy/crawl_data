## crawl_data
#### Cài đặt chrome
#### Cài đặt chrome driver
    - Link: https://chromedriver.chromium.org/downloads
    - Tìm version phù hợp với version chrome đang sử dụng.
        - Cách xem version chrome: https://vtv.vn/tu-van/cach-xac-dinh-phien-ban-google-chrome-dang-dung-20150202151605259.htm
    - Nó là 1 file zip. Extract file zip ra cho vào ổ C:\Program Files.
    - Lấy đường dẫn với cái folder của nó cho vào PATH của window. https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/

#### Cài đặt ruby
    - Download `rubyinstaller-devkit-2.7.2-1-x64.exe` bằng cách click vào [link này](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.2-1/rubyinstaller-devkit-2.7.2-1-x64.exe)
    - Thực hiện cài như bình thường.

#### Download hoặc clone source code
    - Download source code hoặc clone source code từ link này.
    - Extract ra thành 1 folder. Gọi là folder `craw`.

#### Chạy
    - Bật commandos
    - cd vào trong folder `craw`. (Các huynh đài, tỉ muội nào chưa chạy lệnh trên commandos bao giờ thì vui lòng liên hệ với các huynh đệ bên cạnh để được hướng dẫn)
    - Chạy các lệnh sau:

    ```
    gem install bundler -v 1.15.1
    bundle install
    ```

    - Chạy lệnh `ruby main.rb`. Đợi tầm vài giây, nếu mà nó tự động bật ra 1 cái chrome mới và access vào trang https://www.telework-rule.metro.tokyo.lg.jp/search/index.php là được.