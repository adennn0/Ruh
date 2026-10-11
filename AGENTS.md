# Ruhun Parlıyor — ajan proje kuralları

Spesifikasyon: `docs/SPEC.md` (tam belge; yoksa kullanıcıdaki master prompt v3). Saat Anı çekirdeği: `docs/TIME_MOMENT_SYSTEM.md`. 4. aşamadan devam: `docs/CLAUDE_HANDOFF.md`.

## Stack
Flutter + Dart · Riverpod · go_router · Drift (SQLite) · shared_preferences · flutter_local_notifications + timezone · intl · share_plus · local_auth · phosphor_flutter · home_widget (Aşama 5B).

## Komutlar
- Çalıştır: `flutter run`
- Analiz: `flutter analyze` (sıfır uyarı hedefi)
- Test: `flutter test`
- Format: `dart format .`

## Kurallar
- Platform: Android öncelikli, iOS sonra. Platforma özgü her şey `lib/platform/` adaptörleri arkasında; UI Android API'si çağırmaz.
- UI / domain / data katmanlarını ayır; iş mantığı widget içine girmez.
- Renk, yazı, boşluk, radius yalnızca tema tokenlarından; widget'ta sabit renk yok.
- Premium/limit kararları yalnızca `EntitlementService` ve `lib/core/limits.dart` üzerinden.
- API anahtarı repoya veya uygulamaya girmez. AI yalnızca backend proxy üzerinden.
- Mock/demo içerik her yerde açıkça işaretli; gerçekleşmeyen özellik "çalışıyor" gösterilmez. Çalıştırmadığın testi "geçti" diye raporlama.
- Astrolojik değerler deterministik hesaplanır; AI uydurmaz. Hesaplanamıyorsa gösterme.
- Dil: korku/garanti/suçluluk/şifa iddiası yok. Türkçe karakterleri doğrula.
- **Çekirdek ürün:** kişiselleştirilmiş Saat Anı bildirimleri (çift + palindrom saatler). Kota ücretsiz 5 / premium 12. 7 günlük kayan pencere. İzin yoksa planlama yok. Niyet metni kilit ekranına sızmaz. Mesaj tonu tam metni şekillendirir.
- Widget'a günlük/niyet/doğum/kişi verisi asla sızmaz.
- Varsayımları `docs/DECISIONS.md`'ye yaz; spec'te cevabı olan şeyi sorma.
- Spec'teki "Backlog"u (Bölüm 23) istenmedikçe yapma.
- Görsel ciladan önce arka plan davranışını bitir (kullanıcı önceliği).

## İş akışı
1. `docs/CLAUDE_HANDOFF.md` oku. Aşama 1–4 büyük ölçüde mevcut; silerek başlama.
2. Analyze + test; Aşama 4 boşluklarını kapat; Saat Anı bildirimini regresyona uğratma.
3. Aşama 5’ten kesintisiz ilerle; her aşama sonunda analyze + test + commit + kısa rapor.
4. Her ekranı bitirmeden önce spec Bölüm 25 öz denetimini uygula.
