# Ruhun Parlıyor

Yapay zekâ destekli manifestasyon, günlük farkındalık ve kişisel spiritüel rehberlik uygulaması.

---

## Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK ≥ 3.3.0
- Dart ≥ 3.3.0
- Android Studio / VS Code
- Android SDK (API 21+)

### Adımlar
```bash
# Bağımlılıkları yükle
flutter pub get

# Drift kod üretimi çalıştır (veritabanı değiştiğinde)
dart run build_runner build --delete-conflicting-outputs

# Uygulamayı çalıştır
flutter run

# Analiz (sıfır uyarı hedefi)
flutter analyze

# Testler
flutter test

# Format
dart format .
```

### Font Kurulumu
`assets/fonts/` dizinine şu dosyaları ekle (Google Fonts, OFL lisanslı):
- **Fraunces:** `Fraunces-Regular.ttf`, `Fraunces-Medium.ttf`, `Fraunces-SemiBold.ttf`, `Fraunces-Bold.ttf`, `Fraunces-Italic.ttf`
- **Manrope:** `Manrope-Regular.ttf`, `Manrope-Medium.ttf`, `Manrope-SemiBold.ttf`, `Manrope-Bold.ttf`, `Manrope-ExtraBold.ttf`

İndirme: https://fonts.google.com/specimen/Fraunces · https://fonts.google.com/specimen/Manrope

---

## Paket Listesi ve Gerekçeler

| Paket | Sürüm | Gerekçe |
|-------|-------|---------|
| `flutter_riverpod` | ^2.5.1 | State management — tek araç, tutarlı |
| `riverpod_annotation` | ^2.3.5 | Kod üretimi ile provider |
| `go_router` | ^14.2.7 | Navigasyon — StatefulShellRoute (5 sekme) |
| `drift` | ^2.18.0 | Yerel SQLite — tip güvenli ORM |
| `sqlite3_flutter_libs` | ^0.5.24 | Native SQLite |
| `path_provider` | ^2.1.4 | DB dosya yolu |
| `shared_preferences` | ^2.3.2 | Basit ayarlar (onboardingDone, themeId vb.) |
| `flutter_local_notifications` | ^17.2.2 | Yerel bildirimler |
| `timezone` | ^0.9.4 | Saat dilimi doğru bildirim zamanlaması |
| `intl` | ^0.19.0 | Tarih/saat formatı, çoklu dil |
| `share_plus` | ^10.0.2 | Paylaşım ve dışa aktarma |
| `local_auth` | ^2.3.0 | Biyometrik / PIN kilidi |
| `phosphor_flutter` | ^2.1.0 | Tek ikon ailesi (duotone/light) |
| `flutter_svg` | ^2.0.10 | SVG ikon ve vektör |
| `flutter_animate` | ^4.5.0 | Animasyon yardımcısı |
| `equatable` | ^2.0.5 | Değer eşitliği |
| `uuid` | ^4.4.2 | Benzersiz ID üretimi |
| `collection` | ^1.18.0 | Liste/koleksiyon yardımcıları |
| `home_widget` *(Aşama 5B)* | — | Android AppWidget |
| `purchases_flutter` *(Aşama 7)* | — | RevenueCat abonelik |

---

## Mimari Özeti

