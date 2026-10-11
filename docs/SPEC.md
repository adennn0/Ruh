# MASTER PROMPT v3 — RUHUN PARLIYOR
## Yapay zekâ destekli manifestasyon, günlük farkındalık ve kişisel spiritüel rehberlik uygulaması

Bu dosya **tek başına eksiksiz spesifikasyondur**. Başka bir yerde yazılı bir şeye ihtiyaç duyma. Bu belge önceki sürümlerle veya sohbet notlarıyla çelişirse **bu belge geçerlidir**.

**Çekirdek ürün güncellemesi (2026-10-10, D-20/D-21/D-22):** Saat Anı bildirimleri uygulamanın asıl amacıdır. Çift (11:11, 14:14, 22:22) ve palindrom (14:41, 12:21, 23:32) saatlerden kişiye özel seçki planlanır. Kota: ücretsiz günde **5**, premium günde **12**. Ayrıntı `docs/TIME_MOMENT_SYSTEM.md`. Bu paragraf Bölüm 4 karar 7 ve Bölüm 16’daki eski 2/8 sayısını geçersiz kılar.

---

# 0. Çalışma protokolü (önce bunu oku)

Bu bölüm, işin nasıl yürüyeceğini belirler. Amaç: kullanıcı her aşamadan sonra "şurayı düzelt, burayı düzelt" demek zorunda kalmasın; ilk seferde güzel, çalışan ve tutarlı bir ürün çıksın.

1. **Önce oku ve incele.** Bu belgeyi baştan sona oku. Proje klasörünü incele (boşsa bunu belirt).
2. **Kod yazmadan önce tek bir onay noktası.** Şunları sun ve kullanıcının onayını bekle:
   - (a) Belgede gerçekten engelleyici bir çelişki veya eksik varsa kısa liste (yoksa "yok" yaz; küçük ayrıntıları listeleme),
   - (b) mimari özeti (klasör yapısı, katmanlar, seçilen paketler),
   - (c) Aşama 1 için somut plan.
3. **Onaydan sonra kesintisiz çalış.** Aşamaları (Bölüm 24) sırayla, aralarda onay istemeden uygula. Her aşamanın sonunda tek bir rapor ver (ne yapıldı, ne test edildi, bilinen sorunlar, bir sonraki aşama).
4. **Soru politikası.** Bu belgede cevabı olan hiçbir şeyi sorma. Cevap yoksa makul bir varsayım yap, `docs/DECISIONS.md` dosyasına tek satırla yaz ve ilerle. Yalnızca gerçekten bloke edici durumlarda (ör. imzalama anahtarı, mağaza hesabı, API anahtarı gerekiyor) dur ve sor.
5. **Kapsam disiplini.** Yalnızca sıradaki aşamanın kapsamını yap. "Backlog" (Bölüm 23) ve "Yakında" işaretli özellikleri yapma; yalnızca mimariyi onları engellemeyecek şekilde kur.
6. **Dürüstlük.** Gerçekleşmeyen bir özelliği yapılmış gibi gösterme. Demo/mock olan her şeyi arayüzde ve kodda açıkça işaretle.
7. **Kalite çıtası.** Bir ekranı "bitti" demeden önce Bölüm 25'teki öz denetimi (küçük ekran, büyük yazı, açık/koyu tema, boş/hata durumu) kendin uygula. Düzeltilmesi gereken her şeyi kullanıcıya bırakmadan kendin düzelt.
8. **Her aşamada uygulama derlenebilir ve çalışır durumda kalmalı.** Aşama sonunda `flutter analyze` ve `flutter test` temiz olmalı; commit at (anlamlı mesajla).
9. **Araç bağımsızlığı.** Bu belge Claude Code, Antigravity veya başka bir AI kodlama aracıyla kullanılabilir. Aracın özel bir "plan modu" yoksa Bölüm 0 protokolünü sohbet içinde uygula (önce planı yaz, onay bekle). Terminal/emülatör komutlarını çalıştırabiliyorsan çalıştır; çalıştıramıyorsan hangi komutu çalıştırılması gerektiğini kullanıcıya açıkça yaz. **Çalıştırmadığın testi "geçti" diye raporlama.**

# 1. Rolün

Kıdemli bir ürün tasarımcısı, mobil mimar ve deneyimli Flutter geliştiricisi gibi davran. Statik mockup üretme: butonlar, formlar, navigasyon, kayıtlar, boş/hata/yükleniyor durumları gerçekten çalışmalı. Var olan kod varsa körlemesine silme; yapıyı anla. Proje boşsa temiz bir mimari kur.

# 2. Ürün özeti

**Uygulama adı:** Ruhun Parlıyor

**Fikir:** Kullanıcının manifestasyon (niyet belirleme), olumlama, günlük farkındalık ve spiritüel öz değerlendirme rutinini kişiselleştiren mobil uygulama. İçerik; kullanıcının **burcuna**, seçtiği **iletişim tonuna** ve niyetlerine göre şekillenir. Uygulama; günlük mesaj, niyet ve günlük yazma, burç uyumluluğu, doğal taş ve ruh hayvanı keşfi, ay evreleri, 11:11 "saat anı" ritüeli, nefes molası, "Işık Serisi" ve kullanıcının giydirip geliştirdiği bir **Ruh Kedisi** arkadaşından oluşur. Premium katman daha derin kişiselleştirme, daha fazla tema ve daha geniş AI rehber kullanımı sunar.

**Hedef kitle:** Türkçe konuşan, 16 yaş üstü; manifestasyon, astroloji ve farkındalık içeriğine ilgi duyan, estetiğe önem veren kullanıcılar. Ürün yetişkin, rafine ve "premium" hissettirmelidir.

**Hedef platform:** Flutter ile tek kod tabanı. **Önce Android** (telefon ekranları), **iOS sonra** (Bölüm 4, karar 16). Android'e özgü bir tercih yaparken iOS'a geçişi zorlaştırma.

**Dil:** Tüm arayüz Türkçe. Kod, sınıf adları ve teknik dokümantasyon İngilizce olabilir. Metinler yerelleştirmeye uygun (`intl`/ARB) tutulur.

**Sembolik çerçeve (çok önemli):** Burçlar, doğal taşlar, ruh hayvanı, 11:11 gibi saatler ve uyumluluk puanları **sembolik, eğlenceli ve kişisel anlam yüklenebilen** araçlardır. Bilimsel gerçek, kader, tıbbi/finansal/ilişkisel sonuç garantisi veya "evren kesinlikle sana bunu söylüyor" türü iddia olarak sunulmaz. Korku, suçluluk ve kadercilik dili yasaktır. Dil spiritüel ve şiirsel olabilir ama kullanıcının iradesini, gerçekçi adımlarını ve sorumluluğunu destekler. Uygulama profesyonel psikolojik, tıbbi, hukuki veya finansal danışmanlığın yerine geçmez. Doğal taşlar için **şifa/tedavi/sağlık iddiası yasaktır** ("iyileştirir", "hastalığa iyi gelir" vb.); yalnızca sembol ve niyet odağı olarak anlatılır.

# 3. Ürün ilkeleri

1. **Kişiselleştirme:** İçerik kullanıcının burcu, tonu ve niyetlerine göre gelir.
2. **Tutarlılık:** Tek bir design system; her ekran aynı uygulamanın parçası.
3. **Gerçek işlevsellik:** Form, seçim, kayıt, takvim, favori, ayar çalışır. Hiçbir buton yalnızca dekor değildir.
4. **Yumuşak yönlendirme:** Suçluluk, korku, baskı ve zorlayıcı mekanikler yok (Işık Serisi dahil, bkz. Bölüm 14).
5. **Şeffaflık:** AI içeriği, yerel içerik ve kullanıcı girdisi ayrıştırılabilir olmalı (`source: ai | local | demo`). API anahtarı uygulamaya gömülmez.
6. **Mahremiyet:** Doğum tarihi/saati, günlükler, niyetler ve eklenen kişilerin bilgileri hassastır. Gereksiz veri toplama. Kullanıcı görüntüleyebilir, düzenleyebilir, dışa aktarabilir ve silebilir. **Kullanıcının kendi verisi asla paywall arkasına konmaz.**
7. **Erişilebilirlik:** Yeterli kontrast, ≥48dp dokunma alanı, büyük yazı boyutuna uyum, ekran okuyucu etiketleri.
8. **Gerçekçi MVP:** Sunucu, abonelik ve AI için gerçek yapılandırma yoksa sahte çalışıyor gibi gösterme; mock/yer tutucuları açıkça işaretle.
9. **Premium adil olmalı:** Ücretsiz deneyim anlamlı ve tam hissettirmeli; kullanıcıya satın alma baskısı yapılmaz.

# 4. Verilmiş ürün kararları (sorma, uygula)

Aşağıdaki kararlar kullanıcıyla netleşmiştir veya makul varsayımlardır. Değiştirmen gerekirse `docs/DECISIONS.md`'ye gerekçeyle yaz.

