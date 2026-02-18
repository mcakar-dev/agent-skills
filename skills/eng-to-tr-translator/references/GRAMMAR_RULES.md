# Turkish Grammar Rules for Technical Translation

Rules for producing natural-sounding Turkish text that incorporates English technical terms.

---

## 1. Suffix Harmony on English Words

Turkish is an agglutinative language. When adding Turkish suffixes to English terms, follow these rules:

### Apostrophe Rule

Always use an apostrophe (`'`) to separate Turkish suffixes from English words:

| Correct | Incorrect |
|---------|-----------|
| Cache'ten | Cacheten |
| Deploy'dan | Deploydan |
| Endpoint'e | Endpointe |
| Pipeline'da | Pipelineda |
| Branch'e | Branche |
| Cluster'a | Clustera |

### Vowel Harmony

Apply standard Turkish vowel harmony rules to suffixes:

- **Last vowel is a/ı** → use back vowels: `-dan`, `-ta`, `-a`
- **Last vowel is e/i** → use front vowels: `-den`, `-te`, `-e`
- **Last vowel is o/u** → use back rounded: `-dan`, `-ta`, `-a`
- **Last vowel is ö/ü** → use front rounded: `-den`, `-te`, `-e`

For English words, approximate based on the pronounced vowel:

| Term | Suffix Example |
|------|---------------|
| Cache → front vowel | Cache'**ten** |
| Deploy → back vowel | Deploy'**dan** |
| Endpoint → back vowel | Endpoint'**tan** |
| Commit → back vowel | Commit'**ten** |

### Verb Formation

Use **etmek/yapmak** to form verbs from English nouns:

| English | Turkish Verb Form |
|---------|-------------------|
| Deploy | Deploy **etmek** |
| Commit | Commit **etmek** / Commit **atmak** |
| Push | Push **etmek** |
| Debug | Debug **etmek** |
| Refactor | Refactor **etmek** |
| Build | Build **almak** / Build **etmek** |

---

## 2. Sentence Structure

Turkish uses **SOV** (Subject-Object-Verb) order, unlike English **SVO**:

### Example Transformation

**English (SVO):**
```
The service sends a request to the endpoint.
```

**Turkish (SOV):**
```
Servis, Endpoint'e bir Request gönderiyor.
```

### Key Rules

- The verb goes to the **end** of the sentence
- Modifiers come **before** the noun they modify
- Adjective order follows Turkish conventions

---

## 3. Formal Register

Use the formal **siz** (you-formal) form for all professional documentation:

| Informal (sen) | Formal (siz) |
|----------------|---------------|
| Yap | Yapın / Yapınız |
| Kontrol et | Kontrol edin |
| Deploy et | Deploy edin |
| Gönder | Gönderin |
| Oluştur | Oluşturun |

---

## 4. Common Translation Patterns

### Headers

Translate headers but preserve technical terms within them:

| English Header | Turkish Header |
|---------------|----------------|
| Deployment Strategy | Deploy Stratejisi |
| Cache Configuration | Cache Konfigürasyonu |
| API Contract | API Contract |
| Test Scenarios | Test Senaryoları |
| Error Messages | Hata Mesajları |
| Definition of Done | Tamamlanma Tanımı |
| Business Requirements | İş Gereksinimleri |
| Technical Implementation | Teknik Implementasyon |
| Problem Statement | Problem Tanımı |
| Proposed Solution | Önerilen Çözüm |
| Risks | Riskler |

### Connectors and Transitions

| English | Turkish |
|---------|---------|
| Therefore | Bu nedenle |
| However | Ancak |
| In addition | Ayrıca |
| For example | Örneğin |
| As a result | Sonuç olarak |
| On the other hand | Öte yandan |
| First / Second / Third | İlk olarak / İkinci olarak / Üçüncü olarak |

---

## 5. Pluralization

Turkish uses the `-ler`/`-lar` suffix for plurals. For English terms:

| Correct | Incorrect |
|---------|-----------|
| Endpoint'ler | Endpointler |
| Container'lar | Containerlar |
| Pipeline'lar | Pipelinelar |
| Sprint'ler | Sprintler |

---

## 6. Possessive Forms

Use apostrophe before Turkish possessive suffixes:

| English | Turkish Possessive |
|---------|-------------------|
| Cache's size | Cache'in boyutu |
| Pipeline's status | Pipeline'ın durumu |
| Endpoint's response | Endpoint'in Response'u |
