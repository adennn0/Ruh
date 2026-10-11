# Claude Code — 4. aşamadan devam

Bu dosyayı ve `docs/SPEC.md` (yoksa kullanıcıdaki `ruhun_parliyor_master_prompt_v3.md`), `AGENTS.md`, `docs/TIME_MOMENT_SYSTEM.md`, `docs/DECISIONS.md` dosyalarını oku. Sohbet geçmişine güvenme.

## Proje durumu (2026-10-10)

| Aşama | Durum |
|---|---|
| 1 İskelet | Yapıldı |
| 2 Onboarding | Yapıldı |
| 3 Çekirdek ekranlar | Yapıldı (UI); **Saat Anı bildirimleri yeni tamamlandı — doğrula, regresyona uğratma** |
| 4 Keşfet | Ekranlar var (uyumluluk, taş, ruh hayvanı, ay); simetri, determinizm ve ay referans testleri geçti (128 toplam test). **Yeniden yazma.** |
| 5 Eşlikçi karakter | İşlevsel yerel eşlikçi: tür/ad/renk, uyumlu sembolik hayvan ikonu, yuva bazlı kozmetik tak/çıkar, seri kilometre taşı, eski kayıt geçişi; Ana Sayfa, Keşfet ve Profil girişleri. Gerçek 3D hayvan görselleri ve animasyon asset üretimi bekliyor. |
| 5B Android widget | Flutter/native Android XML widget, gizli mod, seri tercihi, deep-link launch ve yedi günlük yerel yenileme penceresi uygulandı. Bağlı Android cihaz görünmediğinden gerçek ana ekran ekleme ve fiziksel cihaz QA'sı bekliyor. |
| 7 Premium satın alma | Ürün/limit bilgili paywall ve Profil/keşif girişleri hazır. Mağaza hesabı/ürün kimlikleri yapılandırılmadığı için satın alma CTA'sı pasif ve geri yükleme açıkça kullanılamaz; D-31. |
| 8 Ay/yükselen | Sıradaki AI dışı aşama; doğrulanmış ephemeris çözümü ve referans harita doğrulaması gerekir. |
| 6 AI | Gerçek AI entegrasyonu, AI dışındaki istenen aşamalardan sonra en son işlev aşaması (kullanıcı önceliği) |
| 9 Cila | En sonda |

## Kullanıcının asıl amacı (öncelik 1)

Uygulama, **11:11 / 22:22 / 14:14** gibi çift saatlerde ve **14:41** gibi palindrom saatlerde kişiye özel bildirim gönderir. Kullanıcı bildirime dokununca o ana, **burcuna, mesaj tonuna ve niyetlerine** göre bir metin görür; niyet diler. Bu “güzel bir ekstra” değil, ürünün neden var olduğudur. Ek olarak uygulamaya eklenilmesi güzel olacak amacına uygun özellikler eklenilebilir.

Zaten kodda:
- `lib/domain/time_moment/`
- `lib/platform/notifications/notifications_adapter.dart` (artık gerçek; TODO değil)
- `NotificationScheduler` 7 günlük pencere
- Kota: ücretsiz 5 / premium 12 (`limits.dart`)
- Günlük mesaj/olumlama tohumuna `contentSalt` — herkese her gün aynı metin gitmez

Yapman gerekenler:
1. `flutter analyze` ve `flutter test` çalıştır; kırıkları düzelt.
2. Aşama 4 test kabulü (spec madde 14): uyumluluk simetrisi, ruh hayvanı determinizmi, ay evresi referans tarihleri — eksikse ekle.
3. Bildirimleri gerçek Android cihazda dene. 2026-10-11'de kullanıcı bildirimlerin artık kendi telefonunda geldiğini doğruladı; teslim sorunu kapalıdır. Yeni izin/planlama değişikliklerinde regresyon testlerini çalıştır.
4. Kullanıcının 2026-10-10 tarihli önceliği: Aşama 5'i tek bir kedi türüne sabitleme; kişisel ruh hayvanı eşlikçisine izin ver. Bir özelliği kaldırma.
5. Gerçek AI entegrasyonunu en sona bırak.

## Yapma

- Saat Anı’nı sabit tek 11:11 alarmına indirgeme.
- Niyet metnini kilit ekranı bildirimine yazma.
- “Kesin gerçekleşecek / evren sana şunu söylüyor / iyileştirir” dili.
- Backlog (spec 23) ve Aşama 6–8’i kullanıcı istemeden.
- API anahtarı gömme.
- Kullanıcının önceliği dışında yeni özelliği kendiliğinden kaldırma veya yerine geçirme.
- Spec’te cevabı olan şeyi sorma; varsayımı `docs/DECISIONS.md` satırına yaz.

## Komutlar

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

## Güncel devir notu (2026-10-11)

- Kullanıcının cihazında Saat Anı bildirim teslimi düzeldi ve kullanıcı tarafından doğrulandı.
- 37 özel saatin tamamı için kategori/anlam ve 30'ar sembolik düşünme metni tanımlandı; `TimeMomentCopyEngine` artık bu havuzdan burç/ton/tarih/kişisel tuza göre seçim yapıyor. İçerik kehanet değil, öz-yansıtma olarak çerçevelenir.
- İsteğe bağlı 1 ve 7 günlük niyet hatırlatması ilgili niyet sekmesini açar ve hedef kartını vurgular; bildirim gövdesinde kişisel niyet metni bulunmaz.
- Günlük içerik yerel tarihe göre saklanır, 7 günlük tekrar anahtarları kullanılır; Günün Mesajı ekranındaki yenileme ücretsiz/premium limitlerini uygular.
- Bağlı Ruhlar profili düzenlenebilir; yeni profiller nötr Sade temasıyla başlar ve alt gezinme dar ekranda eşit genişlikte sekmeler kullanır.
- Saat Anı niyeti Drift `time_moment` tablosunda saklanır; kaydetme sonrası geçmiş açılır ve ana ekrandan geçmişe kısayol vardır. Bildirimden açılan form özgün tarih/özel saati korur.
- Enerji Akışı'nda öz bildirim geçmişinden ayrı, burç/ton/tarih/kişisel tuz ile deterministik sembolik günlük plan bulunur; ücretsiz 1 aralığı, premium 3 aralığı görür. `EntitlementService`/`AppLimits` kullanılır.
- Mobil tasarım yenilemesinde alt gezinme eşit ve etiketli beş hedefe geçti; birincil CTA'lar düz tema rengine, başlıklar sans tipografiye geçti; temel Saat Anı ekranındaki tekrarlayan parıltı kaldırıldı. Tema seçici kaydırılabilir/yükseklik sınırlı hale getirildi.
- Son doğrulama: `flutter analyze` temiz; `flutter test --concurrency=1` 150 test geçti. Fiziksel Android cihaz bağlı olmadığı için telefon üzerinde görsel taşma QA'sı bu oturumda yapılamadı.
- Açık kalan dış doğrulamalar: Android cihaz görünmediği için ana ekran widget'ını fiziksel cihazda ekleme/QA; mağaza hesap ve ürün kimlikleri olmadan gerçek abonelik; kullanıcı kararı gereği gerçek AI entegrasyonu en sona bırakıldı. Ekranların tamamında fiziksel cihaz/200% yazı ölçeği öz denetimi yapılmış sayılmaz.

## Teslim

Her aşama: ne yapıldı, test çıktısı, bilinen sorun, sonraki aşama. Commit mesajı anlamlı olsun.
