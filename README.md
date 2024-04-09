# bitirme24
Salih Yıldız 200207014 Bitirme Tezi Projesi

FPGA'ler ile SWIR Görüntülerin Performansının Arttırılması

Renk bileşeni içermeyen SWIR görüntüler 7x7'lik Difference of Gaussains (DoG) filtresinden geçirilecek ve kenarları keskinleştirilecektir.
![test](https://github.com/samed12pqr/bitirme24/assets/165570990/511f0850-5ded-4898-b8b7-7e02d10b60d3)

DoG Filtresi Kerneli

![Screenshot_1](https://github.com/samed12pqr/bitirme24/assets/165570990/0e3047f6-90c5-4ef9-90e0-4ab5001d5516)

Şematik

![Screenshot_2](https://github.com/samed12pqr/bitirme24/assets/165570990/d63133e1-e00b-4279-896a-f5cbaca97ed5)

Son güncellemeler

- UART modülü tasarlandı ve Baudrate Timer ayrı bir modül yapıldı. (Top modul iki ayrı instination yapıyor, düzeltilmesi gerekebilir)
- Sağa kaydırma modülü tasarlandı. Bu modül ileride kenar filtresi olacaktır.
- Vivado artık FSM'leri algılıyor fakat halen daha yapılması gereken düzeltmeler var.
- MATLAB'den FPGA'ye 8 bit data gönderme testi yapıldı. 400 elemanlı bir vektörü başarıyla sağa kaydırıp MATLAB'e geri alabiliyoruz. Fakat FPGA ilk programlandığında MATLAB'e dönen datalar anlamsız değerler içeriyor.
