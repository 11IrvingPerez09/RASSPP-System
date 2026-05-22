package com.example.appjefecarrera

import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import coil.load
import com.cloudinary.android.MediaManager
import com.cloudinary.android.callback.ErrorInfo
import com.cloudinary.android.callback.UploadCallback
import com.example.appjefecarrera.databinding.ActivityMainBinding


class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inicializar Cloudinary
        val config = mapOf("cloud_name" to "dfcz12ilz")
        try {
            MediaManager.init(this, config)
        } catch (e: Exception) {
            // Ya inicializado
        }

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Botón Login
        binding.btnLogin.setOnClickListener {
            if (binding.etEmail.text.isNotEmpty()) {
                binding.layoutLogin.visibility = View.GONE
                binding.layoutDashboard.visibility = View.VISIBLE
            }
        }

        // Botón Subir Foto
        binding.btnCambiarFoto.setOnClickListener {
            pickImage.launch("image/*")
        }
    }

    private val pickImage = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        uri?.let {
            // Mostrar vista previa inmediatamente
            binding.imgPerfil.load(it)


            // Iniciar subida
            subirACloudinary(it)
        }
    }

    private fun subirACloudinary(uri: Uri) {
        Toast.makeText(this, "Subiendo a la nube...", Toast.LENGTH_SHORT).show()

        MediaManager.get().upload(uri)
            .unsigned("rasspp_preset")
            .callback(object : UploadCallback {
                override fun onSuccess(requestId: String?, resultData: Map<*, *>) {
                    val url = resultData["secure_url"].toString()
                    runOnUiThread {
                        Toast.makeText(this@MainActivity, "Subida exitosa", Toast.LENGTH_SHORT).show()
                        // AQUI: Envia 'url' a tu backend con Retrofit
                    }
                }

                override fun onError(requestId: String?, error: ErrorInfo?) {
                    runOnUiThread {
                        Toast.makeText(this@MainActivity, "Error: ${error?.description}", Toast.LENGTH_LONG).show()
                    }
                }

                override fun onStart(requestId: String?) {}
                override fun onProgress(requestId: String?, bytes: Long, totalBytes: Long) {}
                override fun onReschedule(requestId: String?, error: ErrorInfo?) {}
            }).dispatch()
    }
}