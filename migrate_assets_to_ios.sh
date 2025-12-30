#!/bin/bash

# Android Asset'lerini iOS Projesine Taşıma Script'i
# Kullanım: ./migrate_assets_to_ios.sh

echo "🚀 Android → iOS Asset Migration Başlıyor..."

# Renkli output için
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Paths
ANDROID_PROJECT="/Users/kullanici/StudioProjects/EhliyetUygulamasi"

# iOS proje path'ini otomatik bul veya manuel belirt
if [ -z "$1" ]; then
    # Argüman verilmediyse, yaygın lokasyonlarda ara
    POSSIBLE_PATHS=(
        "/Users/kullanici/StudioProjects/ehliyetsinavsorulari"
        "/Users/kullanici/Desktop/ehliyetsinavsorulari"
        "/Users/kullanici/Documents/ehliyetsinavsorulari"
        "$HOME/StudioProjects/ehliyetsinavsorulari"
    )
    
    IOS_PROJECT=""
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -d "$path" ]; then
            IOS_PROJECT="$path"
            break
        fi
    done
    
    if [ -z "$IOS_PROJECT" ]; then
        echo -e "${RED}❌ iOS projesi bulunamadı!${NC}"
        echo "Kullanım: ./migrate_assets_to_ios.sh /path/to/iOS/Project"
        echo "Örnek: ./migrate_assets_to_ios.sh ~/StudioProjects/ehliyetsinavsorulari"
        exit 1
    fi
else
    IOS_PROJECT="$1"
fi

# Android paths
ANDROID_ASSETS="$ANDROID_PROJECT/app/src/main/assets"
ANDROID_RES="$ANDROID_PROJECT/app/src/main/res"

# iOS paths
IOS_RESOURCES="$IOS_PROJECT/EhliyetSinavSorulari/Resources"

# iOS projesinin varlığını kontrol et
if [ ! -d "$IOS_PROJECT" ]; then
    echo -e "${RED}❌ iOS projesi bulunamadı: $IOS_PROJECT${NC}"
    echo "Lütfen iOS proje path'ini script içinde düzenleyin"
    exit 1
fi

echo -e "${BLUE}📁 Android: $ANDROID_ASSETS${NC}"
echo -e "${BLUE}📁 iOS: $IOS_RESOURCES${NC}"

# iOS Resources klasörünü oluştur (yoksa)
mkdir -p "$IOS_RESOURCES"

# ==========================================
# 1. JSON Dosyalarını Taşı (TÜM KLASÖRLER)
# ==========================================
echo -e "\n${GREEN}📦 1. JSON Dosyaları Taşınıyor...${NC}"

# Tests (Ana testler)
echo "  📄 Tests JSON..."
mkdir -p "$IOS_RESOURCES/JSON/tests"
if [ -d "$ANDROID_ASSETS/tests" ]; then
    cp -r "$ANDROID_ASSETS/tests/"* "$IOS_RESOURCES/JSON/tests/" 2>/dev/null || true
    TEST_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/tests"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $TEST_COUNT test dosyası kopyalandı"
else
    echo -e "    ${RED}⚠️  tests/ klasörü bulunamadı${NC}"
fi

# Flashcards
echo "  🎴 Flashcard JSON..."
mkdir -p "$IOS_RESOURCES/JSON/flashcards"
if [ -d "$ANDROID_ASSETS/cards" ]; then
    cp -r "$ANDROID_ASSETS/cards/"* "$IOS_RESOURCES/JSON/flashcards/" 2>/dev/null || true
    CARD_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/flashcards"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $CARD_COUNT flashcard dosyası kopyalandı"
else
    echo -e "    ${RED}⚠️  cards/ klasörü bulunamadı${NC}"
fi

# Content indexes (konuanlatimi JSON'ları)
echo "  📚 Content Index JSON..."
mkdir -p "$IOS_RESOURCES/JSON/content"
if [ -d "$ANDROID_ASSETS/konuanlatimi" ]; then
    find "$ANDROID_ASSETS/konuanlatimi" -name "*.json" -exec cp {} "$IOS_RESOURCES/JSON/content/" \; 2>/dev/null || true
    CONTENT_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/content"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $CONTENT_COUNT content index dosyası kopyalandı"
else
    echo -e "    ${RED}⚠️  konuanlatimi/ klasörü bulunamadı${NC}"
fi

