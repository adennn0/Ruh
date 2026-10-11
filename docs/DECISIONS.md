# DECISIONS.md — Varsayımlar ve Teknik Kararlar

Her satır: tarih · karar · gerekçe

---

## 2026-10-10

### D-01 · Tema başlangıcı
Varsayılan tema `amethystAurora` (koyu). Sistem açık/koyu tercihi Aşama 3'te `settings`'ten okunur; o zamana kadar her zaman koyu tema kullanılır.

### D-02 · Yazı ölçeği sınırı
`textScaler` 0.8–1.5 arasında sıkıştırıldı. Bu, kullanıcının 200% sistem yazı boyutu ayarlamasını engellemez; yalnızca aşırı küçülmeyi önler ve Bölüm 22'nin "200% desteklenir" zorunluluğuyla uyumludur.

### D-03 · Onboarding yönlendirmesi
Aşama 1 iskeletinde her açılışta onboarding'e yönlendirilir. Aşama 2'de `shared_preferences`'dan `onboardingDone` okunarak bu düzeltilecek.

### D-04 · AIContentService varsayılan uygulama
`LocalContentService` varsayılan; Aşama 6'da `RemoteAIService` ile değiştirilecek. Provider override ile kolayca değiştirilebilir yapı kuruldu.

### D-05 · Drift WAL modu
`PRAGMA journal_mode = WAL` aktif; uygulama arka planda okuma/yazma performansını artırır ve kilitlenme riskini azaltır.

### D-06 · Navigator stack per tab
`StatefulShellRoute.indexedStack` seçildi; bu sayede her sekme kendi yığınını korur, sekme değişiminde state kaybolmaz (spec Bölüm 8).

### D-07 · textScaler clamp 1.5
Flutter'ın `TextScaler.linear` API'si kullanıldı (eski `textScaleFactor` deprecated). Maksimum 1.5x sınırı: 15sp gövde metni en fazla 22.5sp olur, kırılma yaşanmaz.

### D-08 · Fontlar — Fraunces + Manrope
Spec Bölüm 6.4'te önerilen Fraunces ve Manrope seçildi. Fontlar `assets/fonts/` dizininde gömülü olacak. Türkçe karakter desteği (ı İ ş Ş ğ Ğ ü Ü ö Ö ç Ç) font dosyalarının tam Unicode kapsamıyla sağlanır. Fontlar Google Fonts OFL lisansıyla ücretsizdir.

### D-09 · Parçacık efekti
Aşama 3'te arka plan parçacık sayısı `AppLimits.maxParticleCount` (60) ile sınırlandırılacak. `MediaQuery.disableAnimations` ve uygulama içi "Hareketi azalt" ayarına saygı gösterecek.

### D-10 · Ruh hayvanı zaman dilimi sınırları
Spec Bölüm 12.3'ten: Şafak 04:00–09:59, Gün 10:00–15:59, Akşam 16:00–21:59, Gece 22:00–03:59. `SpiritAnimalTimePeriod.fromHour` deterministik olarak hesaplar.

### D-11 · DAO metod adlandirma
Drift DatabaseConnectionUser'daki update(table)/delete(table) ile celiski olmasin diye DAO metodlari yeniden adlandirildi: insertIntention, updateIntention, deleteIntention, insertEntry, updateEntry, deleteEntry.

### D-12 · Icerik JSON semasi (Phase 3)
Flat list: {id, sign, tone, type, text, tags}. type = 'message' | 'affirmation'. LocalContentService in-memory filtreleme yapar, nested map yerine.

### D-13 · StreakBit vs StreakActivity
enums.dart'taki StreakActivity (value object) ile cakisma onlemek icin streak_repository.dart'ta bitmask sabitleri StreakBit adini aldi.

### D-14 · EmptyStateWidget API
title (required) + subtitle (optional). message parametresi yok — bu ayrim tum journale screen'lerde uygulanmali.

### D-15 · Uyumluluk skoru hesaplama (Phase 4)
Deterministik: element iliskisi baz skor (52-88) + nitelik duzeltmesi (-3..+4), ayni burc=78 sabit, 40-95 arasi sikistrima. Simetrik: calculate(a,b)==calculate(b,a). 78 benzersiz cift icin orijinal Turkce yorum.

### D-16 · Kayitli kisiler limiti
Ucretsiz 3, premium sinirsiz. SavedPersonTable'da saklanir, SavedPersonDao ile erisim. Gizlilik: yalnizca cihazda, paylasim kartinda kisi bilgisi yalnizca acik izinle.

### D-17 · Dogal tas eslemesi
12 burc icin deterministik 1:1 esleme. Saglik/sifa iddiasi YOK, sembolik cerceve notu zorunlu.

