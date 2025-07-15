# inception_42

Host bilgisayardan VM'e klasör gönderme komutu:

```bash
scp -r -P 3022 ./inception relvan@127.0.0.1:/home/relvan/
```

Host bilgisayar ve VM'in terminallerini bağlamak için 2 yol:

1 - VM'e ssh yüklemek
```bash
sudo apt update
sudo apt upgrade
sudo apt install ssh
systmctl start ssh
```

2 - VM'in Ayarlar/Ağ sekmesinde NAT'ı Bridged Adaptöre çevirmek veya NAT kullanılmak isteniyosa terminal için port yönlendirmesi yapmak (TCP/Host Port:3022/Guest Port: 22)
+ NAT, sanal makinenin host bilgisayarın internetini paylaşmasını sağlar. Bridged adaptör ise sanal makineyi ağdaki ayrı bir cihaz gibi gösterir ve kendi IP adresini doğrudan ağdan alır.

-> eğer Bridge Adaptor ise;

```bash
ssh kullanıcıadı@ip
```

-> eğer port yönlendirmesi var ise;

```bash
ssh kullanıcıadı@localhost -p 3022
```

Temel SQL komutları:

```sql
-- Veritabanlarını listele
SHOW DATABASES;

-- Veritabanı oluştur
CREATE DATABASE wordpress;

-- Kullanıcı oluştur
CREATE USER 'wpuser'@'%' IDENTIFIED BY 'password';

-- Kullanıcıya yetki ver
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';

-- Yetkileri yenile
FLUSH PRIVILEGES;

-- Veritabanını seç
USE wordpress;

-- Tabloları listele
SHOW TABLES;

-- Kullanıcıları listele
SELECT User, Host FROM mysql.user;

-- Veritabanından çık
EXIT;
```
Docker build'in cache'ini temizlemek için:

```bash
cd /home/vboxuser/Downloads/inception_42 && docker system prune -f
```

Docker container loglarına bakma:

```bash
# Tüm servislerin logları
docker-compose -f ./srcs/docker-compose.yml logs

# Belirli bir servisin logları
docker-compose -f ./srcs/docker-compose.yml logs wordpress
docker-compose -f ./srcs/docker-compose.yml logs nginx
docker-compose -f ./srcs/docker-compose.yml logs mariadb

# Canlı log takibi (real-time)
docker-compose -f ./srcs/docker-compose.yml logs -f
```

docker-compose'un genişletilmiş hali;

```bash
docker-compose -f ./srcs/docker-compose.yml config
```
