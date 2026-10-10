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