### D-18 · Ruh hayvani zaman dilimi
12 burc x 4 donem (Safak/Gun/Aksam/Gece). Saat bilinmiyorsa ana form gosterilir, nedeni aciklanir.

### D-19 · Ay takvimi yaklasik hesaplama
Sinodik ay dongusu (29.530588853 gun), referans yeni ay 2000-01-06 18:14 UTC. ~yaklasik notu her zaman gorunur.

### D-20 · Saat Anı çekirdek bildirim kotası (ürün kararı)
Ücretsiz günde 5, premium günde 12 kişiselleştirilmiş özel saat. Spec v3'teki 2/8 genel hatırlatıcı kotasının yerini alır; çünkü uygulamanın asıl amacı çift/palindrom saatlerde kişisel duraktır. Sayılar `lib/core/limits.dart`.

### D-21 · Özel saat tanımı
Ayna/çift: HH:HH (01:01…23:23). Palindrom: HHMM dört hanesi palindrom (14:41, 12:21, 23:32, 10:01…). Kesişim (11:11, 22:22) `both`. Katalog `SpecialTimes`.

### D-22 · Kişisel seçki
Her gün `localDate + burç + ton + contentSalt + niyet başlıkları` ile deterministik skor. Sessiz saatler elenir. Aynı kişi+gün aynı saatler; farklı `contentSalt` farklı seçki. Niyet başlığı kilit ekranına yazılmaz, yalnızca tıklanınca tam mesajda görünür.

### D-23 · Saat dilimi
Yerel bildirimler `Europe/Istanbul` varsayılanı ile kurulur (TR ürün). Cihaz TZ okuma paketi eklenmedi.

### D-24 · Günlük içerik kişiselleştirme tuzu
`content_salt` SharedPreferences'ta üretilir. `generateDailyMessage` tohumuna girer; aynı burç+ton kombinasyonundaki herkese aynı metin gitmez.

### D-25 · Özellik sırası (kullanıcı önceliği)
2026-10-10 itibarıyla kullanıcı, Ruh Kedisi/Aşama 5'in sıradaki iş olmasını istemiyor. Önce mevcut uygulamadaki diğer özellikler ve işlevsel açıklar tamamlanacak; gerçek AI entegrasyonu en sona bırakılacak. Eşlikçi karakter türü kediyle sınırlı değil; kullanıcının kişisel ruh hayvanı fikri değerlendirilerek bu özellik daha sonra netleştirilecek. Mevcut hiçbir özellik bu karar nedeniyle kaldırılmayacak.

### D-26 · Günlük seçimlerde süreçler arası kararlılık
Saat Anı seçkisi ve tarihli yerel içerik tohumları uygulama yeniden açıldığında da aynı kalmalı. Dart `Object.hash` süreçler arasında kararlı olmadığı için bu tohumlarda `stableHashParts` kullanılır.

### D-27 · Eşlikçi karakter türü (Aşama 5)
Kullanıcının 2026-10-10 talimatı doğrultusunda Aşama 5 tek bir kedi türüne bağlanmaz. Eşlikçi kişisel ruh hayvanı olarak seçilebilir; varsayılan tür, mevcut deterministik ruh hayvanı eşleşmesinden gelir. Bu aşamanın ilk sürümünde ad/tür/görünüm yerel tercihlerde saklanır. Kozmetik açılımları en uzun Işık Serisi değerine göre türetilir; seri düşmesi açılmış eşyaları geri almaz. Görsel asset'ler hazır olana kadar tema tokenlarıyla sembolik, açıkça geçici avatar kullanılır.

### D-28 · Android widget güncelleme penceresi (Aşama 5B)
Widget, uygulama içerik veya tercihleri değiştiğinde güncellenir ve Android'in pil kısıtlarına saygı için sonraki 7 yerel gün başlangıcına yenileme isteği bırakır. Sistem yenilemesi gecikebilir; tarihli snapshot artık güncel değilse yerel widget yalnızca genel fallback gösterir. Yeni kişiselleştirilmiş içerik uygulama açılınca tekrar yazılır. Widget'a niyet, doğum bilgisi, günlük yazısı veya kayıtlı kişi aktarılmaz.

### D-29 · Gerçek AI aşama sırası
Kullanıcının isteğiyle gerçek uygulama içi AI entegrasyonu son işlev aşamasına ertelenir. Aşama 5B sonrasında önce AI dışındaki istenen ürün özellikleri tamamlanır; sonra gerçek AI proxy'si/servisi ele alınır. Mock/local rehber bu sırada çalışır ve açık biçimde işaretli kalır.

