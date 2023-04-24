# CODE DEMO DỰ ÁN CI/CD

# Mục đích
- Dự án nhằm mục đích tự động hoá hoàn toàn CI/CD. Cụ thể: khi người dùng commit code lên https://github.com/quangdaicaa/basevn_html, thì code này sẽ tự động trình bày lên server https://quang.pro:777
- Qua Dự án này, tác giả chứng minh được năng lực chuyên môn DevOps Engineer

# Điểm nổi bật
- Jenkins là trái tim cuả CI. Nhưng ở đây tôi không dùng Jenkins, mà tự mình lập trình thay thế nó. Thay thế được Jenkins chứng tỏ mức độ hiểu rất sâu về CI. Sử dụng FastAPI là thư viện cuả Python để viết API đón lâý webhook; đây là kiến thức cuả Backend Engineer, cho thấy tôi có vốn kỹ năng đa dạng và khả năng lập trình giải quyết vấn đề.
- Kubernetes là khối óc cuả CD. Nhưng vì do giới hạn về phần cứng (1 vCore/mỗi maý ảo) nên tôi không trình bày kỹ thuật Kubernetes trong dự án này. Ở đây tôi dùng Docker đóng gói code vào container Alpine, đưa lên Docker Hub, rôì kéo về mang đi triển khai.
- Giao diện thuần tuý CLI, thuần tuý Linux Bash script, tự động hoá hoàn toàn mọi tác vụ, trình độ tương đương LPI-level 2. Dự án này chỉ dùng 2 máy aỏ, nhưng nếu có rất nhiêù máy hơn nưã thì tôi cũng có thể tự động hoá được, tự lập trình mà không dùng đến Ansible. Ví dụ ta thấy các file tên layer1-2-3.sh, đây là các file ban đầu dựng lên server, các file này không phải được viết chay, mà chúng được tự động render lên, nhờ áp dụng tư duy MVT cuả Frontend Engineer.
- Giám sát Metric bằng stack InfluxDB - Telegraf. Giám sát Log bằng stack Kibana - Elasticsearch - Logstash - Beat, ở đây do giới hạn tài nguyên nên không trình bày Giám sát Log.
- Bảo mật cơ bản: dùng Nginx bọc ngoài cho tất cả service, chứng chỉ SSL tự gia hạn, SHA3 bảo mật cho API.
- Thơì gian xây dựng dự án: 8 tiếng.

# Tài nguyên
- 2 máy ảo, nhà cung cấp Việt Nam. Cấu hình mỗi maý: 1 vCore, 2 GB RAM, 12 GB SSD.
- 2 tên miền:
  + Server CI: quang.vip. File SSH private: secret/quang.vip.pri, user root
  + Sevrer CD: quang.pro. File SSH private: secret/quang.pro.pri, user root
- 3 kho chưá code:
  + Kho code dựng server: https://github.com/quangdaicaa/basevn
  + Kho source code: https://github.com/quangdaicaa/basevn_html
  + Kho Docker Hub: https://hub.docker.com/r/quangdaicaa/html
- Điạ chỉ:
  + CV cá nhân: https://quang.pro
  + View sản phẩm: https://quang.pro:777
  + Server metric: http://quang.pro:888. Username/Password: quangpro/wuKddVM3TGh7AHf
  + API cuả server CI: https://quang.pro:666/docs
  + API cuả server CD: https://quang.vip:666/docs
  + Webhook nối Github vơí CI: https://quang.vip:666/hook
  + Webhook nối CI với CD: https://quang.pro:666/deploy

# Mô hình
- Bước 1: Người dùng commit source code (HTML thuần) lên https://github.com/quangdaicaa/basevn_html
- Bước 2: Github gửi webhook đến server CI https://quang.vip:666/hook
- Bước 3: Server quang.vip tải source code về
- Bước 4: Server quang.vip build source code thành binary code (tạm bỏ qua)
- Bước 5: Server quang.vip đóng gói binary code vào container Alpine
- Bước 6: Server quang.vip đâỷ container Alpine lên https://hub.docker.com/r/quangdaicaa/html
- Bước 7: Server quang.vip phát tín hiệu webhook đến server CD https://quang.pro:666/deploy
- Bước 8: Server quang.pro tải container Alpine về 
- Bước 9: Server quang.pro cho container chaỵ ngầm, ánh xạ cổng, ánh xạ ổ điã SSL
- Bước 10: Server quang.pro trình bày sản phẩm lên view https://quang.pro:777 thông qua Nginx
- Ngoài ra: Server quang.pro và quang.vip định kỳ gửi metric theo dõi hệ thống và tình trạng container về Database http://quang.pro:888

# Cây thư mục
- Thư mục quang.pro: chưá code dựng server quang.pro
- Thư mục quang.vip: chưá code dựng server quang.vip
- Các file layer.sh: file khởi tạo server ban đâù từ khi mơí cài hệ điêù hành
- Thư mục secret: chưá các mã SSH, mã access API, mã login Docker Hub, Token Database