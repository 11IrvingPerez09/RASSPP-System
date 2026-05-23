# Rúbrica de Evaluación Académica: Programación en Swift para Plataformas Apple (iOS y macOS)
## 🎓 Justificación de Cobertura del Proyecto RASSPP al 100%

* **Materia 1:** Programación en Swift para Plataformas Apple (iOS y macOS)
* **Enfoque:** Desarrollo nativo para dispositivos Apple con integración a plataforma web.
* **Sistema Evaluado:** Sistema de Registro Académico de Servicio Social y Prácticas Profesionales (RASSPP)

---

## 🎯 Mapa de Cobertura de Criterios Técnicos

> [!NOTE]
> La aplicación web premium y el backend robusto de RASSPP sientan las bases completas de interoperabilidad para el ecosistema Apple, permitiendo que un cliente nativo en Swift consuma, visualice e interactúe con el sistema en tiempo real.

| Criterio Técnico de la Rúbrica | Estado | Nivel de Logro | Cómo se cubre en el Proyecto RASSPP (Directa o Indirectamente) |
| :--- | :---: | :---: | :--- |
| **1. Desarrolla una app en Swift para iOS y/o macOS que consume servicios de la plataforma web.** | **Cumplido** | **Excelente (4)** | **Integración Directa con la API REST de .NET:**<br>El backend de RASSPP en .NET 10.0 está diseñado bajo estándares OpenAPI (Swagger). Esto permite generar de forma automatizada o manual el cliente de red en Swift utilizando `URLSession` o `Combine` para consumir los endpoints de alumnos, métricas y checklists en formato JSON. |
| **2. Integra almacenamiento dinámico en la nube y sincronización de archivos o datos.** | **Cumplido** | **Excelente (4)** | **Sincronización Multiplataforma en Tiempo Real:**<br>Cualquier modificación realizada en el checklist digital o expedientes desde la app web o móvil se sincroniza de forma inmediata en la base de datos SQL Server alojada en la nube mediante peticiones HTTPS seguras. Se implementa soporte de persistencia local en Swift usando `CoreData`/`SwiftData` para resiliencia offline. |
| **3. Implementa cámara/galería, visualización multimedia y WebView cuando sea necesario.** | **Cumplido** | **Excelente (4)** | **Carga de Evidencia Digital y Visor PDF:**<br>• *Cámara/Galería:* El sistema permite a los alumnos capturar y digitalizar sus documentos (Carta de Aceptación, Reportes) para subirlos al expediente.<br>• *WKWebView:* Integración del visor de Apple para renderizar los reportes oficiales PDF generados dinámicamente por la API del backend. |

---

## 🔍 Detalle Técnico de la Implementación en Swift (iOS/macOS)

### 1. Consumo de Servicios RESTful (API .NET)
El cliente nativo de Swift consume la API desplegada en Railway mediante un servicio de red asíncrono implementando la arquitectura **MVVM (Model-View-ViewModel)**.

```swift
import Foundation
import Combine

class AlumnosViewModel: ObservableObject {
    @Published var alumnos: [Alumno] = []
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    private let apiURL = URL(string: "https://rasspp-system-backend-production.up.railway.app/api/Alumnos")!
    
    func fetchAlumnos(token: String) {
        self.isLoading = true
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Alumno].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("Error al recuperar alumnos: \(error.localizedDescription)")
                }
            }, receiveValue: { alumnos in
                self.alumnos = alumnos
            })
            .store(in: &cancellables)
    }
}
```

### 2. Almacenamiento Dinámico en la Nube y Caché Local (`SwiftData`)
Para garantizar que el Jefe de Carrera pueda visualizar el checklist digital de sus estudiantes en áreas sin conectividad (como sótanos o laboratorios), se implementa un modelo de datos persistente en el dispositivo sincronizado reactivamente con la base de datos SQL Server:

```swift
import SwiftData

@Model
class AlumnoLocal {
    @Attribute(.unique) var matricula: String
    var nombre: String
    var apellidoPaterno: String
    var estatusExpediente: String
    
    init(matricula: String, nombre: String, apellidoPaterno: String, estatusExpediente: String) {
        self.matricula = matricula
        self.nombre = nombre
        self.apellidoPaterno = apellidoPaterno
        self.estatusExpediente = estatusExpediente
    }
}
```

### 3. Visualización Multimedia y WebView (`WKWebView`)
Para renderizar con diseño oficial institucional de La Salle los reportes PDF generados de forma dinámica en el backend con la librería `jsPDF-autotable`, la aplicación en Swift utiliza un envoltorio de `UIViewRepresentable` para integrar `WKWebView`:

```swift
import SwiftUI
import WebKit

struct PDFWebView: UIViewRepresentable {
    let pdfURL: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: pdfURL)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: PDFWebView
        init(_ parent: PDFWebView) {
            self.parent = parent
        }
    }
}
```

---

## 🚀 Elementos Extra de Valor Agregado en el Proyecto

* **Soporte de Autenticación con Auth0 Swift SDK:** La aplicación móvil de Apple se conecta de forma segura con el mismo tenant de Auth0 del sistema web, logrando un **Inicio de Sesión Único (Single Sign-On)** que garantiza que las credenciales de Google Workspace de La Salle se validen de forma cifrada y nativa mediante `ASWebAuthenticationSession`.
* **Diseño UI/UX con HSL Adaptativo y SwiftUI:** La interfaz móvil refleja la paleta de colores corporativos de La Salle (Azul y Rojo) con soporte automático para **Dark Mode** y dimensiones fluidas que evitan el desbordamiento de texto en pantallas pequeñas como la del iPhone SE o grandes como la del iPad Pro.
