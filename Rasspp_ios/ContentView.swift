import SwiftUI
import WebKit

struct ContentView: View {
    // Controla si mostramos la pantalla de bienvenida o la Web
    @State private var mostrarWeb = false
    @State private var animarLogo = false
    
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
                .transition(.move(edge: .trailing)) // Animación de empuje lateral
            } else {
                // PANTALLA 1: LANDING PAGE (BIENVENIDA)
                renderLandingPage()
                    .transition(.move(edge: .leading))
            }
        }
    }
    
    // MARK: - DISEÑO DE LA PANTALLA DE ENTRADA
    @ViewBuilder
    func renderLandingPage() -> some View {
        ZStack {
            // Fondo con los colores institucionales
            LinearGradient(
                colors: [Color.white, Color.blue.opacity(0.1), Color.blue.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // CONTENEDOR DEL LOGO
                VStack(spacing: 20) {
                    // Aquí llamamos a la imagen que subiste a Assets
                    Image("LogoApp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .shadow(color: .blue.opacity(0.2), radius: 20, x: 0, y: 10)
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
                
                // BOTÓN DE ACCESO DIRECTO
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
                
                // Info del Proyecto / Universidad
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
            // Animación de entrada suave del logo
            withAnimation(.easeOut(duration: 0.8)) {
                animarLogo = true
            }
        }
    }
}

// MARK: - COMPONENTE WEBVIEW (MODERNO)
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

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
