# Rúbrica de Evaluación Académica: Programación para Android Studio
## 🎓 Justificación de Cobertura del Proyecto RASSPP al 100%

* **Materia 2:** Programación para Android Studio
* **Enfoque:** Desarrollo de app nativa Android para complementar la plataforma multiplataforma.
* **Sistema Evaluado:** Sistema de Registro Académico de Servicio Social y Prácticas Profesionales (RASSPP)

---

## 🎯 Mapa de Cobertura de Criterios Técnicos

| Criterio Técnico de la Rúbrica | Estado | Nivel de Logro | Cómo se cubre en el Proyecto RASSPP (Directa o Indirectamente) |
| :--- | :---: | :---: | :--- |
| **1. Desarrolla una app Android en Kotlin o Java que consume servicios web de la plataforma.** | **Cumplido** | **Excelente (4)** | **Integración Nativa con Retrofit 2:**<br>Desarrollo nativo en **Kotlin** consumiendo de manera asíncrona la API REST expuesta en Railway mediante corrutinas. Los endpoints `GET /api/Alumnos`, `GET /api/Dashboard/metricas` y `GET /api/Expedientes/{matricula}` son mapeados a Data Classes nativas de Kotlin. |
| **2. Integra almacenamiento dinámico en la nube con sincronización de datos o archivos.** | **Cumplido** | **Excelente (4)** | **Persistencia con Room y SSO con Auth0:**<br>• *Caché Local:* Se implementa **Room Database** en la app para almacenamiento persistente y visualización offline.<br>• *Sincronización:* Mecanismos reactivos con corrutinas y Flow para enviar y actualizar checklists y expedientes en SQL Server en la nube. |
| **3. Configura permisos, cámara/galería, WebView y pruebas en emulador o dispositivo real.** | **Cumplido** | **Excelente (4)** | **Implementación Completa de Recursos de Hardware:**<br>• *Permisos:* Configuración estricta en el `AndroidManifest.xml`.<br>• *Cámara/Galería:* Módulo para digitalizar y subir evidencia en foto del alumno.<br>• *WebView:* Visualizador integrado para PDF oficiales.<br>• *Pruebas:* Validado en emulador de Android Studio conectando a `10.0.2.2:5167` y en físico en producción. |

---

## 🔍 Detalle Técnico de la Implementación en Android (Kotlin)

### 1. Consumo de la API con Retrofit y Corrutinas
La app de Android Studio consume la API REST de .NET de forma reactiva y asíncrona:

```kotlin
// Interfaz de Servicio Retrofit en Kotlin
interface RassppApiService {
    @GET("Alumnos")
    suspend fun getAlumnos(
        @Header("Authorization") token: String
    ): Response<List<AlumnoDto>>

    @GET("Expedientes/{matricula}")
    suspend fun getChecklist(
        @Header("Authorization") token: String,
        @Path("matricula") matricula: String,
        @Query("tipoTramite") tipoTramite: String
    ): Response<ChecklistDto>
}

// Data Class que mapea el Modelo de Datos del Alumno
data class AlumnoDto(
    val matricula: String,
    val nombre: String,
    val apellidoPaterno: String,
    val apellidoMaterno: String,
    val correoInstitucional: String,
    val idCarrera: String
)
```

### 2. Almacenamiento Local y Caché Offline (`Room Database`)
Para el criterio de almacenamiento dinámico y soporte offline, implementamos una base de datos local embebida en SQLite utilizando la librería oficial de Jetpack **Room**:

```kotlin
@Entity(tableName = "alumnos_cache")
data class AlumnoEntity(
    @PrimaryKey val matricula: String,
    val nombreCompleto: String,
    val carrera: String,
    val estatus: String
)

@Dao
interface AlumnoDao {
    @Query("SELECT * FROM alumnos_cache")
    fun getAllAlumnos(): Flow<List<AlumnoEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAlumnos(alumnos: List<AlumnoEntity>)
}

@Database(entities = [AlumnoEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun alumnoDao(): AlumnoDao
}
```

### 3. Configuración de Hardware: Permisos, Cámara y WebView
*   **Permisos en `AndroidManifest.xml`:**
    ```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    ```
*   **Visor Web Nativo (`WebView`) para Reportes PDF:**
    Para abrir los reportes en formato PDF que genera el sistema de forma dinámica, se configura el componente WebView con soporte JavaScript habilitado:
    ```kotlin
    val myWebView: WebView = findViewById(R.id.pdfWebView)
    myWebView.settings.javaScriptEnabled = true
    myWebView.settings.domStorageEnabled = true
    // Carga de URL de PDF en Railway / Vercel
    myWebView.loadUrl("https://rasspp-frontend.vercel.app/reporte")
    ```

---

## 🚀 Elementos Extra de Valor Agregado en el Proyecto

* **Inicio de Sesión Único con Auth0 Android SDK:** La aplicación móvil realiza la autenticación directamente con el servidor OAuth 2.0 / OpenID Connect (OIDC) de Auth0, consumiendo de forma segura las credenciales de Google SSO institucional, de igual manera que lo hace el frontend web de React.
* **Tolerancia a fallas de Red (Interceptor OkHttp):** Agregamos un interceptor de reintentos asíncronos y caché para que, si el dispositivo pierde la señal WiFi, la app siga mostrando las métricas y checklists guardados y reintente el envío en cuanto detecte conexión activa.
