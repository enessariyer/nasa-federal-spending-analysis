-- Script 2 kısımdan oluşuyor. DDL ve Veriden Çıkarım Yaptığımız Kısımlar.

-- KISIM 1 STAR SCHEME ve EDL

CREATE TABLE dim_recipient (
	recipient_key serial PRIMARY KEY,
	recipient_uei varchar(15) UNIQUE,
	recipient_name varchar(200)	
);

CREATE TABLE dim_award (
	award_key serial PRIMARY KEY,
	contract_award_unique_key varchar(50) UNIQUE,
	award_id_piid varchar(50),
	transaction_description text
	
);

CREATE TABLE fact_spending (
	fact_id serial PRIMARY KEY,
	recipient_key int REFERENCES dim_recipient(recipient_key),
	award_key int REFERENCES dim_award(award_key),
	action_date DATE,
    federal_action_obligation DECIMAL(18, 2),
    total_dollars_obligated DECIMAL(18, 2),
    total_outlayed_amount DECIMAL(18, 2),
    current_total_value DECIMAL(18, 2),
    base_and_options_value DECIMAL(18, 2)
);

-- Verileri önce python üzeride temizleyip daha sonra burada oluşturduğum tablolara yükledim.

-- AŞAMA 1 - Data Auditing -- Öncelikle Veri ile ilgili bazı denetimler  yapalım.


-- Kritik satırlarda boş hücre var mı?

SELECT 
    COUNT(*) as toplam_satir,
    COUNT(*) FILTER (WHERE recipient_key IS NULL) as eksik_alici_id,
    COUNT(*) FILTER (WHERE award_key IS NULL) as eksik_sozlesme_id,
    COUNT(*) FILTER (WHERE action_date IS NULL) as eksik_tarih,
    COUNT(*) FILTER (WHERE federal_action_obligation IS NULL) as eksik_butce_verisi
FROM fact_spending;

-- Finansal Mantık Hatası var mı? Bütçe aşımı var mı?

SELECT 
	fact_id,
	recipient_key,
	total_outlayed_amount,
	current_total_value,
	(total_outlayed_amount - current_total_value) AS asim_miktari,
	(total_outlayed_amount - current_total_value) / NULLIF(current_total_value, 0) * 100 AS yuzdesel_asim
FROM fact_spending
WHERE total_outlayed_amount > current_total_value
ORDER BY asim_miktari DESC;

SELECT count(*) FROM fact_spending WHERE total_outlayed_amount > current_total_value

-- 5170 tane bütçe aşımı normal değil. Belirli bir alıcı veya kategoride mi yoğunlaşılmış?

SELECT
	r.recipient_name,
	count(*) AS asim_yapan_is_sayisi,
	round(sum(f.total_outlayed_amount - f.current_total_value), 2) AS toplam_asim_miktari_usd,
	round(avg((f.total_outlayed_amount - f.current_total_value) / NULLIF(f.current_total_value, 0))* 100, 2) AS ortalama_asim_yuzdesi
FROM
	fact_spending f
JOIN dim_recipient r
ON
	f.recipient_key = r.recipient_key
WHERE
	f.total_outlayed_amount > f.current_total_value
GROUP BY
	r.recipient_name
ORDER BY
	toplam_asim_miktari_usd DESC
LIMIT 10


-- Aşım yapan kategoriler en çok hangileri -- 

SELECT
	CASE 
		WHEN a.transaction_description ILIKE '%research%' THEN 'research & development'
		WHEN a.transaction_description ILIKE '%space station%' THEN 'international space station'
		WHEN a.transaction_description ILIKE '%launch%' THEN 'launch services'
		WHEN a.transaction_description ILIKE 'engineering' THEN 'engineering services'
		ELSE 'diger hizmetler'
	END AS proje_kategorisi,
	count(*) AS satir_sayisi,
	sum(f.total_outlayed_amount - f.current_total_value) AS kategori_toplam_asim
FROM
	fact_spending f
JOIN dim_award a
ON
	f.award_key = a.award_key
WHERE
	f.total_outlayed_amount > f.current_total_value