# Trafik kategorisi (alt testler veya içerik)
echo "  🚦 Trafik JSON..."
mkdir -p "$IOS_RESOURCES/JSON/trafik"
if [ -d "$ANDROID_ASSETS/trafik" ]; then
    find "$ANDROID_ASSETS/trafik" -name "*.json" -exec cp {} "$IOS_RESOURCES/JSON/trafik/" \; 2>/dev/null || true
    TRAFIK_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/trafik"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $TRAFIK_COUNT trafik dosyası kopyalandı"
fi

# Motor kategorisi
echo "  🔧 Motor JSON..."
mkdir -p "$IOS_RESOURCES/JSON/motor"
if [ -d "$ANDROID_ASSETS/motor" ]; then
    find "$ANDROID_ASSETS/motor" -name "*.json" -exec cp {} "$IOS_RESOURCES/JSON/motor/" \; 2>/dev/null || true
    MOTOR_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/motor"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $MOTOR_COUNT motor dosyası kopyalandı"
fi

# İlk Yardım kategorisi
echo "  🏥 İlk Yardım JSON..."
mkdir -p "$IOS_RESOURCES/JSON/ilkyardim"
if [ -d "$ANDROID_ASSETS/ilkyardim" ]; then
    find "$ANDROID_ASSETS/ilkyardim" -name "*.json" -exec cp {} "$IOS_RESOURCES/JSON/ilkyardim/" \; 2>/dev/null || true
    ILKYARDIM_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/ilkyardim"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $ILKYARDIM_COUNT ilkyardim dosyası kopyalandı"
fi

# Trafik Adabı kategorisi
echo "  🚸 Trafik Adabı JSON..."
mkdir -p "$IOS_RESOURCES/JSON/trafikadabi"
if [ -d "$ANDROID_ASSETS/trafikadabi" ]; then
    find "$ANDROID_ASSETS/trafikadabi" -name "*.json" -exec cp {} "$IOS_RESOURCES/JSON/trafikadabi/" \; 2>/dev/null || true
    TRAFIKADABI_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/trafikadabi"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $TRAFIKADABI_COUNT trafikadabi dosyası kopyalandı"
fi