### D-30 · Eşlikçi kozmetiklerinin yerel gösterimi
2026-10-10 kullanıcı isteğiyle eşlikçi tamamlanırken kozmetikler yuva başına kaydedilir (şapka, gözlük, atkı, pelerin, kolye, aura). Önceden kaydedilmiş tek `equippedCosmetic` alanı aura yuvasına taşınır. Gerçek hayvan render asset'leri henüz bulunmadığından Phosphor sembolleri geçici, türü belli eden avatarı oluşturur; bitmiş 3D hayvan sanılmaz.

### D-31 · Premium mağaza bağlantısı yapılandırma bekliyor
Aşama 7 paywall/entitlement ekranı mağaza kataloğu yokken fiyat veya satın alma sonucu uydurmaz. App Store/Play ürün kimlikleri, mağaza hesapları ve abonelik koşulları repoda bulunmadığından henüz satın alma SDK'sı eklenmedi; satın alma CTA'sı pasif, geri yükleme eylemi de mağaza sorgusu yapmadığını açıkça bildirir. Bu yapılandırmalar geldiğinde yerel entitlement durumu mağaza doğrulamasıyla değiştirilmelidir.

### D-32 · Enerji akışı öz bildirimi ve zaman çizgisi
Enerji/odak/ruh hâli yalnızca kullanıcının girdiği öz gözlemdir; sensör veya otomatik çıkarım yapılmaz. Kullanıcı aynı gün birden fazla kayıt ekleyebilir. Geçmiş değerler yerel Drift tablosunda saklanır; grafik seçili tarihteki gerçek kayıtları gösterir, veri yoksa boş durum kullanır.

### D-33 · Tema kataloğu ve eski kimlikler
İstek altı görünür palet (Sade, Doğa, Uzay, Kum, Deniz, Ateş) tarif ediyor; uygulamada farklı adlandırılmış beş mevcut tema ve kayıtlı tema kimlikleri var. Kayıtlı tercihler bozulmasın diye eski ID'ler korunur; Pearl Moon Sade, Cyber Nebula Uzay, Ocean Moon Deniz olarak Türkçe gösterilir ve Doğa/Kum/Ateş yeni ID'lerle eklenir. Mevcut Amethyst ve Rose Quartz temaları kaldırılmaz.

### D-34 · Yeni profiller için sade başlangıç teması
Kullanıcının nötr palet tercihi doğrultusunda yeni onboarding profilleri ve kaydı olmayan profiller Pearl Moon (Sade) ile başlar. Daha önce kaydedilmiş tema tercihleri korunur; Pearl Moon'un renkleri daha düşük doygunluklu, açık ve metin kontrastı yüksek olacak şekilde düzenlenir.

### D-35 · Kişiye özel günlük enerji akışı
Enerji Akışı'ndaki mevcut öz bildirim ve geçmiş grafikleri korunur. Ayrı bir günlük plan, tarih + burç + iletişim tonu + yerel kişisel tuzdan deterministik olarak üretilir; ölçüm, gelecek tahmini veya sağlık iddiası değildir. Ücretsiz kullanıcı bir zaman aralığını görür, premium tam üç aralığı görür. Premium kapısı `EntitlementService` ve `AppLimits` üzerinden uygulanır.

### D-36 · Saat Anı niyetinin bulunabilirliği
Saat Anı niyetleri `time_moment` Drift tablosunda kalıcıdır. Kaydetme tamamlandığında geçmiş ekranı açılır ve ana ekrandaki Saat Anı kartı geçmişe doğrudan erişim sunar. Bildirimden açılan form, bildirimin yerel tarihini ve özel saatini korur.

### D-37 · Mobil arayüz hiyerarşisi
Beş alt sekme dar ekranda eşit genişlikte, daima etiketli ve sistem `NavigationBar` davranışıyla görünür. Tekrarlayan parıltı animasyonları temel akışlardan kaldırılır; CTA ve yüzeyler ortak tema tokenlarıyla daha sakin, düz ve erişilebilir tutulur.

### D-38 · Bildirim izni, değişken metin ve premium gece molası
Onboarding tamamlandıktan sonraki ilk ana ekran girişinde bir kez açıklayıcı bildirim izni penceresi gösterilir; işletim sistemi izni yalnızca kullanıcı kabul ederse istenir, erteleme tekrar tekrar sorulmaz. Bildirim gövdeleri kişisel niyet başlığını içermez ve aynı özel saat için kayan 7 günlük pencerede tekrarlanmaz. Premium gece niyet molası varsayılan kapalıdır; kullanıcı 22:00–08:00 arasında tek saat seçip yalnızca bu hatırlatmanın uygulama sessiz saatlerini aşmasını açıkça etkinleştirir. Bu bildirim günlük kotaya dahildir ve burç içeriği en uygun saat/sonuç tahmini olarak sunulmaz. Bildirime dokununca niyet ekleme ve kişisel anı onaylama seçenekleri gösterilir; onay yerel tercihte tarih/saat bazında saklanır.