```
lib/
├── core/
│   ├── theme/          # CosmicTokens, AppThemes (5 tema), AppTextStyles
│   ├── entitlement/    # EntitlementService, AppFeature, tier kapısı
│   ├── router/         # go_router yapılandırması
│   ├── limits.dart     # Tüm sayısal limitler (tek kaynak)
│   └── utils/
├── features/           # Özellik bazlı klasörler
│   ├── onboarding/     # Rıza + 3 adım (Aşama 2)
│   ├── home/           # Ana Sayfa (Aşama 3)
│   ├── journal/        # Günlük — Bugün/Niyetler/Yazılar/Favoriler (Aşama 3)
│   ├── guide/          # Rehber — AI sohbet (Aşama 3 mock, 6 gerçek)
│   ├── discover/       # Keşfet — Uyumluluk/Taş/Hayvan/Ay (Aşama 4)
│   ├── cat/            # Ruh Kedisi (Aşama 5)
│   └── profile/        # Profil ve ayarlar (Aşama 3)
├── domain/
│   ├── models/         # Enum'lar, value object'ler
│   ├── astrology/      # AstrologyEngine — deterministik hesaplama
│   └── services/       # AIContentService arayüzü
├── data/
│   ├── db/             # Drift şeması (16 tablo) + DAO'lar
│   ├── repositories/   # Repository katmanı
│   └── local_content/  # LocalContentService, MockAIService
├── platform/
│   ├── notifications/  # flutter_local_notifications adaptörü
│   ├── widget/         # home_widget adaptörü (WidgetSnapshot sözleşmesi)
│   ├── biometric/      # local_auth adaptörü
│   └── sharing/        # share_plus adaptörü
└── widgets/            # Ortak bileşen kütüphanesi
```

### Katman Kuralları
- **UI** → yalnızca Riverpod provider'larına bağlanır
- **Domain** → saf Dart, framework bağımlılığı yok, iş mantığı burada
- **Data** → Repository pattern; UI doğrudan DB'ye dokunmaz
- **Platform** → tüm platform spesifik kod burada; UI Android API'si çağırmaz

---

## Veri Modeli Özeti

**16 Drift tablosu:** UserProfile · DailyContent · Intention · JournalEntry · TimeMoment · Favorite · SavedPerson · ReminderSetting · StreakDay · RestDayUse · Badge · CatProfile · CatItemUnlock · ChatMessage · AppSettings · EntitlementCache

Detay: [`lib/data/db/tables.dart`](lib/data/db/tables.dart)

---

## Geliştirme Aşamaları

| Aşama | Kapsam | Durum |
|-------|--------|-------|
| **1** | İskelet, tema, DB şeması, router, bileşenler | 🔄 Bu aşama |
| **2** | Onboarding, rıza, burç hesabı | ⏳ Bekliyor |
| **3** | Ana Sayfa, Günlük, Rehber (mock), Profil | ⏳ Bekliyor |
| **4** | Keşfet — Uyumluluk, Taş, Hayvan, Ay | ⏳ Bekliyor |
| **5** | Ruh Kedisi | ⏳ Bekliyor |
| **5B** | Android Ana Ekran Widget'ı | ⏳ Bekliyor |
| **6** | Gerçek AI entegrasyonu (backend proxy) | ⏳ Bekliyor |
| **7** | Premium abonelik | ⏳ Bekliyor |
| **8** | Ay burcu, yükselen, ephemeris | ⏳ Bekliyor |
| **9** | Cila, erişilebilirlik, performans | ⏳ Bekliyor |

---

## AI / Backend Kurulum (Aşama 6)

> ⚠️ **API anahtarı uygulamaya veya repoya girmez.**

Güvenli kurulum adımları (Aşama 6'da tamamlanacak):
1. Backend seç: Firebase Cloud Functions / Cloudflare Workers / Supabase Edge Functions
2. AI anahtarını yalnızca sunucu ortam değişkenine ekle
3. `RemoteAIService` → `lib/data/local_content/remote_ai_service.dart`
4. Provider'ı `aiContentServiceProvider` ile değiştir
5. Sunucuda entitlement doğrulaması ve rate limit uygula

---

## Bilinen Sınırlamalar (Aşama 1)

- Fontlar henüz `assets/fonts/` klasöründe yok → eklenene kadar sistem fontu kullanılır
- Asset görselleri henüz yok → `docs/ASSETS_TODO.md`'ye bakın
- Drift kod üretimi (`app_database.g.dart`) yapılmadıysa derleme hatası alınır → `dart run build_runner build` çalıştırın
- Onboarding gerçek akışı Aşama 2'de
- Tüm özellik ekranları iskelet (EmptyState) durumunda

---

## Test Komutları

```bash
flutter test                    # Tüm testler
flutter test test/astrology/    # Astroloji birim testleri
flutter analyze                 # Statik analiz
```

**Gerçek cihaz bildirim testi:** Aşama 3'te raporlanacak.