# Videolu Sorular
echo "  🎥 Videolu Sorular JSON..."
mkdir -p "$IOS_RESOURCES/JSON/videolusorular"
if [ -d "$ANDROID_ASSETS/videolusorular" ]; then
    find "$ANDROID_ASSETS/videolusorular" -name "*.json" -exec cp {} "$IOS_RESOURCES/JSON/videolusorular/" \; 2>/dev/null || true
    VIDEO_COUNT=$(ls -1 "$IOS_RESOURCES/JSON/videolusorular"/*.json 2>/dev/null | wc -l)
    echo -e "    ✅ $VIDEO_COUNT videolu soru dosyası kopyalandı"
fi

# ==========================================
# 2. HTML Dosyalarını Taşı (TÜM KLASÖRLER)
# ==========================================
echo -e "\n${GREEN}📄 2. HTML Dosyaları Taşınıyor...${NC}"

# Konu anlatımı HTML'leri
echo "  📚 Konu Anlatımı HTML..."
mkdir -p "$IOS_RESOURCES/HTML/konuanlatimi"
if [ -d "$ANDROID_ASSETS/konuanlatimi" ]; then
    find "$ANDROID_ASSETS/konuanlatimi" -name "*.html" -exec cp {} "$IOS_RESOURCES/HTML/konuanlatimi/" \; 2>/dev/null || true
    HTML_COUNT=$(ls -1 "$IOS_RESOURCES/HTML/konuanlatimi"/*.html 2>/dev/null | wc -l)
    echo -e "    ✅ $HTML_COUNT HTML dosyası kopyalandı"
fi

# Trafik HTML'leri
echo "  🚦 Trafik HTML..."
mkdir -p "$IOS_RESOURCES/HTML/trafik"
if [ -d "$ANDROID_ASSETS/trafik" ]; then
    find "$ANDROID_ASSETS/trafik" -name "*.html" -exec cp {} "$IOS_RESOURCES/HTML/trafik/" \; 2>/dev/null || true
    TRAFIK_HTML=$(ls -1 "$IOS_RESOURCES/HTML/trafik"/*.html 2>/dev/null | wc -l)
    echo -e "    ✅ $TRAFIK_HTML HTML dosyası kopyalandı"
fi

# Motor HTML'leri
echo "  🔧 Motor HTML..."
mkdir -p "$IOS_RESOURCES/HTML/motor"
if [ -d "$ANDROID_ASSETS/motor" ]; then
    find "$ANDROID_ASSETS/motor" -name "*.html" -exec cp {} "$IOS_RESOURCES/HTML/motor/" \; 2>/dev/null || true
    MOTOR_HTML=$(ls -1 "$IOS_RESOURCES/HTML/motor"/*.html 2>/dev/null | wc -l)
    echo -e "    ✅ $MOTOR_HTML HTML dosyası kopyalandı"
fi

# İlk Yardım HTML'leri
echo "  🏥 İlk Yardım HTML..."
mkdir -p "$IOS_RESOURCES/HTML/ilkyardim"
if [ -d "$ANDROID_ASSETS/ilkyardim" ]; then
    find "$ANDROID_ASSETS/ilkyardim" -name "*.html" -exec cp {} "$IOS_RESOURCES/HTML/ilkyardim/" \; 2>/dev/null || true
    ILKYARDIM_HTML=$(ls -1 "$IOS_RESOURCES/HTML/ilkyardim"/*.html 2>/dev/null | wc -l)
    echo -e "    ✅ $ILKYARDIM_HTML HTML dosyası kopyalandı"
fi

# ==========================================
# 2.5. Eğitim Görselleri (JPG/PNG)
# ==========================================
echo -e "\n${GREEN}🖼️  2.5. Eğitim Görselleri Taşınıyor...${NC}"

mkdir -p "$IOS_RESOURCES/Images/education"
if [ -d "$ANDROID_ASSETS" ]; then
    # Root'taki tüm JPG/PNG dosyalarını kopyala
    find "$ANDROID_ASSETS" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) -exec cp {} "$IOS_RESOURCES/Images/education/" \; 2>/dev/null || true
    EDU_IMAGE_COUNT=$(ls -1 "$IOS_RESOURCES/Images/education"/*.{jpg,png,jpeg} 2>/dev/null | wc -l)
    echo -e "  ✅ $EDU_IMAGE_COUNT eğitim görseli kopyalandı"
    echo -e "  ${BLUE}ℹ️  Bu görseller konu anlatımı için kullanılabilir${NC}"
fi

# ==========================================
# 3. Font Dosyalarını Taşı
# ==========================================
echo -e "\n${GREEN}🔤 3. Font Dosyaları Taşınıyor...${NC}"

mkdir -p "$IOS_RESOURCES/Fonts"
if [ -d "$ANDROID_RES/font" ]; then
    # Urbanist font'ları bul ve kopyala
    find "$ANDROID_RES/font" -name "urbanist*.ttf" -exec cp {} "$IOS_RESOURCES/Fonts/" \; 2>/dev/null || true
    find "$ANDROID_RES/font" -name "urbanist*.otf" -exec cp {} "$IOS_RESOURCES/Fonts/" \; 2>/dev/null || true
    FONT_COUNT=$(ls -1 "$IOS_RESOURCES/Fonts"/*.ttf "$IOS_RESOURCES/Fonts"/*.otf 2>/dev/null | wc -l)
    echo -e "  ✅ $FONT_COUNT font dosyası kopyalandı"
else
    echo -e "  ${RED}⚠️  font/ klasörü bulunamadı${NC}"
fi

# ==========================================
# 4. PNG/Resim Dosyalarını Listele
# ==========================================
echo -e "\n${GREEN}🖼️  4. Resim Dosyaları Analizi...${NC}"

echo -e "  ${BLUE}ℹ️  Resimler manuel olarak Assets.xcassets'e eklenmelidir${NC}"
if [ -d "$ANDROID_RES/drawable" ]; then
    echo "  📊 Tespit edilen drawable'lar:"
    find "$ANDROID_RES" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.webp" \) | while read file; do
        filename=$(basename "$file")
        echo "    - $filename"
    done | head -20
    IMAGE_COUNT=$(find "$ANDROID_RES" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.webp" \) | wc -l)
    echo -e "  📊 Toplam $IMAGE_COUNT resim dosyası bulundu"
else
    echo -e "  ${RED}⚠️  drawable/ klasörü bulunamadı${NC}"
fi

# ==========================================
# 5. Özet Rapor
# ==========================================
echo -e "\n${GREEN}✅ Migration Tamamlandı!${NC}"
echo -e "\n📊 ÖZET RAPOR:"
echo -e "${BLUE}JSON Dosyaları:${NC}"
echo -e "  📄 Tests: $TEST_COUNT dosya"
echo -e "  🎴 Flashcards: $CARD_COUNT dosya"
echo -e "  📚 Content Indexes: $CONTENT_COUNT dosya"
echo -e "  🚦 Trafik: ${TRAFIK_COUNT:-0} dosya"
echo -e "  🔧 Motor: ${MOTOR_COUNT:-0} dosya"
echo -e "  🏥 İlk Yardım: ${ILKYARDIM_COUNT:-0} dosya"
echo -e "  🚸 Trafik Adabı: ${TRAFIKADABI_COUNT:-0} dosya"
echo -e "  🎥 Videolu Sorular: ${VIDEO_COUNT:-0} dosya"

echo -e "\n${BLUE}HTML Dosyaları:${NC}"
echo -e "  📚 Konu Anlatımı: ${HTML_COUNT:-0} dosya"
echo -e "  🚦 Trafik: ${TRAFIK_HTML:-0} dosya"
echo -e "  🔧 Motor: ${MOTOR_HTML:-0} dosya"
echo -e "  🏥 İlk Yardım: ${ILKYARDIM_HTML:-0} dosya"

echo -e "\n${BLUE}Diğer:${NC}"
echo -e "  🔤 Fonts: $FONT_COUNT dosya"
echo -e "  🖼️  Eğitim Görselleri: ${EDU_IMAGE_COUNT:-0} dosya"
echo -e "  📱 Drawable'lar: $IMAGE_COUNT dosya (Assets.xcassets'e manuel eklenmeli)"

TOTAL_JSON=$((${TEST_COUNT:-0} + ${CARD_COUNT:-0} + ${CONTENT_COUNT:-0} + ${TRAFIK_COUNT:-0} + ${MOTOR_COUNT:-0} + ${ILKYARDIM_COUNT:-0} + ${TRAFIKADABI_COUNT:-0} + ${VIDEO_COUNT:-0}))
TOTAL_HTML=$((${HTML_COUNT:-0} + ${TRAFIK_HTML:-0} + ${MOTOR_HTML:-0} + ${ILKYARDIM_HTML:-0}))

echo -e "\n${GREEN}📊 GENEL TOPLAM:${NC}"
echo -e "  JSON: $TOTAL_JSON dosya"
echo -e "  HTML: $TOTAL_HTML dosya"
echo -e "  Font: $FONT_COUNT dosya"
echo -e "  Görsel: $((${EDU_IMAGE_COUNT:-0} + ${IMAGE_COUNT:-0})) dosya"

# ==========================================
# 6. Tests Index Oluştur
# ==========================================
echo -e "\n${GREEN}📝 tests-index.json oluşturuluyor...${NC}"

# Python kullanarak dinamik index oluştur
python3 - <<EOF
import json
import os

tests_dir = "$IOS_RESOURCES/JSON/tests"
tests = []

if os.path.exists(tests_dir):
    for i in range(1, 35):  # test-1.json to test-34.json
        filename = f"test-{i}"
        filepath = os.path.join(tests_dir, f"{filename}.json")
        if os.path.exists(filepath):
            tests.append({
                "id": filename,
                "fileName": filename,
                "title": f"Test {i}",
                "totalQuestions": 50,
                "category": "Genel",
                "isPremium": i > 1  # İlk test ücretsiz, diğerleri premium
            })

    index = {"tests": tests}
    
    with open(os.path.join(tests_dir, "tests-index.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=2)
    
    print(f"  ✅ tests-index.json oluşturuldu ({len(tests)} test)")
else:
    print(f"  ⚠️  Tests klasörü bulunamadı")
EOF

# ==========================================
# 7. Manuel Adımlar
# ==========================================
echo -e "\n${BLUE}📋 SONRAKI ADIMLAR (Manuel):${NC}"
echo "1. Xcode'da projeyi aç"
echo "2. Resources klasörünü projeye ekle:"
echo "   - File → Add Files to Project"
echo "   - Resources klasörünü seç"
echo "   - ✅ 'Create folder references' seç"
echo "   - ✅ Target'ı işaretle"
echo "3. Info.plist'e font'ları ekle:"
echo "   - UIAppFonts array'ine:"
for font in "$IOS_RESOURCES/Fonts"/*.ttf "$IOS_RESOURCES/Fonts"/*.otf; do
    if [ -f "$font" ]; then
        echo "     - $(basename "$font")"
    fi
done 2>/dev/null
echo "4. Resimler için Assets.xcassets'e ekle (opsiyonel)"
echo ""
echo -e "${GREEN}🎉 Hazır! Artık PROMPTS_DATA_LAYER.md'den başlayabilirsin!${NC}"
