# ASSETS_TODO.md — Görsel Asset Listesi ve Üretim Prompt'ları

Bu dosyadaki her asset, kod içinde yolu hazır tutulmuş bir **geçici placeholder** ile temsil edilir.
Asset eklendiğinde kod değişmeden görsel yükselir.

---

## Hero Görseller

### `assets/hero/ouroboros.webp` (@1x: 512×512 · @2x: 1024×1024, şeffaf WebP)
**Amaç:** Onboarding Ekran 1 ana sembolü (Bölüm 6.3, 7)
**Üretim prompt'u (İngilizce):**
> A highly detailed 3D render of an Ouroboros (serpent biting its own tail) with metallic obsidian-glass finish, amethyst and magenta rim lighting, subtle neon purple highlights, deep cosmic background glow. The serpent should feel ancient yet futuristic — smooth scales with micro-reflections, volumetric atmosphere. Style: premium spiritual app hero, dark background, cinematic lighting. Transparent background, PNG/WebP, 1024×1024.

---

### `assets/hero/cosmic_orb.webp` (@1x: 512×512 · @2x: 1024×1024, şeffaf WebP)
**Amaç:** Onboarding Ekran 2 ve Kozmik Kimlik ekranı (Bölüm 6.3, 7)
**Üretim prompt'u:**
> A volumetric 3D cosmic orb / planet sphere with deep purple and violet hues, emissive light from within, fine orbital rings at 15° and 45° angles, surface texture resembling nebula clouds and stardust. Amethyst-magenta gradient glow, rim light highlight at upper-left. Premium spiritual app visual, transparent background, no text, 1024×1024 WebP.

---

## Doğal Taş Görselleri (×12)
Dosya adı şeması: `assets/gems/<sign_name>.webp` (ör. `aries.webp`, `taurus.webp`)
Her biri: @1x 256×256, şeffaf WebP

| Dosya | Taş | Üretim prompt'u (kısa) |
|-------|-----|------------------------|
| `aries.webp` | Kırmızı Yaspis | 3D red jasper gemstone, polished, volumetric, transparent BG, amethyst rim light |
| `taurus.webp` | Gül Kuvars | 3D rose quartz crystal, pink translucent glow, soft lighting, transparent BG |
| `gemini.webp` | Akik | 3D agate slice, blue-grey banding, polished, cosmic glow, transparent BG |
| `cancer.webp` | Ay Taşı | 3D moonstone, adularescence sheen, blue-white glow, transparent BG |
| `leo.webp` | Kaplan Gözü | 3D tiger's eye gemstone, golden chatoyancy, warm rim light, transparent BG |
| `virgo.webp` | Yeşil Aventurin | 3D green aventurine, sparkling inclusions, soft green glow, transparent BG |
| `libra.webp` | Opal | 3D opal gemstone, rainbow play-of-color, transparent BG, elegant lighting |
| `scorpio.webp` | Obsidyen | 3D obsidian sphere, glossy black volcanic glass, amethyst reflections, transparent BG |
| `sagittarius.webp` | Turkuaz | 3D turquoise stone, matrix veining, sky-blue glow, transparent BG |
| `capricorn.webp` | Oniks | 3D black onyx sphere, deep matte-gloss finish, subtle purple rim, transparent BG |
| `aquarius.webp` | Ametist | 3D amethyst crystal cluster, violet luminescence, transparent BG |
| `pisces.webp` | Akuamarin | 3D aquamarine crystal, ocean-blue translucency, light caustics, transparent BG |

**Ortak stil notu:** Tutarlı ışık yönü (üst-sol), aynı ölçek algısı, premium render kalitesi.

---

## Ruh Hayvanı Görselleri (×12)
Dosya adı şeması: `assets/animals/<sign_name>.webp`
Her biri: @1x 512×512, şeffaf WebP

| Dosya | Hayvan | Üretim prompt'u |
|-------|--------|-----------------|
| `aries.webp` | Şahin | Stylized hawk, obsidian-amethyst aesthetic, cosmic aura, transparent BG |
| `taurus.webp` | Ayı | Stylized bear, earthy cosmic tones, powerful and serene, transparent BG |
| `gemini.webp` | Kelebek | Cosmic butterfly, wings like nebula, violet-magenta, transparent BG |
| `cancer.webp` | Kaplumbağa | Cosmic turtle, moonstone shell, soft blue glow, transparent BG |
| `leo.webp` | Aslan | Majestic cosmic lion, golden-amethyst mane, regal, transparent BG |
| `virgo.webp` | Baykuş | Mystical owl, emerald-violet feathers, wise expression, transparent BG |
| `libra.webp` | Kuğu | Elegant cosmic swan, iridescent feathers, transparent BG |
| `scorpio.webp` | Yılan | Obsidian serpent, scales with amethyst sheen, cosmic, transparent BG |
| `sagittarius.webp` | At | Cosmic horse, flowing mane of stars, transparent BG |
| `capricorn.webp` | Dağ Keçisi | Mountain ibex, crystalline horns, cosmic peaks, transparent BG |
| `aquarius.webp` | Kuzgun | Cosmic raven, electric-blue feathers, mystical, transparent BG |
| `pisces.webp` | Yunus | Cosmic dolphin, bioluminescent, ocean-nebula, transparent BG |

