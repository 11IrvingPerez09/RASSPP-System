import SwiftUI

// MARK: - 1. PANTALLA PRINCIPAL (EL ESQUELETO VISUAL)
struct ContentView: View {
    // Estas variables de estado controlan las pantallas de forma 100% visual
    @State private var estaAutenticado = false
    @State private var estaCargando = false
    @State private var correoInstitucional = "coordinacion.software@ulsa.edu.mx"
    @State private var jefeActual = "Ing. Roberto Martínez"
    @State private var carreraActual = "Ingeniería de Software y Sistemas Computacionales"
    
    var body: some View {
        Group {
            if estaAutenticado {
                // DASHBOARD VISUAL DEL JEFE DE CARRERA
                NavigationStack {
                    VStack(alignment: .leading) {
                        // Banner del perfil simulado
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bienvenido, \(jefeActual)")
                                .font(.title2.bold())
                            Text(carreraActual)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding([.horizontal, .top])
                        
                        if estaCargando {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView("Simulando consulta a la API de RASSPP...")
                                Spacer()
                            }
                            Spacer()
                        } else {
                            // Lista estática simulada de alumnos
                            List {
                                ElementoListaAlumno(nombre: "Carlos Mendoza Ruiz", detalle: "Semestre: 6° • Servicio Social", estatus: "Pendiente")
                                ElementoListaAlumno(nombre: "Ana Valeria Gómez", detalle: "Semestre: 7° • Prácticas Profesionales", estatus: "Aprobado")
                                ElementoListaAlumno(nombre: "Diego Alejandro Torres", detalle: "Semestre: 8° • Prácticas Profesionales", estatus: "Pendiente")
                            }
                            .listStyle(.insetGrouped)
                        }
                    }
                    .navigationTitle("RASSPP Admin")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Cerrar Sesión", role: .destructive) {
                                estaAutenticado = false
                            }
                        }
                    }
                }
                
            } else {
                // PANTALLA DE LOGIN (DISEÑO DE ENTRA ID SIMULADO)
                VStack(spacing: 25) {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("RASSPP")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.blue)
                        Text("Control de Prácticas y Servicio Social")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 15) {
                        Text("Inicia sesión con tu cuenta institucional de Microsoft")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Correo Institucional", text: $correoInstitucional)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.horizontal, 30)
                        
                        Button(action: {
                            // Dispara la animación de carga y el cambio de pantalla puramente visual
                            estaCargando = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                estaCargando = false
                                estaAutenticado = true
                            }
                        }) {
                            HStack {
                                if estaCargando {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "lock.shield.fill")
                                    Text("Autenticar con Entra ID")
                                        .bold()
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(estaCargando ? Color.gray : Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(estaCargando || correoInstitucional.isEmpty)
                        .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 30)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 2. COMPONENTES AUXILIARES DE DISEÑO
struct ElementoListaAlumno: View {
    let nombre: String
    let detalle: String
    let estatus: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(nombre)
                    .font(.headline)
                Text(detalle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Text(estatus)
                .font(.caption2.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(colorParaEstatus(estatus).opacity(0.15))
                .foregroundColor(colorParaEstatus(estatus))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
    
    private func colorParaEstatus(_ estatus: String) -> Color {
        switch estatus {
        case "Aprobado": return .green
        case "Pendiente": return .orange
        case "Rechazado": return .red
        default: return .gray
        }
    }
}

// MARK: - 3. VISTA DE PREVISUALIZACIÓN (PREVIEW)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
