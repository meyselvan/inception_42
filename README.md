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

2 - VM'in Ayarlar/Ağ sekmesinde NAT'ı Bridge Adaptöre çevirmek veya NAT kullanılmak isteniyosa terminal için port yönlendirmesi yapmak (TCP/Host Port:3022/Guest Port: 22)

-> eğer Bridge Adaptor ise;

```bash
ssh kullanıcıadı@ip
```

-> eğer port yönlendirmesi var ise;

```bash
ssh kullanıcıadı@localhost -p 3022
```