| # | Karar |
|---|---|
| 1 | **Burç tabanlı kişiselleştirme MVP'nin merkezidir.** Güneş burcu doğum tarihinden deterministik hesaplanır. |
| 2 | **Ay burcu ve yükselen** doğum yeri ve gerçek ephemeris gerektirir → Aşama 8. O zamana kadar bu alanlar "Premium · Yakında" etiketli kilitli önizleme olarak görünür; değer uydurulmaz. |
| 3 | **AI, tasarımda baştan vardır ama gerçek entegrasyon Aşama 6'dadır.** Önce `AIContentService` arayüzü + yerel burca özel içerik kütüphanesi + mock sohbet. Gerçek AI güvenli bir backend proxy üzerinden bağlanır. |
| 4 | **Alt navigasyon 5 sekme:** Ana Sayfa · Günlük · **Rehber (ortadaki öne çıkan buton, AI)** · Keşfet · Profil. Niyetler, Günlük sekmesinin içinde bir alt sekmedir. |
| 5 | **Ortadaki Rehber butonu** AI mesaj/sohbet alanını açar; ekranın başlığında bir **zil/ayar simgesi** bildirim ayarlarına götürür. |
| 6 | **Premium kapısı baştan koda yazılır** (`EntitlementService`). Gerçek satın alma Aşama 7'de; o zamana kadar yalnızca **debug build'de** premium'u açıp kapatan bir geliştirici anahtarı bulunur. Release'de bu anahtar bulunmaz. |
| 7 | **Bildirimler (çekirdek):** ücretsiz kullanıcı günde en fazla **5** kişiselleştirilmiş Saat Anı; premium **12**. Saatler burç + ton + niyet + kişisel tuz ile seçilir (herkese aynı liste/metin gitmez). Ek hatırlatıcılar (niyet, akşam, günün mesajı) aynı kotadan artan slotları kullanır. Sessiz saatler herkese açık. |
| 8 | **"Premium isteklerine 3 kat daha hızlı":** AI Rehber'de bekleme süresi (cooldown) ücretsizde 30 sn, premiumda 10 sn'dir (3 kat daha kısa) ve sunucuda öncelikli hat kullanılır. Pazarlama metninde "3 kat daha hızlı yanıt" gibi ölçülmemiş bir performans iddiası kullanılmaz; "öncelikli yanıt hattı ve 3 kat daha kısa bekleme" denir. Sayılar `lib/core/limits.dart` içinde tek yerde durur. |
| 9 | **Işık Serisi** (streak) vardır ama yargılamayan biçimde tasarlanır (Bölüm 14). |
| 10 | **Temalar:** 2 ücretsiz, 3 premium (Bölüm 6.5). |
| 11 | **Doğal taş ve ruh hayvanı deterministiktir** (aynı girdi → aynı sonuç), AI'a bırakılmaz. AI yalnızca bu verilere dayalı metni kişiselleştirir (Aşama 6+). |
| 12 | **Ruh Kedisi** uygulamanın arkadaş karakteridir; giydirilebilir; AI konuşması sonraki aşamadır. |
| 13 | **Doğum yeri MVP onboarding'inde istenmez**; Profil'de isteğe bağlı eklenir (Aşama 8'de kullanılır). Şehir listesi pakete gömülür (harici geocoding API yok). |
| 14 | **İçerik kütüphanesi yereldir** (JSON asset) ve orijinal Türkçe metinden oluşur; telifli metin kopyalanmaz. |
| 15 | **Yaş:** Uygulama 16+ için tasarlanır; ilk açılışta gizlilik/KVKK aydınlatması ve açık rıza onayı vardır. |
| 16 | **Platform:** Flutter, tek kod tabanı; Android öncelikli, iOS sonra. **iOS'a hazır kod kuralı:** platforma özgü her şey (bildirim planlama ayrıntıları, widget, biyometri, paylaşım) `lib/platform/` altındaki adaptörlerin arkasında durur; UI Android API'sini doğrudan çağırmaz. `ios/` klasörü projede kalır. iOS derlemesi ve testi Mac + Xcode + Apple Developer hesabı gerektirir; bunlar şimdilik gerekmez. |
| 17 | **Ana ekran widget'ı** ürünün parçasıdır: Android için **Aşama 5B**'de yapılır (`home_widget` + yerel Android AppWidget). iOS widget'ı (WidgetKit/Swift) iOS aşamasında yapılır; bu yüzden widget veri sözleşmesi (`WidgetSnapshot`, Bölüm 13B) platformdan bağımsız tasarlanır. |
| 18 | **Geliştirme aracı:** Claude Code veya Antigravity (Claude Sonnet) olabilir; bu belge araçtan bağımsızdır (Bölüm 0, madde 9). |

# 5. Özellik haritası (ücretsiz / premium / aşama)

| Özellik | Ücretsiz | Premium | Aşama |
|---|---|---|---|
| Onboarding (doğum tarihi/saati, ton) | ✔ | ✔ | 2 |
| Kozmik kimlik (güneş burcu, element, yönetici gezegen, nitelik) | ✔ | ✔ | 2 |
| Ay burcu, yükselen, tam doğum haritası özeti | kilitli önizleme | ✔ | 8 |
| Günlük burca özel mesaj + olumlama (yerel kütüphane) | ✔ günlük 1 + 1 yenileme | Derin mesaj (ay evresi + element bağlamı), sınırsız yenileme | 3 |
| Günlük sekmesi: Bugün / Niyetler / Yazılar / Favoriler | ✔ | ✔ | 3 |
| Aktif niyet sayısı | 3 | Sınırsız | 3 |
| Günlük yazıları (günlük, rüya, şükür) | ✔ | ✔ + arama/filtre/istatistik | 3 |
| Favoriler | ✔ | ✔ | 3 |
| Işık Serisi + rozetler | ✔ | ✔ | 3 |
| Saat Anı (11:11, 16:16 vb.) + nefes molası | ✔ | ✔ | 3 |
| Bildirimler (Saat Anı çekirdek) | Günde 5 kişiselleştirilmiş özel saat | Günde 12 | 3 |
| Temalar | 2 | +3 (futuristik dahil) | 3 |
| Burç uyumluluğu | Genel skor + kısa yorum, 3 kayıtlı kişi | 4 kategorili detay yorum, sınırsız kişi | 4 |
| Doğal taşım | Güneş burcu taşı | Ay/yükselen taşları, taş ritüelleri | 4 / 8 |
| Ruh hayvanım (burç + doğum saati dilimi) | Hayvan + kısa tanım | Derin okuma, ritüel önerileri | 4 |
| Ay evreleri takvimi | ✔ | ✔ + ay bağlamlı niyet önerisi | 4 |
| Ruh Kedisi + giydirme | Temel kedi + ücretsiz kozmetikler | Ek kozmetik paketleri, aura efektleri | 5 |
| Ana ekran widget'ı (Android) | Standart widget (olumlama / günün mesajı) | Tema seçenekleri, kedi widget'ı | 5B |
| Rehber (AI sohbet, merkez buton) | Günde 5 mesaj, 30 sn bekleme | Günde 50 mesaj, 10 sn bekleme, öncelikli hat | 6 (mock: 3) |
| Gerçek abonelik | — | — | 7 |
| Ay/yükselen hesabı | — | ✔ | 8 |

Kullanıcının kendi yazdıklarına (niyet geçmişi, günlük yazıları) erişim hiçbir durumda kilitlenmez; premium yalnızca arama/filtre/istatistik gibi kolaylıklar ekler.

# 6. Görsel kimlik ve design system

## 6.1 Genel his

**Premium cosmic / spiritual / aurora / ethereal ve hafif futuristik.** Rafine, çağdaş, hafif gizemli. Çocuk oyunu, sıradan burç uygulaması veya aşırı süslü meditasyon şablonu gibi görünmez. Ana renk yönü: **royal amethyst — mor ile pembe/magenta neon, bol beyaz ve koyu kozmik tonlarla dengeli.** Turuncu/sarı hiçbir temada ana renk olmaz.

## 6.2 Renk tokenları (varsayılan "Amethyst Aurora" teması)

- Deep cosmic `#0B0615` · Dark violet `#1A0B2E`
- Royal violet `#6A00FF` · Amethyst `#8B5CFF`
- Magenta `#FF2DAA` · Pink glow `#FF4DCE` · Soft pink highlight `#FFB3F1`
- Lavender `#EAE6FF` · Pearl white `#FAF8FF` · Pure white `#FFFFFF`
- Koyu zeminde ikincil metin `#CFC7E8`
- Birincil gradient: `#6A00FF → #9D00FF → #FF2DAA`

Tüm renkleri her yerde birden kullanma. Mor-pembe gradient yalnızca birincil CTA, aktif seçim, hero obje ve birkaç odak noktasında yer alır. Widget'larda **sabit renk kullanma**; yalnızca tema tokenlarını (`ThemeExtension`) kullan.

## 6.3 Işık, 3D ve efekt

- Ana görsel odaklarda **yüksek kaliteli 3D render hissi** (hacim, yansıma, rim light, derinlik) kullanılır. Bu görseller koda çizilmez; **önceden render edilmiş asset** olarak gelir (Bölüm 6.6). Asset gelene kadar kaliteli gradient/ışık tabanlı **geçici** placeholder kullan ve `docs/ASSETS_TODO.md`'ye yaz; düz daire/emoji ile "bitmiş gibi" bırakma.
- **Onboarding Ekran 1'in ana sembolü Ouroboros'tur** (kendi kuyruğunu ısıran yılan): metalik/obsidyen-cam hissi, amethyst ve magenta yansımalar, kontrollü tek neon vurgu. Basit halka veya emoji olmaz.
- **Kozmik kimlik ekranında** düz sarı daire yok: hacimli, dokulu, ışık yayan kozmik küre + ince orbital halkalar. En parlak vurgu hero objede kalır.
- Aurora/ethereal dalgalar ölçülü kullanılır. Neon her yerde olmaz: tek ana odak + birkaç etkileşim vurgusu.
- Glassmorphism ölçülü: seçili kartlar, modal ve sheet'ler; metin okunaklı kalır. Aşırı blur/glow/yansıma yok.
- Derinlik; kontrollü gölge, yüzey katmanı ve ışıkla kurulur.
- Semboller yetişkin, karakterli, zarif. **Tek ikon ailesi:** Phosphor (`phosphor_flutter`, duotone/light, tutarlı ağırlık). 12 burç sembolü için özel, ince çizgili bir SVG seti kullan. Çocuk uygulaması ikonu gibi şişkin/sevimli ikon yok.

## 6.4 Tipografi

- Başlık: sıcak, rafine bir serif (öneri: **Fraunces** veya Cormorant Garamond). Gövde, input, buton: **Manrope** (veya Inter). En fazla iki aile.
- Fontlar pakete **gömülür** (runtime indirme yok: çevrimdışı çalışır, gizlilik). **Türkçe karakterleri (ı İ ş Ş ğ Ğ ü Ü ö Ö ç Ç) doğrula.**
- Ölçek: display 32/28 · h1 24 · h2 20 · title 17 · body 15–16 · caption 13 · label 12. **Gövde metni 15sp'nin altına inmez.**
- Uzun başlıklar TAMAMI BÜYÜK HARF olmaz; küçük üst etiketler kısa uppercase olabilir. Butonlarda okunabilir cümle düzeni; harf aralığını abartma.
- Sistem yazı tipi ölçeğini (200%'e kadar) destekle; taşma ve kırpılma olmamalı.

## 6.5 Temalar (tema sistemi)

Tema sistemi baştan kurulur: `AppTheme` + `ThemeExtension<CosmicTokens>`; tüm renk, gradient, yüzey, glow ve hero arka planı tokenlardan gelir. Tema seçimi kalıcıdır, anında uygulanır, yeniden başlatma gerektirmez. Tüm temalar AA kontrast (gövde ≥4.5:1) sağlar.

| Tema | Tür | Erişim | Karakter |
|---|---|---|---|
| **Amethyst Aurora** (varsayılan) | Koyu | Ücretsiz | Bölüm 6.2 paleti, aurora arka plan |
| **Pearl Moon** | Açık | Ücretsiz | Zemin `#FAF8FF`, yüzey `#FFFFFF`, metin `#1A0B2E`, aynı mor-magenta vurgu, lavanta kartlar |
| **Cyber Nebula** (futuristik) | Koyu | Premium | Zemin `#05030D`, yüzey `#0E0A1F`, elektrik camgöbeği `#3DF5FF` + elektrik mor `#7B5CFF` + magenta `#FF2DAA`, metin `#E9F7FF`; ince 1px gradient kenarlıklar, HUD benzeri köşe vurguları, hero'da hafif holografik parıltı, çok ince ızgara dokusu |
| **Rose Quartz Aurora** | Koyu | Premium | Zemin `#12060F`, yüzey `#1F0B1A`, gradient `#FF4DCE → #FFB3F1`, ikincil `#C77DFF` |
| **Ocean Moon** | Koyu | Premium | Zemin `#050A1A`, yüzey `#0B1530`, gradient `#5B8CFF → #8B5CFF`, ikincil turkuaz `#52E0D0` (su teması) |

Premium temalar premium olmayan kullanıcıya **önizlenebilir** (kilit simgesiyle, "Dene" ile birkaç saniyelik önizleme); kalıcı seçim için premium gerekir. Seçili tema premium biterse sessizce Amethyst Aurora'ya döner ve kullanıcıya nazik bir bilgi verilir.

## 6.6 Asset stratejisi (3D, taş, hayvan, kedi)

Gerçek 3D/illüstrasyon asset'lerini kullanıcı harici araçlarla (ör. Blender, Midjourney) üretir. Senin görevin:
- `docs/ASSETS_TODO.md` dosyasını tam dosya adı, boyut (şeffaf WebP, @1x/@2x/@3x gerekiyorsa), amaç ve **İngilizce üretim prompt'u önerisiyle** birlikte yazmak. Gerekli asset'ler: `hero/ouroboros`, `hero/cosmic_orb`, `gems/<taş>` ×12, `animals/<hayvan>` ×12, `cat/*` katmanları, tema arka planları, paylaşım kartı şablonları.
- Asset yoksa **adlandırılmış geçici placeholder** (gradient + ışık) kullanmak ve kodda `assets/…` yolunu bu dosya adlarıyla hazır tutmak; böylece asset eklenince kod değişmeden görsel yükselir.
- Asset'ler tutarlı bir ışık yönü, malzeme ve renk grading'i taşımalıdır; temaya göre renk ayarı (tint) gerekiyorsa `ColorFiltered`/shader ile yapılır.

## 6.7 Hareket ve etkileşim

- Geçişler 200–350 ms, doğal ease/spring. Seçimlerde hafif haptic. Hero/paylaşılan eleman geçişleri kullan.
- Arka plan yıldız/parçacık efekti hafif olmalı (en fazla ~60 parçacık), uygulama arka plandayken durmalı, düşük performanslı cihazda ve "hareketi azalt" ayarında kapanmalı. Hedef 60 fps.
- Tüm animasyonlar `MediaQuery.disableAnimations` ve uygulama içi "Hareketi azalt" ayarına saygı gösterir.

## 6.8 Bileşen kütüphanesi

Ortak bileşenleri bir kez yaz, her yerde kullan: renk/tipografi/spacing (4-8-12-16-20-24-32-48) / radius (12-16-24-32-pill) / elevation tokenları; buton varyantları (primary gradient, secondary, ghost, destructive) ve durumları (default, pressed, disabled, focus, loading); input stilleri (hata/yardım metni dahil); kart varyantları (düz, cam, seçili, kilitli-premium); chip; segmented control; bottom sheet; dialog; snackbar/toast; boş durum; hata durumu + retry; yükleniyor iskeleti (shimmer); ilerleme göstergesi; premium kilit rozeti. Seçili durumlar yalnızca renkle değil kenarlık + check ile de belirtilir.

# 7. Onboarding (ilk açılış)

İlk açılışta önce **kısa gizlilik/KVKK aydınlatması ve açık rıza** (doğum bilgisi kişisel veridir; cihazda saklanır; neden istenir; silinebilir; 16 yaş üstü onayı) tek ekranda gösterilir. Ardından üç ana onboarding ekranı gelir. Üstte ilerleme göstergesi (3 adım), geri butonu, tutarlı geçişler. Üç ekran aynı renk, tipografi, ışık ve kart dilini kullanır.

## Ekran 1 — Doğum bilgisi / başlangıç ritüeli

- Görsel: merkezde kaliteli 3D **Ouroboros** (Bölüm 6.3). Parlaklık kontrollü, sembol net.
- Başlık: **"İlk Adımın: Kökenin"** · Açıklama: **"Enerjini analiz edebilmemiz için doğum bilgilerine ihtiyacımız var."** Bilgilerin neden istendiği kısa ve açık yazılır.
- Alanlar (gerçek input): **doğum tarihi** (yerelleştirilmiş date picker), **doğum saati** (time picker), **"Tam saatten emin değilim"** seçeneği. İsteğe bağlı: hitap adı ("Sana nasıl hitap edelim?"; boş bırakılabilir).
- Doğrulama: gelecek tarih ve geçersiz giriş için açık hata mesajı. Saat bilinmiyorsa atlanabilir; bu durumda bazı yorumların yaklaşık olabileceği açıklanır.
- CTA: **"Yolculuğa Başla"** (tek metin, tutarlı). Tarih girilmeden ilerlenmez; saat bilinmiyor seçeneği geçişe izin verir.

## Ekran 2 — Kozmik kimlik

- Görsel: büyük 3D kozmik küre + orbital halkalar (düz sarı daire yok). Ekranın ana odağı küre; kartlar hiyerarşiyi bozmaz.
- Başlık: **"Kozmik Kimliğin"**.
- **Gerçekten hesaplanan** alanlar: güneş burcu (doğum tarihinden), element, yönetici gezegen, nitelik (öncü/sabit/değişken) ve enerji teması. Burç sınırı günlerinde (±1 gün) küçük bir not: "Burç sınır günlerinde doğum saatine göre değişebilir."
- **Henüz hesaplanamayan** alanlar (Yükselen, Ay Burcu): uydurma değer gösterilmez; "Premium · Yakında" etiketli kilitli kart olarak görünür.
- Kartlar tek grid sisteminde, aynı radius/padding/ikon stili/yazı hiyerarşisinde. Kısa kişisel özet veya olumlama alıntısı (burca özel yerel içerikten).
- CTA: **"Keşfet"**.

## Ekran 3 — Mesaj tonu

- Başlık: **"Mesaj Tonunu Seç"** · Açıklama: **"Seçtiğin ton mesajlarını şekillendirir."**
- Dört kart: **Yumuşak** (Nazik ve kucaklayıcı) · **Net & Güçlü** (Kısa ve özgüvenli) · **Spiritüel** (Derin ve sezgisel) · **Mantıklı** (Analitik ve rasyonel).
- Seçili durum kenarlık + check ile belirgin; varsayılan Spiritüel; sonradan Profil'den değiştirilebilir. Her kartta o tonda kısa bir örnek cümle gösterilir.
- CTA: **"Frekansı Ayarla"**. Tamamlanınca Ana Sayfa'ya geçilir; `onboardingDone` kalıcı kaydedilir, uygulama yeniden açıldığında onboarding tekrar gösterilmez.

# 8. Navigasyon

Alt navigasyon, 5 öğe: **Ana Sayfa · Günlük · [Rehber] · Keşfet · Profil**.
- Ortadaki **Rehber** butonu diğerlerinden büyük/öne çıkan, hafif glow'lu (ama aşırı değil), tema gradient'li yuvarlak bir butondur; erişilebilirlik etiketi "Rehber, yapay zekâ mesajları".
- Her sekme kendi gezinme yığınını korur (durum kaybolmaz). `go_router` + `StatefulShellRoute`.
- Çalışmayan sekmeye sahte ekran konmaz.

# 9. Ana Sayfa

Kalabalık dashboard değil; net hiyerarşi. Sıra:
1. **Karşılama:** kısa sıcak selamlama (isim varsa kullan, yoksa zorlama), tarih, **ay evresi çipi**, **Işık Serisi çipi** (gizlenebilir).
2. **Bugünün Sana Özel Mesajı (hero kart):** kullanıcının **burcuna ve tonuna** göre. Kısa önizleme + "Mesajın tamamını oku". Tarih, favori, kopyala, paylaş. Aynı gün mesaj sebepsiz değişmez; bir kez üretilip kaydedilir; "Yeni mesaj oluştur" açık bir aksiyondur (ücretsiz günde 1 hak). AI/yerel kullanılamıyorsa güvenli yerel içerik gösterilir (`source` ayrımı).
3. **Ruh Kedisi kartı** (kompakt) ve **bugünkü ritüel ilerlemesi** (yan yana iki kart).
4. **11:11 / Saat Anı kartı:** kısa niyet deneyimine giriş (Bölüm 12.5).
5. **Günlük olumlama:** tek kısa olumlama; kopyala/favori/paylaş. Öz-yeterliliği destekleyen dil ("İstediğim yönde küçük, tutarlı adımlar atmaya hazırım"); mutlak garanti yok.
6. **Hızlı eylemler:** Niyet oluştur · Günlük yaz · Nefes molası · Saat anı. Hepsi çalışan ekrana gider.
7. **Keşfet önizlemesi:** yatay kaydırılan 3–4 kart (Uyumluluk, Doğal Taşım, Ruh Hayvanım, Ay Takvimi).

İlerleme yalnızca gerçekten kaydedilen etkinliklerden hesaplanır; yargılamayan dil kullanılır.

# 10. Günlük sekmesi

Üstte segmented control: **Bugün · Niyetler · Yazılar · Favoriler**.

## 10.1 Bugün
Günün **burca özel** içeriği: mesaj, olumlama, günün küçük ritüeli, isteğe bağlı yansıma sorusu ("Bugün hangi küçük adım sana iyi gelir?"). Önceki günlere takvim/şerit ile erişim. Favori, kopyala, paylaş. Yükleniyor/hata+retry/boş durumları. Aynı günün içeriği kalıcıdır.
Premium: **Derin Mesaj** (ay evresi + element bağlamı; yalnızca hesaplanabilen verilere dayanır).

## 10.2 Niyetler
- Yeni niyet: başlık, açıklama, kategori (kişisel gelişim, ilişkiler, kariyer, huzur, sağlık alışkanlıkları, bolluk/üretkenlik; yargılayıcı olmayan), isteğe bağlı olumlama ve **"Bu niyet doğrultusunda bugün atabileceğin küçük adım ne?"** alanı.
- Durum: aktif / tamamlandı / arşivlendi. Düzenleme, arşivleme, silme (onaylı). Geçmişi görüntüleme.
- Ücretsiz: en fazla 3 aktif niyet (limite gelince nazik, baskısız bir premium bilgisi; arşivleyerek yer açma seçeneği de gösterilir). Premium: sınırsız.
- AI niyetten öneri üretebilir (Aşama 6) ama kullanıcının niyetini izinsiz değiştirmez; üretilen metin düzenlenebilir.

## 10.3 Yazılar
Günlük yazıları; tür seçimi: **Günlük · Rüya · Şükür** (şükür: "bugün minnettar olduğum 3 şey" hızlı formu). Tarih, başlık (isteğe bağlı), metin, ruh hali (isteğe bağlı). Liste, düzenleme, silme. Premium: arama, filtre, basit istatistikler.

## 10.4 Favoriler
Mesaj, olumlama, niyet/ritüel içerikleri; listele, aç, favoriden çıkar, kopyala/paylaş. Kaynak içerik silinirse kırık referans kalmaz.

# 11. Rehber (ortadaki buton — AI sohbet ve mesajlar)

- Başlık çubuğunda sağda **zil/ayar** simgesi → **Bildirim ayarları** (Bölüm 16'daki ekranın aynısı).
- Üstte **"Bugünkü mesajım"** hızlı kartı; altta sohbet. Hızlı çipler: "Bugünkü mesajım", "Bana bir olumlama yaz", "Niyetimi netleştir", "1 dakikalık nefes", "Burcuma göre bugün".
- Kullanıcının tonuna göre konuşur. **Burç/doğum verisi yalnızca kullanıcı kişiselleştirmeyi kabul ettiyse ve ilgiliyse** kullanılır. Niyet bağlamı için ayrı bir ayar vardır: "Rehber niyetlerimi bilsin" (varsayılan kapalı).
- Kalan hak göstergesi ("Bugün kalan: 3/5") ve bekleme sayacı; premium'da "Öncelikli hat" rozeti. Limitler `limits.dart`'tan gelir.
- Sohbet geçmişini silme/temizleme. Yanıt sırasında yükleniyor göstergesi; ağ/API hatasında anlaşılır mesaj + yeniden dene; zaman aşımında fallback.
- **AI yapılandırılmamışsa** (Aşama 3–5): açık "Geliştirme modu: örnek yanıtlar" bandı ile mock yanıt; gerçek AI gibi sunulmaz.
- **AI davranış kuralları (kodda sistem prompt'una ve testlere yansır):** duyguları küçümsemez/yargılamaz; korku, kadercilik, bağımlılık ve kesin kehanet dili yok; sağlık/para/hukuk/ruh sağlığı için uzman yerine geçmez; geleceği bildiğini söylemez; manipülatif ifadeler ("enerjini yükseltmezsen kötü şey olur", "bu işaret kesinlikle şu anlama gelir") yok. **Kullanıcı kendine zarar verme düşüncesi veya tehlikeli bir durumdan söz ederse** manifestasyon/astroloji yorumuyla geçiştirilmez; destekleyici, güvenlik odaklı yanıt verilir ve yerel acil/yardım hatlarına (ör. 112; liste config'ten, doğrulanmış) yönlendirilir. Bu tespit hem istemci tarafı basit anahtar kelime kontrolüyle hem de sunucu/prompt tarafında yapılır.

# 12. Keşfet sekmesi

Kart ızgarası: **Uyumluluk · Doğal Taşım · Ruh Hayvanım · Ay Takvimi · Saat Anı · Nefes Molası · Kedim**; "Günün Kartı" gibi backlog öğeleri gösterilmez (veya "Yakında" etiketli, dokunulamaz önizleme olarak yalnızca tek satırda).

## 12.1 Burç uyumluluğu (Aşama 4)
- İki burç seçilir: biri varsayılan olarak kullanıcının burcu; diğeri listeden **veya kayıtlı kişilerden**. Kişi eklemek için ad (takma ad olabilir) + doğum tarihi yeterli; veriler **yalnızca cihazda** saklanır. Ücretsiz 3, premium sınırsız kayıtlı kişi.
- **Deterministik sembolik skor** (aynı çift → aynı sonuç, sıralama fark etmez / simetrik):
  - Element ilişkisi: aynı element 80 · tamamlayıcı (Ateş–Hava, Toprak–Su) 88 · Ateş–Toprak 60 · Hava–Su 60 · Toprak–Hava 55 · Ateş–Su 52.
  - Nitelik düzeltmesi (öncü/sabit/değişken): öncü–öncü −3 · sabit–sabit −3 · değişken–değişken 0 · öncü–sabit +2 · sabit–değişken +3 · öncü–değişken +4.
  - Aynı burç: 78 sabit. Sonuç 40–95 arasına sıkıştırılır.
  - Etiketler: ≥85 **Yüksek akış** · 70–84 **Uyumlu ritim** · 55–69 **Öğretici denge** · <55 **Dönüştürücü bağ**. Olumsuz/korkutucu etiket yok.
- İçerik: 78 benzersiz çift için orijinal, dengeli Türkçe yorum (JSON). Ücretsiz: skor + 2–3 cümle. Premium: Aşk · Arkadaşlık · İletişim · İş birliği başlıklı detay metin (sayısal alt skor üretilmez).
- Her ekranda: "Bu puan sembolik ve eğlence amaçlıdır; ilişkilerin gerçek dinamiği iki kişinin çabasına bağlıdır."
- **Paylaşım kartı:** güzel bir görsel (kişi adları yalnızca kullanıcı izin verirse); gizli profil bilgisi eklenmez.

## 12.2 Doğal Taşım (Aşama 4, premium genişleme Aşama 8)
- Güneş burcundan **deterministik** eşleşen doğal taş (başlangıç eşlemesi; değiştirilebilir, tek yerde tutulur): Koç–Kırmızı Yaspis · Boğa–Gül Kuvars · İkizler–Akik · Yengeç–Ay Taşı · Aslan–Kaplan Gözü · Başak–Yeşil Aventurin · Terazi–Opal · Akrep–Obsidyen · Yay–Turkuaz · Oğlak–Oniks · Kova–Ametist · Balık–Akuamarin.
- Ekran: hacimli taş görseli (asset), taşın sembolik anlamı, niyet odağı olarak nasıl kullanılabileceğine dair kısa, **iddiasız** öneri ve "Bu taşı niyetime bağla" aksiyonu (niyete etiket olarak ekler).
- **Sağlık/şifa iddiası yok**; sembolik çerçeve notu var.
- Premium (Aşama 8): ay ve yükselen taşları, "doğum haritana göre taş seti". Veri hesaplanamıyorsa gösterilmez.

## 12.3 Ruh Hayvanım (Aşama 4)
- **Deterministik** üretim: 12 ana hayvan (burçtan) × 4 doğum saati dilimi (varyant). Dilimler: **Şafak** 04:00–09:59 · **Gün** 10:00–15:59 · **Akşam** 16:00–21:59 · **Gece** 22:00–03:59. Saat bilinmiyorsa "ana form" gösterilir ve nedeni açıklanır.
- Başlangıç ana hayvanları: Koç–Şahin · Boğa–Ayı · İkizler–Kelebek · Yengeç–Kaplumbağa · Aslan–Aslan · Başak–Baykuş · Terazi–Kuğu · Akrep–Yılan · Yay–At · Oğlak–Dağ Keçisi · Kova–Kuzgun · Balık–Yunus. Ad kalıbı: "Şafak Şahini", "Gece Kuzgunu"…
- Ekran: hayvan görseli (asset), ad, karakter özeti, "bugünün hayvan mesajı" (burca özel yerel içerik), paylaşım kartı. Premium: derin okuma ve ritüel önerileri.
- "Sembolik ve eğlence amaçlı" notu zorunlu.

## 12.4 Ay Takvimi (Aşama 4)
- Sinodik ay hesabı (ortalama 29,530588853 gün; referans yeni ay 2000-01-06 18:14 UTC) ile 8 evre; ay görseli, "yaklaşık" notu. Takvim görünümünde evreler; her evre için kısa niyet teması (yeni ay: niyet başlat, dolunay: farkındalık/bırakma…). Birim testleri bilinen tarihlerle doğrulanır (±1 gün tolerans).
- Ana Sayfa'daki ay evresi çipi buradan beslenir. Premium: ay evresine bağlı niyet önerisi.

## 12.5 Saat Anı (11:11 / 16:16) ve Nefes Molası (Aşama 3)
- **Saat Anı akışı:** saat vurgulanır (ör. 11:11) → "Bir an dur, nefes al" 30 saniyelik nefes animasyonu → bugün neye niyet ettiğini seç/yaz → kaydet. Kayıt: saat, tarih, niyet metni, serideki ritüel olarak sayılır.
- Kullanıcı bakılan saati manuel seçebilir (11:11, 12:12, 16:16, 22:22 + palindromlar + özel). İsteğe bağlı kısa "sayı anlamı" metni; her zaman **sembolik** çerçeve ("bazı insanlar bu saati … için bir hatırlatıcı olarak görür"); kesin mesaj/garanti yok.
- Bildirimle hatırlatıcı **çekirdek üründür** (Bölüm 16): her gün kişiye özel seçilen çift/palindrom saatlerde gelir; tıklanınca ton + burç + niyet bağlamlı tam mesaj gösterilir.
- **Nefes Molası:** 1–3 dakikalık yönlendirmeli nefes (animasyonlu daire/aurora; ritim seçimi: 4-4-4, 4-6, 5-5), titreşim isteğe bağlı, tamamlanınca seriye sayılır. Tıbbi iddia yok.

# 13. Ruh Kedisi (Aşama 5)

Kullanıcının arkadaş karakteri: şık, gizemli, zarif stilize bir kedi (çocuksu/şişkin değil; obsidyen-ametist estetiği).
- **Oluşturma:** ad (düzenlenebilir), tüy rengi (obsidyen, inci, gri, lavanta-mor…), göz rengi. Burç aurası rengi kedinin etrafında hafif ışık olarak görünür.
- **Giydirme ("Kedini Giydir"):** slotlar — şapka · gözlük · boyunluk/atkı · pelerin · kolye/aksesuar · aura/arka plan. Önizleme, "Giydir/Çıkar", kayıt. Eşyalar **Işık Serisi kilometre taşlarıyla** (3/7/14/21/49/100/365 gün veya toplam ritüel sayısı) ve rozetlerle açılır; premium'da ek kozmetik paketleri ve aura efektleri vardır. **Hiçbir eşya oyun avantajı veya baskı aracı olmaz** (yalnızca kozmetik).
- **Durumlar:** "parlıyor" ve "dinleniyor". Kedi **asla üzgün, aç, hasta veya "seni özledi/terk edildi" göstermez**; seriyi kaçıran kullanıcıyı cezalandıran hiçbir durum yoktur.
- **Etkileşim:** dokununca hafif tepki (animasyon + haptic), günün mesajını "kedi ağzından" okuma seçeneği (Aşama 6'da AI ile genişler). Hareketi azalt ayarına saygı.
- **Teknik:** katmanlı vektör/WebP (gövde, kulak, kuyruk, göz + eşya katmanları) ortak çıpa noktaları ve tek tuval (`512×512`) ile; çıpalar `assets/cat/anchors.json`'da. Rive veya hafif Flutter animasyonu. Asset'ler Bölüm 6.6'daki yöntemle gelir.
- Kedi Ana Sayfa'da kompakt kart, Keşfet'te ve Profil'de tam ekran girişe sahiptir.

# 13B. Ana ekran widget'ı (Aşama 5B — Android)

Amaç: kullanıcı uygulamayı açmadan günün olumlamasını ve mesajını görsün ("I Am" tarzı günlük görünürlük). Widget, uygulamanın en güçlü geri dönüş alışkanlığı araçlarından biridir; sade ve güzel olmalıdır.

- **Boyutlar:** küçük (2×2): kısa günlük olumlama · geniş (4×2): günün mesajı önizlemesi + ay evresi + (açıksa) Işık Serisi. Dokunma → uygulamayı ilgili içeriğe (günün mesajı) açar (deep link).
- **Teknik:** `home_widget` paketi + yerel Android AppWidget (Kotlin). Flutter tarafı veriyi paylaşılan depoya yazar; widget onu okur. Platform kodu `lib/platform/widget/` adaptörü arkasında kalır.
- **Veri sözleşmesi (platformdan bağımsız):** `WidgetSnapshot { localDate, headline, body, moonPhaseLabel?, streakCount?, themeId, accentColors, privacyMode, contentSource }`. iOS widget'ı (sonra) aynı sözleşmeyi kullanır. Uygulama; günlük içerik üretildiğinde, ton/burç/tema değiştiğinde ve gün değişiminde snapshot'ı günceller.
- **Yenileme:** gün değişiminde ve uygulama içeriği güncellediğinde yenilenir; Android'in arka plan kısıtları nedeniyle "anlık" güncelleme vaat edilmez ve Android pil kısıtlamalarına saygı gösterilir.
- **Gizlilik:** widget ana ekranda herkese görünür. **Günlük yazısı, niyet metni, doğum bilgisi ve kayıtlı kişi bilgisi asla widget'ta gösterilmez.** Ayarlarda "Widget'ta gizli mod" seçeneği: açıkken yalnızca genel, kişisel olmayan bir olumlama gösterilir. Işık Serisi yalnızca "Işık Serisini göster" açıksa görünür.
- **Tema:** widget seçili temanın renklerini kullanır; premium tema seçiliyse ve premium bittiyse varsayılana döner. Premium: tema seçenekleri ve kedi widget'ı. Ücretsiz: standart widget.
- **Durumlar:** onboarding tamamlanmadıysa "Başlamak için uygulamayı aç" yer tutucusu; veri yoksa/yüklenemezse güvenli yerel olumlama; çökme yok. Içerik `contentSource` ile ayırt edilir.
- Profil'de "Widget ekle" yönergesi (nasıl eklenir, kısa görsel/metin) bulunur.

# 14. Işık Serisi (streak) ve rozetler

Amaç teşvik; baskı değil.
- **Seriyi sayan eylemler (günde en az biri):** günlük mesajın tamamını okumak · niyet oluşturmak/güncellemek · günlük/şükür/rüya yazısı kaydetmek · nefes molasını tamamlamak · Saat Anı kaydetmek. Yalnızca gerçek eylemler sayılır; gün yerel takvim gününe göre hesaplanır (saat dilimi/yaz saati değişimine dayanıklı).
- **Dinlenme günü:** her hafta (pazartesi başlangıçlı) bir gün kaçırma seriyi **otomatik korur**; herkese ücretsizdir. Premium'a bağlı seri koruma **yok**.
- **Dil:** "Bugün ışığını yaktın.", "Yeniden başlamak her zaman mümkün." Seri bozulursa "kaybettin" denmez; toplam "Işık Günü" sayısı ve en uzun seri gösterilir, sayaç sessizce yeniden başlar.
- Kullanıcı seriyi **tamamen gizleyebilir** (Ayarlar → "Işık Serisini göster").
- **Bildirim** serinin kopma riskini asla korku diliyle bildirmez.
- **Kilometre taşları:** 3, 7, 14, 21, 49, 100, 365 gün → kutlama animasyonu (kısa), kedi eşyası ve rozet.
- **Rozetler (başlangıç seti ~12):** İlk Niyet · İlk Yazı · İlk Saat Anı · İlk Nefes · 7 Gün Işık · 21 Gün Işık · Şükür Ustası (10 şükür kaydı) · Rüya Gezgini (5 rüya kaydı) · Taş Seçildi · Ruh Hayvanı Keşfedildi · Uyumluluk Kaşifi · Temalı (ilk tema değişimi). Rozetler Profil'de gösterilir.

# 15. Profil ve ayarlar

Üstte profil başlığı (hitap adı, burç rozeti, kedi avatarı). Tüm satırlar çalışmalıdır; çalışmayan öğe "Yakında" etiketli ve dokunulamaz olur.

- **Bilgilerim:** doğum tarihi, doğum saati + bilinmiyor, doğum yeri (isteğe bağlı; Aşama 8'de kullanılır), hitap adı. Doğum verisi değişince hesaplanan profil, günlük içerik ve türevler (taş, ruh hayvanı) **yeniden hesaplanır**.
- **Kozmik Kimliğim:** Bölüm 7'deki kimlik ekranının kalıcı hâli.
- **Mesaj tonu:** dört ton.
- **Tema:** tema seçici (premium temalar kilitli önizleme ile).
- **Işık Serisi ve Rozetler.**
- **Kedim.**
- **Bildirimler** (Bölüm 16).
- **Rehber ayarları:** burç/doğum verisini kullanmasına izin · niyetlerimi bilsin · sohbet geçmişini sil.
- **Premium** (Bölüm 17).
- **Uygulama kilidi** (biyometrik/PIN; günlük ve niyetler için; `local_auth`).
- **Hareketi azalt · Titreşim · Widget'ta gizli mod · Widget ekleme yönergesi.**
- **Verilerimi dışa aktar** (JSON, `share_plus` ile dosya) · **Tüm verilerimi sil** (onaylı, geri alınamaz; veritabanı, tercihler, planlı bildirimler ve önbellek temizlenir).
- **Gizlilik ve KVKK metni · Kullanım koşulları · Hakkında/sürüm · Geri bildirim gönder.**
- Debug build'de ek "Geliştirici" bölümü (premium anahtarı, mock AI, içerik sıfırlama). Release'de yok.

# 16. Bildirimler

Hepsi isteğe bağlı ve kapatılabilir; **izin istemeden bildirim planlanmaz.** Bildirim izni, kullanıcı bildirim açan ilk eylemi yaptığında bağlamıyla birlikte istenir.
- Türler: **kişiselleştirilmiş Saat Anı** (çift + palindrom saatlerden günlük seçki; asıl ürün) · günlük niyet hatırlatıcısı · akşam kısa değerlendirmesi · (isteğe bağlı) günlük mesaj hazır bildirimi.
- **Limit:** ücretsiz günde en fazla **5**, premium en fazla **12**. Limit hem UI'da hem planlama kodunda doğrulanır. Saat Anı kotayı önce doldurur.
- **Kişiselleştirme:** seçilen saatler ve tam mesaj `localDate + burç + ton + contentSalt + aktif niyet başlıkları` ile deterministiktir. Kilit ekranı gövdesine niyet yazılmaz. Bildirime dokununca `/time-moment/open` tam metni açar (seçilen ton).
- **Özel saat tanımı:** ayna/çift = HH:HH; palindrom = HHMM palindrom (ör. 14:41). 11:11 ve 22:22 her iki sınıfa girer.
- **Sessiz saatler** herkese açık (varsayılan örnek 22:00–08:00, kullanıcı değiştirir).
- İçerik suçluluk/korku/baskı içermez. Varsayılan sıklık düşüktür.
- **Planlama stratejisi (iOS'a hazır):** Tüm bildirimleri uzun vadeli tek seferde planlama. Önümüzdeki **7 günlük kayan pencere** planla; uygulama her açıldığında, gün değişiminde ve ayar değiştiğinde pencereyi yeniden kur. (iOS aynı anda yalnızca sınırlı sayıda — yaklaşık 64 — yerel bildirim tutabilir; bu strateji Android'de de sorunsuz çalışır.) Planlama mantığı `lib/platform/notifications/` adaptöründe durur.
- Teknik: `flutter_local_notifications` + `timezone`; saat dilimi değişimi, yeniden başlatma sonrası yeniden planlama, Android 13+ bildirim izni, tam zamanlı alarm gerektiğinde kısıtlama farkındalığı (gerekirse yaklaşık zamanlı fallback). **Gerçek cihazda test edilir** ve sonuç raporlanır.
- Bildirim ayarları ekranı, Rehber başlığındaki zil simgesinden ve Profil'den **aynı ekrana** açılır.

# 17. Premium ve entitlement

- `EntitlementService`: `tier` (free/premium), `isFeatureAvailable(feature)`, `limitFor(feature)`; önbellek + süre sonu. Tüm kapılar bu servis üzerinden geçer; widget'larda `if (premium)` dağınık kontrol yok.
- Premium ekranı: ücretli özellikleri açıkça listeler (Bölüm 5), temaları, Rehber limitlerini, bildirim limitini; **fiyat, deneme, yenileme ve iptal koşulları gerçek mağaza verisinden** çekilir. Gerçek satın alma yoksa sahte "satın alındı" gösterilmez; geliştirme yer tutucusu ve açık bir not kullanılır.
- Ücretsiz kullanıcı küçük düşürülmez; temel deneyim anlamlı kalır. Kilitli kartlar nazik ("Premium ile"), baskısızdır. "Satın alma geri yükleme" butonu bulunur.
- Aşama 7'de önerilen çözüm: RevenueCat (`purchases_flutter`) veya `in_app_purchase`; seçimi gerekçeyle `DECISIONS.md`'ye yaz. Abonelik durumu sunucu tarafı AI limitleriyle eşleşmelidir (Bölüm 19).

# 18. Burca özel içerik sistemi ve astroloji katmanı

## 18.1 İçerik kütüphanesi (yerel, orijinal Türkçe)
- `assets/content/` altında JSON: günlük mesajlar, olumlamalar, ritüeller, yansıma soruları, Saat Anı metinleri, ay evresi temaları, doğal taş ve ruh hayvanı metinleri, uyumluluk metinleri.
- **MVP minimumu:** 12 burç × 4 ton × **en az 7** günlük mesaj ve 7 olumlama (≈670 giriş) + genel (burçsuz) yedek havuz. Metinler orijinal olmalı, sözleşmeli şemada olmalı (`id, sign, tone, text, tags`).
- **İçerik seçimi:** `localDate + sign + tone` ile deterministik tohumlama; aynı gün aynı içerik; "yeni mesaj" farklı bir giriş seçer; son N günde gösterilenler tekrarlanmaz.
- **İçerik lint testi:** tüm metinlerde yasaklı kalıplar (garanti/kader/korku/tıbbi iddia: "kesinlikle gerçekleşecek", "iyileştirir", "uğursuz" vb. ve ton uyumsuzluğu) otomatik taranır; uzunluk sınırları denetlenir. Test başarısızsa teslim edilmez.
- Metinler şiirsel olsa da kullanıcıya **küçük, somut bir adım** önermeli.

## 18.2 Astroloji hesaplama katmanı
- `AstrologyEngine` arayüzü: `sunSign(date)`, `element/modality/ruler`, `moonPhase(date)`, (Aşama 8) `moonSign(dateTimeUtc)`, `ascendant(dateTimeUtc, lat, lon)`.
- Güneş burcu: tarih tablosu (21 Mar–19 Nis Koç · 20 Nis–20 May Boğa · 21 May–20 Haz İkizler · 21 Haz–22 Tem Yengeç · 23 Tem–22 Ağu Aslan · 23 Ağu–22 Eyl Başak · 23 Eyl–22 Eki Terazi · 23 Eki–21 Kas Akrep · 22 Kas–21 Ara Yay · 22 Ara–19 Oca Oğlak · 20 Oca–18 Şub Kova · 19 Şub–20 Mar Balık); sınır günleri not edilir.
- **Aşama 8:** ay burcu ve yükselen için doğrulanmış bir ephemeris çözümü (ör. Swiss Ephemeris tabanlı paket veya sunucu uç noktası). Tarihsel saat dilimi/yaz saati kurallarını (Türkiye dahil) doğru ele al; en az 5 referans doğum haritasıyla karşılaştır ve sonucu testlerde sabitle. **Ay burcu için:** doğum saati yoksa ve o gün ay burç değiştiriyorsa kesin değer verme ("gün içinde değişebilir"). **Yükselen için** doğum saati + doğum yeri zorunludur; yoksa hesaplama yapılmaz.
- AI'dan burç/gezegen hesaplaması **istenmez**; AI yalnızca hazır hesaplanmış verilere dayalı metni kişiselleştirir.

# 19. AI katmanı

## 19.1 Arayüz
`AIContentService` (sağlayıcıdan bağımsız) şu işlevleri ayırır: `generateDailyMessage`, `generateAffirmation`, `generateIntentionSuggestion`, `sendChatMessage`, (sonra) `generateCatLine`. Üç uygulama: `LocalContentService` (yerel kütüphane, varsayılan), `MockAIService` (geliştirme modu, açıkça işaretli), `RemoteAIService` (backend proxy). Aktif uygulama yapılandırmadan seçilir.

## 19.2 Mimari (Aşama 6)
- **Uygulama sağlayıcı anahtarı taşımaz.** Mobil uygulama yalnızca kendi backend proxy'sine konuşur (öneri: Firebase Cloud Functions, Cloudflare Workers veya Supabase Edge Functions; seçimi `DECISIONS.md`'ye yaz). Anahtarlar yalnızca sunucu ortamında tutulur.
- İstemci kimliği: anonim oturum/imzalı cihaz belirteci. Sunucu **entitlement'ı doğrular** (premium mu?) ve hız/limit kurallarını **sunucuda** uygular (ücretsiz günde 5 mesaj/30 sn bekleme; premium günde 50/10 sn + öncelikli kuyruk). İstemci tarafı sayaçlar yalnızca arayüz içindir.
- İstek/yanıt şeması sabit ve sürümlüdür; zaman aşımı (≈20 sn), yeniden deneme (üstel geri çekilme), kota aşımı, boş yanıt ve ağ hatası için tanımlı fallback (yerel içerik + anlaşılır mesaj).
- **Model seçimi yapılandırılabilir.** Öneri: günlük içerik/olumlama için hızlı ve ekonomik bir model (ör. `claude-haiku-5-5`), Rehber sohbeti için daha güçlü bir model (ör. `claude-sonnet-5-5`). Model adları tek bir yapılandırma dosyasında durur; kod sağlayıcıya sıkı bağlanmaz.
- Günlük içerik aynı gün tekrar üretilmez (önbellek: `localDate`).
- Sunucuda içerik güvenliği: kullanıcı mesajı ve model yanıtı kısa bir güvenlik denetiminden geçer; Bölüm 11'deki kriz kuralı uygulanır.
- Loglama: günlük metinleri, niyetler ve doğum bilgileri **loglanmaz**.

## 19.3 Prompt yönergeleri
- Sistem prompt'u: ton (4 ton tanımı), dil (Türkçe), uzunluk sınırı, yasaklı kalıplar (Bölüm 18.1 lint listesiyle aynı), "geleceği bilmiyorsun, kesin kehanet yok", "somut küçük adım öner", sorumlu dil kuralları.
- **Modele giden bağlam asgari olur:** burç (kullanıcı izin verdiyse), ton ve — yalnızca ilgili ayar açıksa — seçili niyetin başlığı. Doğum tarihi/saati, tam ad ve günlük metinleri **gönderilmez**.
- Çıktı biçimi: günlük içerik için JSON (`message`, `affirmation`, `reflectionPrompt`); istemci doğrular, uzunluk/biçim sınırını uygular, geçersizse fallback'e düşer.
- Premium kullanıcılarda aynı prompt ve güvenlik kuralları geçerlidir; fark yalnızca limit, öncelik ve derinliktir.

# 20. Veri modeli ve kalıcılık

Veri uygulama kapanıp açılınca korunur. Yerel veritabanı: **Drift (SQLite)**; basit ayarlar için `shared_preferences`. Veri erişimi repository katmanı üzerinden; UI doğrudan DB'ye dokunmaz. Tarihler yerel saat dilimiyle doğru işlenir; günlük içerikte `localDate` benzersizdir. Şemayı gereksiz karmaşıklaştırma; gerçek özelliklerle eşleştir; migrasyon stratejisi kur.

- **UserProfile:** id, displayName?, birthDate?, birthTime?, birthTimeUnknown, birthPlace? (şehir kimliği/enlem-boylam/saat dilimi), preferredTone (soft/strong/spiritual/rational), createdAt, updatedAt.
- **DailyContent:** id, localDate (benzersiz), message, affirmation, reflectionPrompt?, source (ai/local/demo), contentKey (yerel kütüphane kimliği), regenCount, createdAt.
- **Intention:** id, title, description, category, status (active/completed/archived), actionStep?, affirmation?, linkedStoneId?, createdAt, updatedAt, completedAt?.
- **JournalEntry:** id, entryDate, type (journal/dream/gratitude), title?, body, mood?, createdAt, updatedAt.
- **TimeMoment (Saat Anı):** id, date, timeLabel (11:11…), intentionText?, createdAt.
- **Favorite:** id, contentType, contentId, createdAt (kaynak silinince temizlenir).
- **SavedPerson (uyumluluk):** id, nickname, birthDate, createdAt (yalnızca yerel).
- **ReminderSetting:** id, type, time, enabled, label?; global: quietHoursStart/End, updatedAt.
- **StreakDay:** localDate, activityMask; **RestDayUse:** weekStartDate, usedOn. Toplam gün, en uzun seri türetilir.
- **Badge:** id, earnedAt.
- **CatProfile:** name, furColor, eyeColor, equipped (slot→itemId), createdAt. **CatItemUnlock:** itemId, source (milestone/badge/premium), unlockedAt.
- **ChatMessage:** id, conversationId, role, content, createdAt (yerel saklanır; silinebilir).
- **AppSettings:** onboardingDone, consentAcceptedAt, themeId, reduceMotion, haptics, appLockEnabled, showStreak, aiUseBirthData, aiKnowIntentions, widgetPrivacyMode.
- **EntitlementCache:** tier, expiresAt, source.

# 21. Teknik yaklaşım (sabit, seçenek bırakma)

Flutter + Dart. Aksi belirtilmedikçe şu yığın kullanılır (başka paket gerekirse nedenini README'ye ve `DECISIONS.md`'ye yaz):
- State management: **Riverpod** (yalnızca bu; başka state aracı karıştırma).
- Navigasyon: **go_router** (`StatefulShellRoute`).
- Yerel DB: **Drift**; ayarlar: **shared_preferences**.
- Bildirim: **flutter_local_notifications** + **timezone**; tarih/yerelleştirme: **intl**.
- Paylaşım/dışa aktarma: **share_plus**; görsel paylaşım kartları için `RepaintBoundary` ile PNG.
- Uygulama kilidi: **local_auth**.
- Animasyon: Flutter yerleşik animasyonları + gerekirse **flutter_animate**; kedi/hero için gerekirse **rive** veya **lottie** (gerekçeli).
- İkonlar: **phosphor_flutter**; vektör: **flutter_svg**.
- Abonelik (Aşama 7): RevenueCat veya `in_app_purchase`.
- Ana ekran widget'ı (Aşama 5B): **home_widget** + yerel Android AppWidget (Kotlin).
- Platform adaptörleri: `lib/platform/` (bildirim, widget, biyometri, paylaşım). iOS'a geçişte yalnızca bu katman ve `ios/` yapılandırması genişler.

Mimari: UI / domain (iş mantığı, saf fonksiyonlar) / data (repository + yerel kaynak) ayrımı. İş mantığı widget'a gömülmez. Klasör düzeni özellik bazlı (`features/home`, `features/journal`, `features/discover/compat` …) + `core/` (theme, limits, entitlement, utils). Widget'lar küçük ve yeniden kullanılabilir. Renk/yazı/boşluk/radius yalnızca merkezi theme tokenlarından. Çok dilli altyapı (ARB). Hatalar için tutarlı bir `Result`/hata modeli. `.env` ve gizli değerler gitignore'da.

Kod kalitesi: `flutter format`, `flutter analyze` (sıfır uyarı hedefi), anlamlı testler. Gereksiz bağımlılık ekleme.

# 22. UX, erişilebilirlik, güvenlik ve gizlilik

- Her butonun eylemi açık; geri navigasyon tutarlı. Tarih/saat için gerçek picker. Kaydetme sonrası küçük onay (snackbar). Geri alınamaz silmelerde onay. Her ekran için **loading / error / empty / normal** durumu. Klavye alanı kapatmaz; kaydırma düzgün. Küçük telefonlarda (örn. 360×640) taşma yok, metin kırpılmaz. Büyük yazı (200%) desteklenir.
- Sistem açık/koyu tercihi: varsayılan tema Amethyst Aurora (koyu); kullanıcı tema seçimini kendisi yönetir; "Sisteme uy" seçeneği (Pearl Moon ↔ Amethyst Aurora) eklenir.
- Paylaşım içeriğine gizli profil bilgisi otomatik eklenmez.
- İzinler (bildirim, biyometri) yalnızca gerektiğinde ve bağlamıyla istenir.
- Veri silme gerçekten tüm yerel kayıtları, planlı bildirimleri ve önbelleği temizler.
- Analitik/uzak loglama eklenirse günlük metinleri, niyetler ve doğum verisi varsayılan olarak **gönderilmez**; açık rıza olmadan analitik yok.
- KVKK: aydınlatma metni, açık rıza kaydı (`consentAcceptedAt`), silme/dışa aktarma hakkı, çocuklara yönelik olmadığı bilgisi.
- Astroloji/manifestasyon bilimsel kesinlik gibi sunulmaz; sağlık, finans, hukuk, ruh sağlığı konularında garanti/kehanet yok; kullanıcının kararları kendisindedir.

# 23. Backlog (şimdi YAPMA; mimariyi engellemeyecek şekilde hazırla)

Bunlar ürünü daha çekici kılacak fikirlerdir; kullanıcı açıkça istemedikçe uygulanmaz:
1. **iOS yayını:** iOS ana ekran widget'ı (WidgetKit/Swift, aynı `WidgetSnapshot` sözleşmesi), Info.plist izin metinleri, App Store hazırlığı.
2. **Günün Kartı:** özgün çizimli, sembolik günlük kart çekimi (telifli tarot görsellerini kullanma; özgün sanat/metin).
3. **Görselleştirme panosu** (niyetlere bağlı görsel/renk panosu).
4. **Haftanın Işığı:** haftalık özet ("Wrapped" tarzı) — yalnızca gerçek kayıtlardan.
5. Ambiyans sesleri/odak sesleri (telifsiz; "frekans iyileştirir" gibi iddialar olmadan).
6. Doğum haritası görseli (Aşama 8 sonrası).
7. Uyumluluk davet bağlantısı (iki kullanıcı arasında paylaşım).
8. Ritüel paketleri (premium içerik paketleri, örn. "Yeni Ay Ritüeli").
9. Rehber'de kedinin sesiyle konuşma ve kedi AI cümleleri.
10. Tablet düzeni.
11. Ek premium temalar ve element temaları.

# 24. Geliştirme aşamaları

Her aşama derlenebilir, çalışır ve test edilebilir sonuç üretir. Aşama sonunda rapor ver, commit at, sonraki aşamaya geç (kullanıcı onayı beklemeden; yalnızca Bölüm 0'daki ilk onay şart).

**Aşama 1 — İskelet:** proje yapısı, theme tokenları ve tema sistemi (2 ücretsiz tema çalışır, diğerleri tanımlı), tipografi (gömülü fontlar), ortak bileşenler, `go_router` iskeleti (5 sekme), Drift şeması + repository'ler, `EntitlementService` (+ debug anahtarı), `limits.dart`, `AIContentService` arayüzü + `LocalContentService`, `lib/platform/` adaptör iskeleti, `docs/` dosyaları (`DECISIONS.md`, `ASSETS_TODO.md`), README.

**Aşama 2 — Onboarding ve kozmik kimlik:** rıza ekranı, 3 onboarding ekranı, doğum tarihi/saati, güneş burcu hesabı, ton seçimi, kalıcılık ve doğru yönlendirme. Testler: burç sınırları, form doğrulama.

**Aşama 3 — Çalışan çekirdek:** Ana Sayfa, Günlük (Bugün/Niyetler/Yazılar/Favoriler), burca özel yerel içerik kütüphanesi (≈670 giriş) + lint testi, Saat Anı + Nefes Molası, Işık Serisi + rozetler, Profil ve ayarlar (tüm satırlar), bildirimler (limitli, sessiz saatler), uygulama kilidi, dışa aktarma/silme, tüm temalar çalışır ve kilitli önizleme, Rehber ekranı (mock AI, açık işaretli) + bildirim ayarlarına zil bağlantısı.

**Aşama 4 — Keşfet:** Uyumluluk (+ kayıtlı kişiler + paylaşım kartı), Doğal Taşım, Ruh Hayvanım, Ay Takvimi. Testler: uyumluluk simetrisi ve skor tablosu, ruh hayvanı determinizmi, ay evresi referans tarihleri.

**Aşama 5 — Ruh Kedisi:** oluşturma, giydirme, kilometre taşı kilidi açma, animasyonlar, Ana Sayfa kartı.

**Aşama 5B — Ana ekran widget'ı (Android):** Bölüm 13B'deki widget'lar, `WidgetSnapshot` veri sözleşmesi, gizli mod, deep link, gerçek cihazda test. (Sıra gerekirse `DECISIONS.md`'ye gerekçeyle Aşama 3'ün sonuna çekilebilir.)

**Aşama 6 — AI entegrasyonu:** backend proxy, `RemoteAIService`, limit/cooldown (sunucuda), kriz kuralı, fallback'ler, gizlilik ayarları, ton ve burç kişiselleştirmesi. Gerçek anahtar yoksa mock modda bırak ve README'de kurulum adımlarını yaz.

**Aşama 7 — Premium:** gerçek abonelik altyapısı (mağaza yapılandırması varsa), paywall, geri yükleme, entitlement–sunucu eşleşmesi. Yapılandırma yoksa yer tutucu + açık not.

**Aşama 8 — Ay/yükselen ve doğum haritası:** doğum yeri seçimi, ephemeris, ay burcu, yükselen, ay/yükselen taşları, referans harita testleri.

**Aşama 9 — Cila:** erişilebilirlik, küçük/büyük ekran, performans, hata düzeltmeleri, golden testler, gerçek cihaz bildirim testi, son tasarım turu.

> Kullanıcı yalnızca belirli bir aşamayı isterse yalnızca onu yap. Mevcut kod tabanında Aşama 1–4 büyük ölçüde vardır; **silerek başlama**. Devam: `docs/CLAUDE_HANDOFF.md`. Saat Anı bildirim çekirdeğini regresyona uğratma. Sonraki asıl iş Aşama 5.

# 25. Kalite çıtası ve öz denetim (her ekran için zorunlu)

Bir ekranı bitirmeden önce **kendin** uygula, bulduğun sorunları düzelt, sonra raporla:

1. **Boyutlar:** 360×640, 393×852 ve 412×915 görünümlerinde taşma/kırpılma yok.
2. **Yazı ölçeği:** %130 ve %200'de düzen bozulmuyor.
3. **Tema:** tüm 5 temada (premium'lar debug anahtarıyla) okunaklı; kontrast ≥4.5:1; sabit renk yok.
4. **Durumlar:** loading / error+retry / empty / normal / kilitli-premium durumları var.
5. **Dokunma:** tüm dokunma alanları ≥48dp; her butonun gerçek eylemi var.
6. **Türkçe:** ı İ ş ğ ü ö ç karakterleri doğru; metinler yerelleştirme dosyasında.
7. **Tutarlılık:** yalnızca ortak bileşenler/tokenlar; aynı eleman her yerde aynı görünüm.
8. **Hareket:** animasyonlar akıcı; "hareketi azalt"a saygılı.
9. **Dil:** korku/garanti/suçluluk/şifa iddiası yok (lint testi geçer).
10. **Dürüstlük:** demo/mock/geçici içerik açıkça işaretli.

Mümkünse kritik ekranlar için golden testler ekle (en az: onboarding 3 ekran, Ana Sayfa, Günlük/Bugün, Profil, Uyumluluk sonucu) ve emülatörde çalıştırıp gözle kontrol et.

# 26. Test kabul kriterleri

Aşağıdakileri doğrulamadan işi tamamlandı olarak bildirme (kapsamdaki aşamaya göre):

1. Temiz kurulumda uygulama açılıyor ve çökmeden rıza + onboarding'i gösteriyor.
2. Doğum tarihi seçiliyor; saat girilebiliyor veya "bilmiyorum" seçilebiliyor; geçersiz girişte açık hata var.
3. Güneş burcu doğru hesaplanıyor (12 burç sınır günleri dahil testli); hesaplanamayan alanlar uydurulmuyor.
4. Seçilen ton kaydediliyor ve içeriğe/AI'a yansıyor; onboarding tamamlanınca yeniden açılışta tekrar gösterilmiyor.
5. Günlük içerik burca ve tona uygun, aynı gün kalıcı; "yeni mesaj" çalışıyor ve ücretsiz limiti uyguluyor.
6. İçerik lint testi geçiyor (yasaklı kalıp yok).
7. Niyet oluşturma/düzenleme/tamamlama/arşivleme/silme çalışıyor; ücretsiz 3 aktif niyet limiti uygulanıyor.
8. Günlük/rüya/şükür yazıları kaydediliyor ve yeniden açılıyor.
9. Favoriye ekleme/çıkarma, kopyalama ve paylaşma çalışıyor; kırık referans kalmıyor.
10. Saat Anı akışı ve Nefes Molası çalışıyor ve seriye sayılıyor.
11. Işık Serisi: yerel gün hesabı, haftalık dinlenme günü, kilometre taşı ve rozet mantığı testli; seri gizlenebiliyor; "kaybettin" dili yok.
12. Bildirimler izin olmadan planlanmıyor; ücretsiz 5/premium 12 kişiselleştirilmiş Saat Anı ve sessiz saatler çalışıyor; bildirime dokununca o ana özel mesaj açılıyor; yeniden başlatma/saat dilimi sonrası doğru planlanıyor (gerçek cihaz raporu).
13. Tema değişikliği anında ve kalıcı; premium temalar kilitli önizleme gösteriyor; premium bitince varsayılana dönülüyor.
14. Uyumluluk skoru simetrik ve tabloyla birebir tutuyor; ruh hayvanı ve doğal taş deterministik; ay evresi referans tarihlerde doğru (±1 gün).
15. Kedi oluşturma/giydirme kalıcı; eşyalar kilometre taşıyla açılıyor; kedi hiçbir durumda üzgün/terk edilmiş görünmüyor.
16. Rehber mock modda açık bandla çalışıyor; kalan hak ve bekleme sayacı doğru; AI yokken çökmeden fallback var.
17. Entitlement kapıları tek servisten geçiyor; release build'de geliştirici premium anahtarı yok.
18. Profil'deki her satır çalışıyor veya "Yakında" ve dokunulamaz; dışa aktarma ve "tüm verilerimi sil" gerçekten çalışıyor.
19. Uygulama kilidi (varsa cihazda) çalışıyor.
20. Hiçbir API anahtarı, gerçek kullanıcı verisi veya gizli bilgi repoya/loglara yazılmıyor.
21. Küçük ekranlarda ve büyük yazıda taşma yok; Türkçe karakterler doğru.
22. (Aşama 5B) Widget ana ekrana eklenebiliyor; günün içeriğini gösteriyor; gün değişiminde güncelleniyor; dokunma doğru ekrana götürüyor; gizli mod ve "seriyi göster" ayarına uyuyor; onboarding öncesi/veri yokken çökmeden yer tutucu gösteriyor; kişisel veri hiçbir durumda widget'a sızmıyor.
23. `flutter analyze` ve tüm testler çalıştırılıp sonuçları raporlanıyor (çalıştırılamayanlar açıkça belirtiliyor).

# 27. Beklenen teslimat

- Çalışan Flutter uygulaması ve temiz proje yapısı; tek design system.
- Geliştirilen ekranların listesi (aşama aşama).
- `README.md`: kurulum/çalıştırma, paket listesi ve nedenleri, mimari ve veri modeli özeti.
- `docs/DECISIONS.md` (varsayımlar), `docs/ASSETS_TODO.md` (asset listesi + üretim prompt'ları), AI/backend kurulum adımları (anahtarların güvenli yeri).
- **Çalışan / demo / henüz uygulanmayan** özellikler arasında açık ayrım.
- Test komutları ve sonuçları; gerçek cihaz bildirim testi notu.
- Bilinen sınırlamalar ve sonraki adımlar.

**Son talimat:** Önce bu belgeyi oku ve mevcut proje durumunu incele; ardından Bölüm 0'daki **tek onay noktası** için (varsa engelleyici belirsizlikler, mimari özet, Aşama 1 planı) kısa bir sunum yap ve onayı bekle. Onaydan sonra aşamaları kesintisiz uygula. Statik prototip üretme; her aşamada derlenebilir, gerçek davranışlı, görsel olarak tutarlı ve güzel bir ürün geliştir. Renk, 3D hero yaklaşımı, kontrollü neon, yetişkin sembol dili, tema sistemi ve ekranlar arası tutarlılık şartlarını koru.