---

## Ruh Kedisi Katmanları
Tüm katmanlar: `assets/cat/` dizini, 512×512 WebP, ortak çıpa noktaları `anchors.json`'da

| Dosya | İçerik |
|-------|--------|
| `cat/body_obsidian.webp` | Temel gövde — obsidyen |
| `cat/body_pearl.webp` | Temel gövde — inci beyazı |
| `cat/body_grey.webp` | Temel gövde — gri |
| `cat/body_lavender.webp` | Temel gövde — lavanta-mor |
| `cat/eyes_amethyst.webp` | Göz — ametist |
| `cat/eyes_gold.webp` | Göz — altın |
| `cat/eyes_ocean.webp` | Göz — okyanus mavisi |
| `cat/slot_hat_*.webp` | Şapka slotu eşyaları |
| `cat/slot_glasses_*.webp` | Gözlük slotu |
| `cat/slot_scarf_*.webp` | Boyunluk/atkı slotu |
| `cat/slot_cape_*.webp` | Pelerin slotu |
| `cat/slot_collar_*.webp` | Kolye slotu |
| `cat/aura_*.webp` | Aura/arka plan efektleri |
| `cat/anchors.json` | Çıpa noktaları (hat, glasses, scarf, cape, collar, aura) |

**Üretim prompt'u (temel kedi):**
> Stylized cosmic cat character, sleek and elegant (not cute/chibi), obsidian-amethyst aesthetic. Sitting pose, front-facing, 512×512. Layered: body, ears, tail, eyes as separate transparent WebP layers. Style: adult spiritual app mascot, subtle glow around eyes, fine fur detail, premium illustration. Transparent background.

---

## Kişisel Eşlikçi Görseli (Aşama 5)

Durum: Hayvan türüne göre sembolik Phosphor ikon avatarı ve kozmetik yuva katmanları uygulamada çalışıyor; aşağıdaki yüksek kaliteli, tutarlı 3D hayvan asset seti henüz üretilmedi. İkon avatarı nihai illüstrasyon gibi sunulmamalı.

### `assets/companion/<animal>.webp` (@1x: 512×512 · @2x: 1024×1024, şeffaf WebP)
**Amaç:** Kullanıcının seçtiği ruh hayvanı eşlikçisinin ana ekran ve profil görünümü. En azından Bölüm 12.3'teki 12 türü kapsamalı; hayvan pozları tutarlı çıpa ve ışık yönü kullanmalı. Görsel gelene kadar uygulamadaki tema tokenlı parıltı simgesi geçici placeholder'dır; tamamlanmış hayvan illüstrasyonu gibi sunulmaz.
**Üretim prompt'u (İngilizce):**
> Create an elegant, calm, adult-oriented stylized [ANIMAL] companion for a spiritual reflection app. Distinct recognizable anatomy, gentle presence, subtle translucent amethyst and pearl rim light, refined 3D render with soft volumetric depth, centered full-body pose, transparent background, no text, no accessories baked into the base art, 1024x1024 WebP. Keep the same camera angle, scale, and lighting across all animal variants.

## Tema Arka Planları
`assets/themes/bg_<themeId>.webp` (1080×2400, WebP, düşük dosya boyutu)

| Dosya | Tema |
|-------|------|
| `bg_amethystAurora.webp` | Aurora dalgaları, koyu mor-magenta |
| `bg_pearlMoon.webp` | Açık, lavanta, ince ay ışığı |
| `bg_cyberNebula.webp` | Koyu, ince ızgara, siyon+mor |
| `bg_roseQuartzAurora.webp` | Gül tonları, yumuşak aurora |
| `bg_oceanMoon.webp` | Derin okyanus, mavi-turkuaz |

---

## Paylaşım Kartı Şablonları
`assets/themes/share_card_<themeId>.webp` (1080×1080, WebP)
Her temada: gradient arka plan + logo alanı + metin alanı + spiral/kozmik süsleme.

---

> **Not:** Asset eklenene kadar tüm bu dosya yolları kod içinde `Image.asset('assets/...')` olarak tanımlı, ancak `AssetImage` yerine gradient placeholder gösterilir.
> Tüm gerçek assetler eklendiğinde bu dosya satır satır güncellenir ve tamamlananlar ✅ işaretiyle işaretlenir.
