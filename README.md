# 🚀 Turkcell Smart Allocation App

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Turkcell_logo.svg/2560px-Turkcell_logo.svg.png" alt="Turkcell Logo" width="200"/>
</p>

<p align="center">
  <strong>Akıllı Kaynak Tahsis ve Yönetim Sistemi</strong><br/>
  SwiftUI ile geliştirilmiş iOS uygulaması
</p>

---

## 📋 İçindekiler

- [Proje Hakkında](#-proje-hakkında)
- [Özellikler](#-özellikler)
- [Mimari Yapı](#-mimari-yapı)
- [Network Katmanı](#-network-katmanı-turkcellsmartallocationnetwork)
- [App Katmanı](#-app-katmanı-turkcellsmartallocationapp)
- [API Endpoints](#-api-endpoints)
- [Veri Modelleri](#-veri-modelleri-dtos)
- [Kurulum](#-kurulum)
- [Kullanım](#-kullanım)

---

## 📖 Proje Hakkında

**Turkcell Smart Allocation App**, Turkcell'in saha ekiplerinin ve kaynaklarının akıllı bir şekilde yönetilmesini sağlayan iOS uygulamasıdır. Uygulama, gelen talepleri öncelik skorlarına göre değerlendirir ve uygun kaynaklara otomatik olarak atar.

### 🎯 Amaç

- Müşteri taleplerinin etkin yönetimi
- Saha ekiplerinin optimize edilmiş atamaları
- Gerçek zamanlı kaynak kullanım takibi
- Öncelik bazlı kuyruk yönetimi

---

## ✨ Özellikler

### Dashboard
- 📊 Anlık istatistikler (bekleyen talepler, aktif atamalar, tamamlanan işler)
- 🤖 Otomasyon durumu göstergesi
- 📍 Şehir bazlı kaynak kullanım oranları
- 🔴 Öncelik kuyruğu (kritik talepler)
- 🔗 Son atamalar listesi

### Talep Yönetimi
- 📋 Tüm taleplerin listelenmesi
- 🔍 Status ve urgency bazlı filtreleme
- ⚡ Öncelik skoru hesaplaması
- ⏱️ Bekleme süresi takibi

### Kaynak Yönetimi
- 👥 Ekip listesi ve durumları
- 🏙️ Şehir bazlı filtreleme
- 📈 Kullanım oranı (utilization) gösterimi
- 🔄 Aktif atama detayları

### Atama Yönetimi
- 🔗 Tüm atamaların görüntülenmesi
- ✅ Tamamlanan/Aktif filtresi
- 📊 Öncelik skoru ve timeline

---

## 🏗️ Mimari Yapı

Proje, **Clean Architecture** prensiplerine uygun olarak tasarlanmıştır ve iki ana modülden oluşur:

```
TurkcellSmartAllocationApp/
├── TurkcellSmartAllocationApp/     # 📱 iOS App Modülü
│   ├── View/                       # SwiftUI View'ları
│   ├── Components/                 # Yeniden kullanılabilir UI bileşenleri
│   ├── Utils/                      # Yardımcı araçlar
│   └── Assets.xcassets/            # Görsel varlıklar
│
├── TurkcellSmartAllocationNetwork/ # 🌐 Network Modülü
│   ├── Controllers/                # API Controller'ları
│   ├── Services/                   # Business Logic Service'leri
│   ├── DTOs/                       # Data Transfer Objects
│   └── Core/                       # Endpoint ve Error handling
│
├── TurkcellSmartAllocationAppTests/        # 🧪 Unit Testler
└── TurkcellSmartAllocationAppUITests/      # 🧪 UI Testler
```

### Katman Diyagramı

```
┌─────────────────────────────────────────────────────────┐
│                    📱 View Layer                         │
│  (DashboardView, PendingRequestView, ResourcesView...)  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  🔧 Service Layer                        │
│  (DashboardService, RequestService, AllocationService)  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                 📡 Controller Layer                      │
│  (DashboardController, RequestController, ...)          │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   🌐 Network Layer                       │
│  (EndpointURLHandler, ErrorHandler, URLSession)         │
└─────────────────────────────────────────────────────────┘
```

---

## 🌐 Network Katmanı (TurkcellSmartAllocationNetwork)

Network katmanı, backend API ile iletişimi yönetir. Protocol-oriented programming kullanılarak test edilebilir bir yapı oluşturulmuştur.

### 📁 Klasör Yapısı

```
TurkcellSmartAllocationNetwork/
├── Controllers/
│   ├── DashboardController.swift    # Dashboard API çağrıları
│   ├── RequestController.swift      # Request API çağrıları
│   ├── ResourceController.swift     # Resource API çağrıları
│   └── AllocationController.swift   # Allocation API çağrıları
│
├── Services/
│   ├── DashboardService.swift       # Dashboard business logic
│   ├── RequestService.swift         # Request business logic
│   ├── ResourceService.swift        # Resource business logic
│   └── AllocationService.swift      # Allocation business logic
│
├── DTOs/
│   ├── DashboardSummaryDto.swift    # Dashboard veri modelleri
│   ├── RequestDto.swift             # Request veri modelleri
│   ├── ResourceDto.swift            # Resource veri modelleri
│   ├── AllocationDto.swift          # Allocation veri modelleri
│   └── ApiErrorDto.swift            # API hata modeli
│
└── Core/
    ├── EndpointURLHandler.swift     # URL yapılandırması
    └── ErrorHandler.swift           # Hata yönetimi
```

### 🔌 EndpointURLHandler

Tüm API endpoint'lerini merkezi olarak yöneten enum yapısı:

```swift
public enum EndpointURLHandler {
    static let baseUrl = URL(string: "http://localhost:3001/api")
    
    // Request Endpoints
    case requests
    case requestDetail(id: String)
    case userRequests(userId: String)
    
    // Resource Endpoints
    case resources
    case resourcesFiltered(city: String?, status: String?)
    case resourceDetail(id: String)
    
    // Allocation Endpoints
    case allocations
    case allocationsFiltered(status: String?)
    case allocationDetail(id: String)
    
    // Dashboard Endpoints
    case dashboardSummary
}
```

### 🛡️ Error Handling

`AppError` enum'u ile kapsamlı hata yönetimi:

| Hata Tipi | Açıklama |
|-----------|----------|
| `networkNoInternet` | İnternet bağlantısı yok |
| `networkTimeout` | İstek zaman aşımına uğradı |
| `cancelled` | İstek iptal edildi |
| `server(status:message:)` | Sunucu hatası (HTTP status code ile) |
| `decoding` | JSON parsing hatası |
| `invalidResponse` | Geçersiz response |
| `unknown` | Bilinmeyen hata |

### 📡 Controller Yapısı

Her controller, ilgili API endpoint'i ile iletişim kurar:

```swift
protocol DashboardControllerProtocol {
    func getSummary(from url: URL) async throws -> DashboardSummaryDto
}

final class DashboardController: DashboardControllerProtocol {
    func getSummary(from url: URL) async throws -> DashboardSummaryDto {
        // URLSession ile API çağrısı
        // ISO8601 tarih formatı desteği
        // Detaylı konsol loglaması
    }
}
```

### 🔧 Service Yapısı

Service'ler, controller'ları kullanarak business logic uygular:

```swift
protocol DashboardServiceProtocol {
    func fetchSummary() async throws -> DashboardSummaryDto
}

final class DashboardService: DashboardServiceProtocol {
    private let controller: DashboardControllerProtocol
    
    func fetchSummary() async throws -> DashboardSummaryDto {
        let url = EndpointURLHandler.dashboardSummary.url
        let summary = try await controller.getSummary(from: url)
        printSummary(summary)  // Konsola detaylı log
        return summary
    }
}
```

### 🔄 Dependency Injection

Tüm service ve controller'lar protocol tabanlı olup, test için mock injection destekler:

```swift
// Production kullanımı
let service = DashboardService()

// Test kullanımı (mock controller ile)
let mockController = MockDashboardController()
let testService = DashboardService(controller: mockController)
```

---

## 📱 App Katmanı (TurkcellSmartAllocationApp)

SwiftUI ile geliştirilmiş kullanıcı arayüzü katmanı.

### 📁 Klasör Yapısı

```
TurkcellSmartAllocationApp/
├── TurkcellSmartAllocationAppApp.swift     # App entry point
│
├── View/
│   ├── MainTabView.swift                   # Ana tab navigation
│   ├── DashboardView.swift                 # Dashboard ekranı
│   ├── PendingRequestView.swift            # Talepler ekranı
│   ├── ResourcesView.swift                 # Kaynaklar ekranı
│   └── ActiveAllocationView.swift          # Atamalar ekranı
│
├── Components/
│   ├── CardViews.swift                     # Kart bileşenleri
│   └── SmallComponents.swift               # Küçük UI bileşenleri
│
└── Utils/
    └── MockData.swift                      # Mock veriler
```

### 📱 View'lar

#### 1️⃣ MainTabView
Ana navigasyon yapısını içerir:
- Dashboard (📊)
- Talepler (📋)
- Kaynaklar (👥)
- Atamalar (🔗)

#### 2️⃣ DashboardView
Ana dashboard ekranı, şunları görüntüler:
- **Header**: Turkcell Smart Allocation başlığı ve otomasyon durumu
- **Stats Cards**: Bekleyen talep, aktif atama, bugün tamamlanan sayıları
- **Resource Utilization**: Kaynak kullanım oranları (yatay scroll)
- **Priority Queue**: Öncelik kuyruğundaki kritik talepler
- **Recent Allocations**: Son yapılan atamalar

```swift
struct DashboardView: View {
    @State private var summary: DashboardSummaryDto?
    private let dashboardService = DashboardService()
    
    var body: some View {
        ScrollView {
            // Stats, Utilization, Priority Queue, Recent Allocations
        }
        .task { await fetchDashboard() }
        .refreshable { await fetchDashboard() }
    }
}
```

#### 3️⃣ PendingRequestView
Talep listesi ekranı:
- **Filtreler**: Status (Tümü, Bekleyen, Atandı, Tamamlandı)
- **Urgency Filtresi**: Tümü, Yüksek, Orta, Düşük
- **İstatistikler**: Toplam, bekleyen ve kritik talep sayıları
- **Talep Kartları**: Kullanıcı bilgisi, servis, öncelik skoru, bekleme süresi

#### 4️⃣ ResourcesView
Kaynak yönetimi ekranı:
- **Şehir Filtresi**: Tab bar ile şehir seçimi
- **İstatistikler**: Toplam, aktif ve müsait ekip sayıları
- **Kaynak Kartları**: Kapasite, şehir, kullanım oranı, aktif atamalar

#### 5️⃣ ActiveAllocationsView
Atama listesi ekranı:
- **Durum Filtresi**: Tümü, Atandı, Tamamlandı
- **İstatistikler**: Toplam, atandı ve tamamlandı sayıları
- **Atama Kartları**: Ekip, lokasyon, servis tipi, urgency, timestamp

### 🎨 Component'ler

#### SummaryMetricCard
İstatistik gösterim kartı:
```swift
SummaryMetricCard(title: "Bekleyen Talep", value: 15, valueColor: .blue)
```

#### MetricBox
Detay metrik kutusu (progress bar veya ikon ile):
```swift
MetricBox(title: "Öncelik Skoru", value: "85/100", showProgress: true, progressValue: 85)
```

#### IconLabel
İkon ve metin birleşimi:
```swift
IconLabel(iconName: "network", text: "Fiber Internet")
```

---

## 🔗 API Endpoints

Backend API'ye yapılan tüm istekler:

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/api/dashboard/summary` | GET | Dashboard özet verileri |
| `/api/requests` | GET | Tüm talepler |
| `/api/requests/:id` | GET | Talep detayı |
| `/api/requests?userId=:userId` | GET | Kullanıcı talepleri |
| `/api/resources` | GET | Tüm kaynaklar |
| `/api/resources?city=:city` | GET | Şehre göre kaynaklar |
| `/api/resources?status=:status` | GET | Duruma göre kaynaklar |
| `/api/resources/:id` | GET | Kaynak detayı |
| `/api/allocations` | GET | Tüm atamalar |
| `/api/allocations?status=:status` | GET | Duruma göre atamalar |
| `/api/allocations/:id` | GET | Atama detayı |

---

## 📦 Veri Modelleri (DTOs)

### DashboardSummaryDto
```swift
struct DashboardSummaryDto: Decodable {
    let stats: DashboardStatsDto           // İstatistikler
    let automationStatus: AutomationStatusDto // Otomasyon durumu
    let resourceUtilization: [ResourceUtilizationDto] // Kaynak kullanımı
    let resourcesByCity: [String: CityResourceDto]    // Şehir bazlı kaynaklar
    let recentAllocations: [RecentAllocationDto]      // Son atamalar
    let recentLogs: [RecentLogDto]                    // Son loglar
    let priorityQueue: [PriorityQueueItemDto]         // Öncelik kuyruğu
    let breakdown: BreakdownDto                       // Dağılım verileri
}
```

### RequestDto
```swift
struct RequestDto: Decodable {
    let id: String
    let userId: String
    let service: String          // Fiber, Mobile, TV, vb.
    let requestType: String      // INSTALLATION, REPAIR, vb.
    let urgency: String          // HIGH, MEDIUM, LOW
    let status: String           // PENDING, ASSIGNED, COMPLETED
    let createdAt: Date
    let user: UserDto
    let allocation: AllocationDto?
    let priorityScore: Int       // 0-100 arası öncelik skoru
}
```

### ResourceFullDto
```swift
struct ResourceFullDto: Decodable {
    let id: String
    let resourceType: String
    let capacity: Int
    let city: String
    let status: ResourceStatus   // AVAILABLE, BUSY
    let allocations: [ResourceAllocationDto]
    let activeAllocations: Int
    let utilization: Int         // Kullanım yüzdesi
}
```

### AllocationFullDto
```swift
struct AllocationFullDto: Decodable {
    let id: String
    let requestId: String
    let resourceId: String
    let priorityScore: Int
    let status: AllocationStatus  // ASSIGNED, COMPLETED
    let timestamp: Date
    let expectedCompletionAt: Date?
    let completedAt: Date?
    let request: AllocationRequestDto
    let resource: AllocationResourceDto
}
```

### Enum'lar

```swift
enum AllocationStatus: String, Decodable {
    case assigned = "ASSIGNED"
    case completed = "COMPLETED"
}

enum ResourceStatus: String, Decodable {
    case available = "AVAILABLE"
    case busy = "BUSY"
}
```

---

## ⚙️ Kurulum

### Gereksinimler
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Backend API (localhost:3001)

### Adımlar

1. **Projeyi klonlayın:**
```bash
git clone https://github.com/turkcell/smart-allocation-app.git
cd TurkcellSmartAllocationApp
```

2. **Xcode ile açın:**
```bash
open TurkcellSmartAllocationApp.xcodeproj
```

3. **Backend API'yi başlatın:**
```bash
# Backend klasörüne gidin ve sunucuyu başlatın
npm run dev
# veya
node server.js
```

4. **Uygulamayı çalıştırın:**
   - Xcode'da simulator seçin
   - `Cmd + R` ile çalıştırın

### 🔧 Konfigürasyon

Base URL'i değiştirmek için `EndpointURLHandler.swift` dosyasını düzenleyin:

```swift
static let baseUrl = URL(string: "http://localhost:3001/api")
// Production için:
// static let baseUrl = URL(string: "https://api.turkcell.com.tr/allocation")
```

---

## 🚀 Kullanım

### Dashboard
- Uygulama açıldığında Dashboard ekranı görüntülenir
- Pull-to-refresh ile verileri yenileyin
- Kart'lara tıklayarak ilgili sekmeye gidin

### Talepler
- Filtreleme butonlarını kullanarak talepleri filtreleyin
- Her kart talep detaylarını gösterir
- Öncelik skoruna göre sıralı listeleme

### Kaynaklar
- Şehir tab'larına tıklayarak filtreleme yapın
- Kullanım oranlarını takip edin
- Aktif atamaları görüntüleyin

### Atamalar
- Durum filtresini kullanın (Tümü/Atandı/Tamamlandı)
- Atama detaylarını inceleyin
- Timeline bilgisini görüntüleyin

---

## 📊 Konsol Logları

Network katmanı detaylı konsol logları üretir:

```
══════════════════════════════════════════════════════════════════════════════════
📊 DASHBOARD SUMMARY
══════════════════════════════════════════════════════════════════════════════════

📈 İSTATİSTİKLER:
    🕐 Bekleyen Talepler: 5
    🔵 Aktif Atamalar: 3
    ✅ Tamamlanan Atamalar: 12
    🏢 Toplam Kaynak: 8
    📅 Bugün Tamamlanan: 4
    📋 Kuyrukta Bekleyen: 2

🤖 OTOMASYON DURUMU:
    Durum: ✅ Çalışıyor
    Request Interval: 5000ms
    Allocation Interval: 3000ms
```

---

## 🧪 Test

### Unit Test Çalıştırma
```bash
xcodebuild test -scheme TurkcellSmartAllocationApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Test Çalıştırma
```bash
xcodebuild test -scheme TurkcellSmartAllocationAppUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 📝 Lisans

Bu proje Turkcell iç kullanımı için geliştirilmiştir.

---

## 👥 Katkıda Bulunanlar

- **Gökhan SAL** - iOS Developer
- **Melisa Melayim** - iOS Developer

---

<p align="center">
  <sub>Made with ❤️ for Turkcell Code Night</sub>
</p>
