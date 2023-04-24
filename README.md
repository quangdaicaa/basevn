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

# Tài nguyên
- 2 máy ảo, nhà cung cấp Việt Nam. Cấu hình mỗi maý: 1 vCore, 2 GB RAM, 12 GB SSD.
- 2 tên miền:
  + Server vai trò CI: quang.vip
  + Sevrer vai trò CD: quang.pro
- 3 kho chưá code:
  + Kho code dựng server: https://github.com/quangdaicaa/basevn
  + Kho source code: https://github.com/quangdaicaa/basevn_html
  + Kho Docker Hub: https://hub.docker.com/r/quangdaicaa/html
- Điạ chỉ:
  + CV cá nhân: https://quang.pro
  + View sản phẩm: https://quang.pro:777
  + Server metric: http://quang.pro:888
  + API cuả server CI: https://quang.pro:666/docs
  + API cuả server CD: https://quang.vip:666/docs
  + Webhook nối Github vơí CI: https://quang.vip:666/hook
  + Webhook nối CI với CD: https://quang.pro:666/deploy
