# Translation Example: Technical Documentation

## English Input

```markdown
# PAY-102: Payment Gateway Integration

## 1. Context & Problem

### 1.1 Problem Statement

* **Current Behavior:** The payment service directly calls the bank endpoint 
  with no retry mechanism. When the endpoint times out, the transaction fails 
  silently without logging.
* **Impact:** 15% of transactions fail during peak hours due to timeout issues.
* **Root Cause:** No circuit breaker or retry pattern implemented.

### 1.2 Proposed Solution

* **Summary:** Implement a circuit breaker with retry mechanism using the 
  Strategy Pattern for different payment providers.
* **Key Decisions:** Use Resilience4j for circuit breaker. Deploy behind a 
  feature flag for gradual rollout.

## 2. Business Requirements

| ID | Requirement Description | Acceptance Criteria |
|:---|:------------------------|:--------------------|
| FR-1 | System must retry failed payments up to 3 times | All retries logged with trace ID |
| FR-2 | Circuit breaker must open after 5 consecutive failures | Alert triggered on dashboard |

## 3. Technical Implementation

### 3.1 Architectural Design

* **Design Pattern:** Strategy Pattern for payment method selection, 
  Circuit Breaker for fault tolerance
* **Component Interaction:**
    1. Controller receives payment request
    2. Service selects strategy via Factory Pattern
    3. Strategy executes with Circuit Breaker wrapper
    4. Failed calls trigger retry with exponential backoff

### 3.2 Configuration & Feature Flags

* **Feature Flags:** `ENABLE_CIRCUIT_BREAKER`: Default FALSE
* **System Parameters:** `MAX_RETRY`: 3, `TIMEOUT`: 2000ms
```

---

## Turkish Output

```markdown
# PAY-102: Ödeme Geçidi Entegrasyonu

## 1. Bağlam & Problem

### 1.1 Problem Tanımı

* **Mevcut Durum:** Ödeme servisi, banka Endpoint'ini herhangi bir Retry 
  mekanizması olmadan doğrudan çağırıyor. Endpoint Timeout olduğunda, 
  Transaction loglama yapılmadan sessizce başarısız oluyor.
* **Etki:** Timeout sorunları nedeniyle yoğun saatlerde Transaction'ların 
  %15'i başarısız oluyor.
* **Kök Neden:** Circuit Breaker veya Retry Pattern uygulanmamış.

### 1.2 Önerilen Çözüm

* **Özet:** Farklı ödeme sağlayıcıları için Strategy Pattern kullanarak 
  Retry mekanizmalı bir Circuit Breaker implementasyonu yapılacak.
* **Temel Kararlar:** Circuit Breaker için Resilience4j kullanılacak. 
  Kademeli rollout için Feature Flag arkasında Deploy edilecek.

## 2. İş Gereksinimleri

| ID | Gereksinim Açıklaması | Kabul Kriterleri |
|:---|:----------------------|:-----------------|
| FR-1 | Sistem başarısız ödemeleri 3 kez Retry etmeli | Tüm Retry'lar trace ID ile loglanmalı |
| FR-2 | 5 ardışık başarısızlıktan sonra Circuit Breaker açılmalı | Dashboard'da alert tetiklenmeli |

## 3. Teknik Implementasyon

### 3.1 Mimari Tasarım

* **Design Pattern:** Ödeme yöntemi seçimi için Strategy Pattern, 
  hata toleransı için Circuit Breaker
* **Component Etkileşimi:**
    1. Controller ödeme Request'ini alır
    2. Service, Factory Pattern ile strateji seçer
    3. Strateji, Circuit Breaker wrapper ile çalıştırılır
    4. Başarısız çağrılar üstel geri çekilme ile Retry tetikler

### 3.2 Konfigürasyon & Feature Flag'ler

* **Feature Flag'ler:** `ENABLE_CIRCUIT_BREAKER`: Default FALSE
* **Sistem Parametreleri:** `MAX_RETRY`: 3, `TIMEOUT`: 2000ms
```

---

## Key Observations

| Aspect | What Happened |
|--------|---------------|
| Technical terms | Deploy, Pipeline, Commit, Push, Retry, Timeout, Circuit Breaker, Strategy Pattern, Feature Flag — all kept in English |
| Headers | Translated to Turkish but technical terms preserved within |
| Suffix harmony | `Endpoint'ini`, `Transaction'ların`, `Retry'lar` — apostrophe used correctly |
| Code/config values | `ENABLE_CIRCUIT_BREAKER`, `MAX_RETRY`, `TIMEOUT` — untouched |
| Sentence structure | Adjusted to Turkish SOV where appropriate |
| Register | Formal tone maintained throughout |