GROUP BY
	1
ORDER BY
	3 DESC
	

-- aşım yapanlar için pareto analizi -- 

WITH asim_ozet AS (
	SELECT
		r.recipient_name,
		sum(f.total_outlayed_amount - f.current_total_value) AS toplam_asim
	FROM fact_spending f
	JOIN dim_recipient r ON f.recipient_key = r.recipient_key 
	WHERE f.total_outlayed_amount > f.current_total_value
	GROUP BY r.recipient_name
)
SELECT
	recipient_name,
	toplam_asim,
	sum(toplam_asim) OVER (ORDER BY toplam_asim DESC) / sum(toplam_asim) OVER () * 100 AS kumulatif_yuzde
FROM asim_ozet
ORDER BY asim_ozet.toplam_asim DESC
	
	
	
	
-- Negatif Değer ve 0 Analizi --

SELECT  
	'Negatif Yükümlülük' AS durum, 
	count(*) AS adet
FROM fact_spending
WHERE federal_action_obligation < 0
UNION ALL
SELECT
	'Sıfır Yükümlülük' AS durum,
	count(*) AS adet
FROM fact_spending
WHERE federal_action_obligation = 0
	
-- mapping de hata var mı? --

SELECT
	f.fact_id,
	f.recipient_key AS f_tablosundaki_id,
	r.recipient_key
FROM fact_spending f
LEFT JOIN dim_recipient r ON f.recipient_key = r.recipient_key
WHERE r.recipient_key IS NULL

-- zaman aralığı doğru mu? --

SELECT
	MIN(action_date),
	MAX(action_date),
	COUNT(DISTINCT action_date) AS farkli_gun_sayisi
FROM fact_spending
	
	
-- AŞAMA 2 Performans ve Sorgu Optimizasyonu (Indexing) --
	
-- analizden önce maliyet analizi --

EXPLAIN analyze
SELECT
recipient_key,
sum(federal_action_obligation)
FROM fact_spending
WHERE action_date > '2024-01-01'
GROUP BY recipient_key

DROP INDEX idx_fact_recipient

DROP INDEX idx_fact_date

DROP INDEX idx_fact_recipient_date

-- çıktıda seq scan olduğu görülüyor. performansı kötü etkiler --

CREATE INDEX idx_fact_recipient ON fact_spending (recipient_key)

CREATE INDEX idx_fact_date ON fact_spending (action_date)

CREATE INDEX idx_fact_recipient_date ON fact_spending (action_date, recipient_key)

EXPLAIN analyze
SELECT
recipient_key,
sum(federal_action_obligation)
FROM fact_spending
WHERE action_date > '2024-04-01'
GROUP BY recipient_key


-- Büyük veri yüklemelerinden sonra istatistikleri tazelemeliyiz --

VACUUM ANALYZE fact_spending;

VACUUM ANALYZE dim_recipient;

VACUUM ANALYZE dim_award


-- Index'ler yararlı olsada yer kapladıkları için maliyetleri de vardır. Kontrol etmeliyim.

SELECT
    relname AS tablo_adi,
    pg_size_pretty(pg_total_relation_size(relid)) AS toplam_boyut,
    pg_size_pretty(pg_relation_size(relid)) AS veri_boyutu,
    pg_size_pretty(pg_indexes_size(relid)) AS indeks_boyutu
FROM pg_catalog.pg_statio_user_tables
WHERE relname = 'fact_spending';



-- KISIM 2 Veri Ananlizi


-- AŞAMA 3 NASA ADVANCED QUANT ANALYTICS

-- ANALİZ 1 Oligopol Yapısı ve Market Share -- 

WITH alici_ozet AS (
SELECT
		r.recipient_name AS alici_ismi,
		sum(f.federal_action_obligation) AS toplam_fon
FROM
	fact_spending f
JOIN dim_recipient r
	ON
	f.recipient_key = r.recipient_key
GROUP BY
	r.recipient_name
)
SELECT
	alici_ismi,
	toplam_fon,
	sum(toplam_fon) OVER (ORDER BY toplam_fon DESC) / sum(toplam_fon) OVER () * 100 AS kumulatif_yuzde,
	toplam_fon / sum(toplam_fon) OVER () * 100 AS toplamdaki_pay
