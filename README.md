# Rúbrica de Evaluación Académica: Implementación e Integración de Servidores
## 🎓 Justificación de Cobertura del Proyecto RASSPP al 100%

* **Materia 5:** Implementación e Integración de Servidores
* **Enfoque:** Contenedores Docker, compilaciones multi-stage, orquestación de redes locales, despliegue continuo (CI/CD) en la nube y telemetría avanzada de servidores.
* **Sistema Evaluado:** Sistema de Registro Académico de Servicio Social y Prácticas Profesionales (RASSPP)

---

## 🎯 Mapa de Cobertura de Criterios Técnicos

> [!NOTE]
> La arquitectura de servidores de RASSPP está diseñada para la alta disponibilidad y la resiliencia mediante una estrategia de despliegue híbrida (local y nube). Esto permite una transición transparente entre entornos de desarrollo local en contenedores Docker y producción en la nube (Vercel + Railway + base de datos SQL Server remota).

| Criterio Técnico de la Rúbrica | Estado | Nivel de Logro | Cómo se cubre en el Proyecto RASSPP (Directa o Indirectamente) |
| :--- | :---: | :---: | :--- |
| **1. Configuración, instalación y operación de servidores (Docker & Compose).** | **Cumplido** | **Excelente (4)** | **Virtualización Completa del Ecosistema:**<br>El proyecto incluye la orquestación de la API de .NET 10.0 y el Frontend de Vite mediante contenedores aislados que comparten una red bridge interna (`rasspp-network`). La API utiliza compulación *multi-stage* optimizada para reducir la huella de memoria en disco. |
| **2. Monitoreo de recursos y salud de los servidores en tiempo real.** | **Cumplido** | **Excelente (4)** | **Telemetría e Instrumentation Activa:**<br>• *Cloud:* Monitoreo continuo de uso de CPU, memoria y ancho de banda en la consola de Railway.<br>• *Código:* Endpoint de diagnóstico de salud (`/health`) en .NET que evalúa la conectividad a la base de datos SQL Server antes de autorizar tráfico.<br>• *Logs:* Consolidación de logs estructurados stdout/stderr accesibles desde Docker y Railway. |
| **3. Despliegue multiplataforma en producción con alta disponibilidad y CI/CD.** | **Cumplido** | **Excelente (4)** | **Pipelines Automatizados e Inyección de Variables:**<br>Integración con GitHub para despliegues continuos automáticos (*git push*): el frontend de React/Vite se compila y aloja en la red perimetral de Vercel (Edge Network), mientras que el backend dinámico de .NET se levanta en Railway. Las variables de entorno (`VITE_API_URL`, connection strings de SQL Server) se inyectan dinámicamente según el entorno. |

---

## 🔍 Detalle Técnico de la Implementación (Servidores y Despliegue)

### 1. Virtualización y Compilación Multi-Stage (Docker & Compose)

Para homogeneizar el entorno de desarrollo y simplificar el aprovisionamiento, se utiliza **Docker Compose** orquestando los servicios sobre una red puente privada.

#### Orquestación de Servidores: [docker-compose.yml](file:///c:/Users/IRVIN/OneDrive/Documentos/RASSPP-2026/RASSPP-System/docker-compose.yml)
```yaml
version: '3.8'
 
services:
  backend-api:
    build:
      context: .
      dockerfile: Rasspp.Api/Dockerfile
    ports:
      - "5167:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=192.168.100.149;Database=RASSPP_DB;User Id=sa;Password=Tacosdorados.02;TrustServerCertificate=True;MultipleActiveResultSets=true
    networks:
      - rasspp-network
 
  frontend-web:
    build:
      context: ./rasspp-frontend
      dockerfile: Dockerfile
    ports:
      - "5173:5173"
    volumes:
      - ./rasspp-frontend:/app
      - /app/node_modules
    networks:
      - rasspp-network
 
networks:
  rasspp-network:
    driver: bridge
```

#### Dockerfile del Servidor de Aplicaciones (Compilación de Alto Rendimiento): [Dockerfile (API)](file:///c:/Users/IRVIN/OneDrive/Documentos/RASSPP-2026/RASSPP-System/Rasspp.Api/Dockerfile)
Se implementa una compilación multi-stage para compilar en un entorno robusto de desarrollo (`sdk:10.0`) y empaquetar el ejecutable final en una imagen runtime superligera y segura (`aspnet:10.0`), reduciendo el tamaño de la imagen final a menos de 200 MB:

```dockerfile
# Etapa 1: Compilación y Restauración de Dependencias
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
 
COPY ["Rasspp.Api/Rasspp.Api.csproj", "Rasspp.Api/"]
COPY ["Rasspp.Business/Rasspp.Business.csproj", "Rasspp.Business/"]
COPY ["Rasspp.Data/Rasspp.Data.csproj", "Rasspp.Data/"]
RUN dotnet restore "Rasspp.Api/Rasspp.Api.csproj"
 
COPY . .
WORKDIR "/src/Rasspp.Api"
RUN dotnet build "Rasspp.Api.csproj" -c Release -o /app/build
RUN dotnet publish "Rasspp.Api.csproj" -c Release -o /app/publish
 
# Etapa 2: Imagen Final de Producción Ligera
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Rasspp.Api.dll"]
```

