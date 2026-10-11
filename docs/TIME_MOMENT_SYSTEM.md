# Saat Anı sistemi — çekirdek ürün

Bu uygulama **çift saat** (11:11, 14:14, 22:22) ve **palindrom saat** (14:41, 12:21, 23:32) anlarında kullanıcıya kişisel bir durak hatırlatmak için vardır. Bu özellik dekoratif değildir; Aşama 4+ işinde regresyona uğratılmaz.

## Ne vardı, ne eklendi

Önce: Saat Anı ekranı vardı; bildirim adaptörü boş TODO idi; ayarlar yalnızca anahtardı, gerçek izin/planlama yoktu.

Şimdi:
- Katalog: `lib/domain/time_moment/special_times.dart`
- Günlük kişisel seçki: `lib/domain/time_moment/time_moment_planner.dart`
- Ton + burç + tuz metinleri: `lib/domain/time_moment/time_moment_copy.dart`
- Gerçek Android izin + `flutter_local_notifications`: `lib/platform/notifications/notifications_adapter.dart`
- 7 günlük kayan pencere: `lib/domain/services/notification_scheduler.dart`
- Bildirime dokununca tam mesaj: `lib/features/time_moment/time_moment_message_screen.dart` (`/time-moment/open`)

## Kurallar (bozulmaz)

1. İzin yoksa planlama yok. İlk istek, kullanıcı bir bildirimi açtığında bağlamıyla yapılır.
2. Ücretsiz **günde 5**, premium **günde 12** özel saat (`AppLimits`).
3. Saatler herkese aynı liste olarak gitmez. Tohum: tarih + burç + ton + `contentSalt` + aktif niyet başlıkları.
4. Sessiz saatler (varsayılan 22:00–08:00) herkese açık, planlamadan düşülür.
5. Kilit ekranı gövdesinde niyet metni yok. Tam mesaj tıklanınca, seçilen **mesaj tonu** ile yazılır.
6. Dil: gerçekleşme garantisi, kader, korku, şifa iddiası yok. Sembolik durak + küçük somut adım.
7. Planlama 7 günlük pencere; uygulama açılışı, ön plana dönüş, ayar değişiminde yeniden kurulur.
8. Platform kodu yalnızca `lib/platform/` arkasında durur.

### Android teslim koşulları

- Manifest, `ScheduledNotificationReceiver` ve `ScheduledNotificationBootReceiver` bileşenlerini içermelidir; ikincisi yeniden başlatma ve uygulama güncelleme olaylarında planı geri kurar.
- Android 13+ bildirim izni verilmediyse planlama yapılmaz. Ayarlar ekranı izin durumunu ve sıradaki bildirim sayısını gösterir; kullanıcı "İzin ver ve bildirimleri etkinleştir" eylemiyle izin akışını başlatır.
- Dakika hassasiyeti için `SCHEDULE_EXACT_ALARM` özel erişimi istenir. Kullanıcı bunu vermezse bildirimler yalnızca Android'in daha geç teslim edebileceği yaklaşık modda planlanır.
- Android 16 fiziksel cihazında 2026-10-10 tarihinde `POST_NOTIFICATIONS` reddedilmişti; bu izin kullanıcı tarafından verilmeden görünür bildirim teslimi doğrulanamaz.

## Kullanıcı akışı

1. Profil veya Ana Sayfa zili → Bildirim Ayarları → **Kişisel Saat Anı** açık.
2. Android 13+ `POST_NOTIFICATIONS` izni istenir.
3. O gün (ve sonraki 6 gün) kişisel saatler planlanır.
4. Bildirim gelir → dokununca o ana özel tam metin + “niyetimi söyle” / nefes molası.

## Test

```bash
flutter test test/time_moment/special_times_test.dart
```

Gerçek cihaz: izin ver, 11:11 veya bir sonraki planlı saati bekle (veya sessiz saatleri daraltıp debug ile pending listesini kontrol et). Emülatörde tam zamanlı alarm kısıtlı olabilir; raporda dürüst ol.

## Claude Code notu

Bu sistemi silip “basit 11:11 alarmı”na indirgeme. Görsel cila Aşama 9. Önce bu davranışın gerçek cihazda çalıştığını doğrula, sonra Aşama 5 (Ruh Kedisi).