FROM alici_ozet
ORDER BY toplam_fon DESC 
	
SELECT count(*) FROM dim_recipient

-- 3110 toplam şirketten 45'ine fonların yüzde sekseni gidiyor. California Institute of Technology en büyük
-- yüzdeyi oluşturuyor.

-- Analiz 2 Para Yakma Hızı (Moving Average) --

WITH agg_tablo AS (
SELECT
	date_trunc('month', action_date) AS aylar,
	sum(federal_action_obligation) AS aylik_fon
FROM
	fact_spending
GROUP BY 1
)
SELECT
	to_char(aylar, 'YY-MM') AS donem,
	round(aylik_fon, 2) AS aylik_harcama,
	round(avg(aylik_fon) OVER (ORDER BY aylar ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS three_month_ma
FROM agg_tablo
ORDER BY aylar	


-- Performans olarak daha güçlü hali --
SELECT 
    DATE_TRUNC('month', action_date) as ay,
    SUM(federal_action_obligation) as aylik_toplam,
    -- Mevcut ay ve önceki 2 ayı kapsayan ortalama
    AVG(SUM(federal_action_obligation)) OVER(
        ORDER BY DATE_TRUNC('month', action_date) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as hareketli_ort_3_ay
FROM fact_spending
GROUP BY 1
ORDER BY 1;

-- Eylül ayında kamu kurumlarında görülen bütçeyi yak anlayışı gözlemlenebilir.


-- Analiz 3 Aylara göre büyüme kıyaslaması--

SELECT
	to_char(action_date, 'YY-MM') AS aylar
FROM
	fact_spending
GROUP BY
	aylar
ORDER BY
	aylar
	

WITH donemsel_karsilastirma AS (
SELECT
		r.recipient_name AS alici_ismi,
		sum(CASE WHEN date_trunc('month', action_date) = '2023-10-01'
		THEN f.federal_action_obligation ELSE 0 END) AS eski_donem,
		sum(CASE WHEN date_trunc('month', action_date) = '2024-01-01'
		THEN f.federal_action_obligation ELSE 0 END) yeni_donem
FROM
	fact_spending f
JOIN dim_recipient r ON
	f.recipient_key = r.recipient_key
GROUP BY r.recipient_name
)
SELECT
	alici_ismi,
	eski_donem,
	yeni_donem,
	round( (yeni_donem - eski_donem) / NULLIF(eski_donem, 0), 2) * 100 AS buyume_yuzdesi
FROM donemsel_karsilastirma
WHERE eski_donem > 0 AND yeni_donem > 0
ORDER BY buyume_yuzdesi DESC

-- Bir yılın Ekim ayı ile diğer yılın Ocak ayını karşılaştırmak elma ile armutu kıyaslamak gibi olsa da.
-- Farklı aylarda ödenen fonun ne kadar dalgalandığını görebiliriz.

-- ANALİZ 4 'Eylül Patlaması' Tespiti (MoM Growth)

-- Senaryo Kamu kurumlarıi bütçelerinin kesilmemsi için ellerindeki parayı mali yıl sonu olan Eylül'de
-- hızla harcar.

WITH aylik_ozet AS (
SELECT
	date_trunc('month', action_date) AS aylar,
	sum(federal_action_obligation) AS toplam_harcama
FROM fact_spending
GROUP BY aylar
)
SELECT
	to_char(aylar, 'YY-MM') AS aylar,
	(toplam_harcama - LAG(toplam_harcama) OVER w) / 
	NULLIF(LAG(toplam_harcama) OVER w, 0) * 100 AS buyume
FROM aylik_ozet
WINDOW w AS (ORDER BY aylar)
ORDER BY aylar

-- NASA'nın harcama yapısı, rutin bir bütçe akışından ziyade stratejik proje hakedişlerine ve 
-- mali yıl döngüsüne göre şekillenen, aşırı dalgalı ve "olay odaklı" bir karakter sergilemektedir.