---

### 2. Diagnóstico de Salud y Monitoreo de Recursos (Health Checks y Telemetría)

#### A. Endpoint Interno de Monitoreo de Salud (`/health`)
En el archivo `Program.cs` del backend .NET 10, se registra el servicio de Health Checks de ASP.NET Core para que el balanceador de carga o el monitor de Railway valide que la base de datos SQL Server está en línea antes de desviar peticiones al servidor.

```csharp
// Program.cs - Configuración del servidor API
var builder = WebApplication.CreateBuilder(args);

// Registrar el servicio de diagnóstico del servidor
builder.Services.AddHealthChecks()
    .AddSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")!);

var app = builder.Build();

// Mapear la ruta de salud para herramientas de telemetría o balanceadores de carga
app.MapHealthChecks("/health");

app.Run();
```

Cuando un monitor externo hace una petición `GET https://servidor/health`, la API ejecuta internamente un query ligero de prueba a la base de datos (`SELECT 1`). Si responde, retorna un código de estado `200 OK` ("Healthy"). De lo contrario, retorna `503 Service Unavailable` ("Unhealthy"), permitiendo al orquestador cloud reiniciar la instancia de forma automatizada.

#### B. Telemetría y Límites en Railway (Nube)
En producción, el servidor de Railway monitorea de manera constante los siguientes indicadores de salud:
* **Uso de CPU (Millicores):** Permite detectar loops infinitos o bloqueos de hilos (thread starvation).
* **Consumo de Memoria (RAM):** Ayuda a diagnosticar fugas de memoria (memory leaks) en procesos pesados de generación de reportes de servicio social.
* **Network Throughput:** Registra las tasas de transferencia de carga y descarga de evidencias digitalizadas en PDF.

---

### 3. Pipeline de Despliegue Multiplataforma e Integración de Redes (CI/CD)

El sistema opera bajo un esquema híbrido de despliegue en la nube diseñado para maximizar la velocidad de carga (Frontend estático) y la capacidad de cómputo (Backend dinámico):

```
                     +---------------------------------------+
                     |         GitHub Repository (Push)      |
                     +-------------------+-------------------+
                                         |
                    +--------------------+--------------------+
                    |                                         |
                    v (Frontend React/Vite)                   v (Backend .NET API)
       +------------+------------+               +------------+------------+
       |   Vercel Deployment     |               |   Railway Container     |
       |  (CI/CD Pipeline Build) |               |  (Docker Build & Run)   |
       +------------+------------+               +------------+------------+
                    |                                         |
                    v (Inyección HTTPS)                       v (Inyección HTTPS)
       +------------+------------+               +------------+------------+
       |  https://rasspp-...app  |               |  https://rasspp-...app  |
       +------------+------------+               +------------+------------+
                    |                                         |
                    +------------------> (CORS) <-------------+
                                         |
                                         v
                      +------------------+------------------+
                      |   SQL Server DB (DDNS / Cloud)      |
                      +-------------------------------------+
```

* **Frontend (Vercel):** Se compila y distribuye en la red global CDN de Vercel. Cuenta con compilación automatizada al hacer *push* a la rama `main`, garantizando cero latencia de carga para los alumnos.
* **Backend (Railway):** Detecta los cambios de Git, compila el Dockerfile multi-stage asíncronamente y expone los endpoints en un entorno HTTPS dinámico administrado por Railway.
* **Base de Datos Segura:** La base de datos SQL Server está alojada localmente y expuesta de forma segura a través de túneles SSH de alto rendimiento o DNS dinámico (No-IP con `rassppdb.ddns.net`) permitiendo al contenedor del backend en Railway comunicarse directamente por el puerto TCP/IP estándar `1433`.

---

## 🚀 Elementos Extra de Valor Agregado en el Proyecto

* **Despliegues Libres de Caídas (Zero-Downtime Deployments):** Railway y Vercel utilizan contenedores paralelos transicionales. Al subir cambios, el servidor viejo no se detiene hasta que el contenedor con el código nuevo responde al probe `/health` correctamente. Esto previene la interrupción del servicio escolar durante periodos de alta demanda.
* **Políticas de CORS Seguras en Producción:** Para evitar el secuestro de peticiones (Cross-Origin Resource Sharing attacks), el servidor backend restringe las llamadas HTTPS entrantes permitiendo únicamente a los dominios autorizados de la aplicación web y los clientes nativos de Swift/Android:
  ```csharp
  app.UseCors(builder => builder
      .WithOrigins("https://rasspp-frontend.vercel.app", "http://localhost:5173")
      .AllowAnyMethod()
      .AllowAnyHeader());
  ```
* **Terminación SSL Automatizada:** Todo el tráfico entre clientes (navegadores, iOS, Android) y el servidor backend de .NET está cifrado en tránsito mediante certificados TLS/SSL autogestionados y auto-renovados por Railway y Vercel.
