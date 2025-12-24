# NASA Federal Harcamaları Analiz Motoru (FY 2024)

### Proje Hakkında
Bu çalışmada, NASA'nın Ekim 2023 ile Eylül 2024 (2024 Federal Mali Yılı) tarihleri arasında gerçekleştirdiği federal harcamaları uçtan uca bir veri mühendisliği ve analiz süreciyle inceledim. Projenin temel amacı, devasa miktardaki kamu kaynağının nasıl dağıtıldığını, hangi şirketlerin bu süreçte stratejik rol oynadığını ve harcama paternlerindeki finansal dinamikleri ortaya çıkarmaktır.

---

### Analiz Kapsamında Yanıtlanan 4 Temel Soru
Analiz sürecinde, NASA’nın bütçe yönetimine dair şu kritik sorulara yanıt aradım:

1.  **Pazar Yoğunlaşma Analizi (Market Share):** NASA bütçesinin ne kadarı dev ölçekli şirketlere gidiyor? Tedarik zincirinde bir oligopol yapı veya yoğunlaşma riski var mı?
2.  **Harcama Trendleri ve Para Yakma Hızı (Moving Average):** Aylık harcamalardaki mevsimsel gürültüyü temizlediğimizde, NASA’nın reel harcama trendi ne yöne evriliyor?
3.  **Çeyreklik Fonlanma Momenti (QoQ Growth):** Şirketler mali yıla nasıl başladı ve nasıl bitirdi? İlk çeyrek (Q1) ile son çeyrek (Q4) arasındaki performans farkları nelerdir?
4.  **Mali Yıl Sonu "Eylül" Patlaması (September Surge):** Kamu bütçe disiplini gereği mali yılın son ayında harcamalarda istatistiksel olarak anlamlı bir artış yaşanıyor mu?

---

### Analiz Sonuçları ve Bulgularım
Elde ettiğim çıktılar üzerinden yaptığım finansal yorumlar şu şekildedir:

* **Pazar Yoğunlaşması ve Bağımlılık Riski:** Analiz sonuçlarına göre NASA bütçesinin **%11,10**'u tek başına **California Institute of Technology**'e, **%9,95**'i ise **SpaceX**'e aktarılmıştır. İlk 5 şirketin toplam bütçenin yaklaşık **%39,44**'ünü kontrol etmesi, kurumun stratejik projelerde belirli alıcılara yüksek düzeyde bağımlı olduğunu ve pazarda bir oligopol yapının hakim olduğunu kanıtlamaktadır.
* **Harcama Trendleri ve Hareketli Ortalama:** Aylık harcamalar incelendiğinde, verinin oldukça volatil bir yapı sunduğu görülmektedir. Özellikle Nisan 2024'teki **2,43 milyar $** ve Eylül 2024'teki **2,71 milyar $**'lık zirveler dikkat çekicidir. 3 aylık hareketli ortalama (`three_month_ma`), yılın son çeyreğinde harcama hızının istikrarlı bir şekilde yükselerek mali yıl kapanışına doğru ivme kazandığını göstermektedir.
* **Çeyreklik Performans ve Şirket Büyümeleri:** Mali yılın başı (Q1) ile sonu (Q4) karşılaştırıldığında, bazı şirketlerin fonlanma miktarında astronomik artışlar yaşadığı gözlemlenmiştir. Örneğin **Ares Technical Services** ve **ASRC Federal** gibi firmalar, yılın sonuna doğru fon miktarlarını binlerce kat artırarak mali yıl kapanışındaki bütçe dağılımından aslan payını almıştır.
* **Aylık Büyüme (MoM) ve Eylül Patlaması:** Aylık bazda büyüme oranları incelendiğinde, Nisan ayındaki **%86,32**'lik ve Temmuz ayındaki **%66,95**'lik sıçramalar, harcamaların dönemsel projelere göre kümelendiğini göstermektedir. Mali yılın son ayı olan Eylül'de harcamaların **%19,34** oranında artış göstermesi, literatürde **"September Surge"** olarak bilinen bütçe yakma operasyonunun istatistiksel bir göstergesidir.

---

### Metodoloji ve Teknik Süreç
Projeyi profesyonel bir veri ambarı (Data Warehouse) mimarisiyle şu adımları izleyerek gerçekleştirdim:

* **Veri Edinme ve Temizlik:** NASA harcama verilerini Python kullanarak ham formatta sisteme dahil ettim. Veri setindeki finansal değerleri ve tarih kolonlarını analiz için optimize ettim.
* **Mimari Tasarım (Star Schema):** İlişkisel veri bütünlüğünü sağlamak adına veriyi bir **Yıldız Şeması (Star Schema)** yapısında modelledim. Bu kapsamda `dim_recipient` (Alıcılar), `dim_award` (Sözleşmeler) boyut tablolarını ve tüm işlemleri merkezde toplayan `fact_spending` (Harcamalar) tablosunu oluşturdum.
* **SQL Entegrasyonu ve Optimizasyon:** Hazırladığım verileri PostgreSQL veritabanına aktardım. Milyonlarca satırda bile milisaniyeler içinde sonuç alabilmek için **Index** stratejileri geliştirdim ve `EXPLAIN ANALYZE` ile sorgu planlarını optimize ettim.
* **Analitik Sorgulama ve Görselleştirme:** Belirlediğim 4 temel soruyu cevaplamak için ileri seviye SQL tekniklerini (Window Functions, CTEs, Pivot) kullandım. SQL'den çektiğim bu rafine verileri Python ortamına aktararak **Plotly** kütüphanesiyle etkileşimli ve dinamik grafiklere dönüştürdüm.

---

### Projenin Amacı ve Kazanımlar
Bu proje ile temel olarak **SQL becerilerimi** ileri seviyeye taşımayı ve Python ile SQL'i entegre bir şekilde kullanma yetkinliği kazanmayı hedefledim. Veriyi sadece saklamakla kalmayıp, **Plotly** aracılığıyla interaktif bir görselleştirme süreci işleterek, veriden stratejik hikayeler çıkarma (**Data Storytelling**) becerimi geliştirdim.
