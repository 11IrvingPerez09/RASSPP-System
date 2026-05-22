import SwiftUI
import WebKit

struct ContentView: View {
    @State private var mostrarWeb = false
    @State private var animarLogo = false
    
    // ESTADOS PARA LA CÁMARA Y FOTO DE PERFIL REAL (CONEXIÓN CLOUDINARY)
    @State private var mostrarOpcionesFoto = false
    @State private var mostrarPicker = false
    @State private var tipoFuente: UIImagePickerController.SourceType = .photoLibrary
    @State private var imagenPerfil: UIImage? = nil
    @State private var subiendoACloudinary = false
    @State private var urlFotoCloudinary = ""
    
    var body: some View {
        ZStack {
            if mostrarWeb {
                // PANTALLA 2: EL WEBVIEW DE RASSPP
                NavigationStack {
                    WebViewInstitucional(url: URL(string: "https://santipoev.web.app/")!)
                        .edgesIgnoringSafeArea(.bottom)
                        .navigationTitle("Portal RASSPP")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { withAnimation { mostrarWeb = false } }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "chevron.left")
                                        Text("Volver")
                                    }
                                    .fontWeight(.medium)
                                }
                            }
                        }
                }
                .transition(.move(edge: .trailing))
            } else {
                // PANTALLA 1: LANDING PAGE CON BOTÓN ESTILO GOOGLE
                renderLandingPage()
                    .transition(.move(edge: .leading))
            }
        }
        // Menú nativo de iOS (Action Sheet) al presionar la foto de perfil
        .confirmationDialog("Gestionar Foto de Perfil", isPresented: $mostrarOpcionesFoto, titleVisibility: .visible) {
            Button("Tomar Foto con Cámara") {
                tipoFuente = .camera
                mostrarPicker = true
            }
            Button("Seleccionar de Galería") {
                tipoFuente = .photoLibrary
                mostrarPicker = true
            }
            if imagenPerfil != nil {
                Button("Eliminar Foto", role: .destructive) {
                    withAnimation {
                        imagenPerfil = nil
                        urlFotoCloudinary = ""
                    }
                }
            }
            Button("Cancelar", role: .cancel) {}
        }
        // Abre la cámara o galería del iPhone
        .sheet(isPresented: $mostrarPicker, onDismiss: subirFotoACloudinaryReal) {
            ImagePicker(image: $imagenPerfil, sourceType: tipoFuente)
        }
    }
    
    // MARK: - DISEÑO DE LA PANTALLA DE ENTRADA (LANDING PAGE)
    @ViewBuilder
    func renderLandingPage() -> some View {
        ZStack {
            // Fondo degradado tecnológico institucional
            LinearGradient(
                colors: [Color.white, Color.blue.opacity(0.1), Color.blue.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // CAPA SUPERIOR: AVATAR ESTILO GOOGLE (Esquina superior derecha)
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { mostrarOpcionesFoto = true }) {
                        ZStack {
                            if subiendoACloudinary {
                                Circle()
                                    .frame(width: 42, height: 42)
                                    .foregroundColor(.blue.opacity(0.1))
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else if let foto = imagenPerfil {
                                // Muestra la miniatura multimedia real tomada de la cámara
                                Image(uiImage: foto)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 42, height: 42)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 1.5))
                                    .shadow(color: .black.opacity(0.15), radius: 4)
                            } else {
                                // Icono de perfil por defecto limpio (Estilo Google)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 38))
                                    .foregroundColor(.blue.opacity(0.8))
                                    .frame(width: 42, height: 42)
                            }
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }
                Spacer()
            }
            
            // CONTENIDO CENTRAL (Logotipo de tu aplicación y Leyendas)
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image("LogoApp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .shadow(color: .blue.opacity(0.15), radius: 20, x: 0, y: 10)
                        .scaleEffect(animarLogo ? 1.0 : 0.8)
                        .opacity(animarLogo ? 1.0 : 0.0)
                    
                    VStack(spacing: 8) {
                        Text("RASSPP")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text("Gestión de Prácticas y Servicio Social")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // BOTÓN ACCESO DIRECTO AL PORTAL WEB
                Button(action: {
                    withAnimation(.spring()) {
                        mostrarWeb = true
                    }
                }) {
                    HStack(spacing: 15) {
                        Text("Entrar a la Aplicación")
                            .font(.title3.bold())
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(colors: [.blue, Color.blue.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                
                // Footer Institucional
                VStack(spacing: 5) {
                    Text("Universidad de La Salle")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Text("Proyecto Integrador • Ingeniería de Software")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.bottom, 10)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animarLogo = true
            }
        }
    }
    
    // MARK: - CONEXIÓN HTTP POST REAL CON TU CONSOLA DE CLOUDINARY
    func subirFotoACloudinaryReal() {
        guard let fotoReal = imagenPerfil else { return }
        
        // Convertir la foto a bytes comprimidos JPEG
        guard let datosImagen = fotoReal.jpegData(compressionQuality: 0.7) else { return }
        
        withAnimation {
            subiendoACloudinary = true
        }
        
        // TUS CREDENCIALES VERIFICADAS:
        let cloudName = "dfcz12ilz"
        let uploadPreset = "rasspp_preset"
        
        let urlAPI = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var peticion = URLRequest(url: urlAPI)
        peticion.httpMethod = "POST"
        
        // Boundary estructurado para la petición Multipart Form Data
        let boundary = "Boundary-\(UUID().uuidString)"
        peticion.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var cuerpo = Data()
        
        // Inyectar el Upload Preset Unsigned
        cuerpo.append("--\(boundary)\r\n".data(using: .utf8)!)
        cuerpo.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        cuerpo.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // Inyectar los bytes de la captura multimedia de la cámara
        cuerpo.append("--\(boundary)\r\n".data(using: .utf8)!)
        cuerpo.append("Content-Disposition: form-data; name=\"file\"; filename=\"foto_perfil.jpg\"\r\n".data(using: .utf8)!)
        cuerpo.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        cuerpo.append(datosImagen)
        cuerpo.append("\r\n".data(using: .utf8)!)
        cuerpo.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        peticion.httpBody = cuerpo
        
        // Disparar tarea asíncrona en segundo plano
        URLSession.shared.dataTask(with: peticion) { datos, respuesta, error in
            DispatchQueue.main.async {
                withAnimation {
                    self.subiendoACloudinary = false
                }
            }
            
            if let error = error {
                print("Error de red: \(error.localizedDescription)")
                return
            }
            
            // Decodificar la respuesta exitosa de los servidores de Cloudinary
            if let datos = datos {
                if let json = try? JSONSerialization.jsonObject(with: datos, options: []) as? [String: Any],
                   let urlPublica = json["secure_url"] as? String {
                    
                    DispatchQueue.main.async {
                        self.urlFotoCloudinary = urlPublica
                        print("🔥 ¡ÉXITO TOTAL! Servidor sincronizado.")
                        print("URL del CDN en la nube: \(urlPublica)")
                    }
                } else {
                    let respuestaFalsa = String(data: datos, encoding: .utf8) ?? ""
                    print("Error del API de Cloudinary. Verifica el guardado del Preset: \(respuestaFalsa)")
                }
            }
        }.resume()
    }
}

// MARK: - COMPONENTE WEBVIEW COMPATIBLE (SIN WARNINGS)
struct WebViewInstitucional: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let configuracion = WKWebViewConfiguration()
        let preferenciasWeb = WKWebpagePreferences()
        preferenciasWeb.allowsContentJavaScript = true
        configuracion.defaultWebpagePreferences = preferenciasWeb
        
        let webView = WKWebView(frame: .zero, configuration: configuracion)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let peticion = URLRequest(url: url)
        uiView.load(peticion)
    }
}
