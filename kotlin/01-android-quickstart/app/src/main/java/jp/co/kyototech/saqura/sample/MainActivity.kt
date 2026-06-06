package jp.co.kyototech.saqura.sample

import android.os.Bundle
import android.util.Log
import android.widget.ScrollView
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.lifecycle.lifecycleScope
import co.kyototech.saqura.aes.*
import co.kyototech.saqura.licensing.ApiLicense
import co.kyototech.saqura.passwords.PasswordHasher
import co.kyototech.saqura.rsa.*
import co.kyototech.saqura.streaming.*
import kotlinx.coroutines.launch
import java.io.File

/**
 * SaQura — Android quickstart.
 *
 * Runs the core SaQura surfaces on launch and prints the results to the screen
 * (and to logcat under the tag "SaQuraSample"). Everything here works on the
 * Free tier with no license — output is just watermarked. Drop a Distribution
 * `.lic` into `app/src/main/assets/` and activate it (see the README) to unlock
 * full features.
 */
class MainActivity : ComponentActivity() {

    private val sb = StringBuilder()
    private lateinit var output: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        output = TextView(this).apply {
            setPadding(40, 56, 40, 56)
            textSize = 13f
            setTextIsSelectable(true)
        }
        setContentView(ScrollView(this).apply { addView(output) })

        lifecycleScope.launch { runDemos() }
    }

    private suspend fun runDemos() {
        line("SaQura — Android quickstart")
        line("===========================")
        line("SDK: jp.co.kyototech:saqura:1.1.3")
        line()

        line("--- License ---")
        line("Licensed : ${ApiLicense.isLicensed}")
        line("Tier     : ${ApiLicense.currentTier}")
        if (!ApiLicense.isLicensed) {
            line("(Free tier — output is watermarked. See README to activate a .lic.)")
        }
        line()

        demo("AES-256-GCM") {
            val key = AESKey.newKey()
            val enc = "Hello from SaQura on Android!".encryptWithAES(key)
            val dec = enc.decryptWithAES(key)
            line("Encrypted : ${preview(enc)}")
            line("Decrypted : $dec")
        }

        demo("RSA-4096 (encrypt + sign)") {
            val pair = RSAKey.newKeyPair()
            val enc = "Secret".encryptWithRSA(pair.publicKey)
            val dec = enc.decryptWithRSA(pair.privateKey)
            line("Encrypted : ${preview(enc)}")
            line("Decrypted : $dec")
            val sig = "Document content".signWithRSA(pair.privateKey)
            val ok = "Document content".verifyRSASignature(sig, pair.publicKey)
            line("Signature verifies : $ok")
        }

        demo("Password hashing (PBKDF2-SHA512)") {
            val hash = PasswordHasher.hash("correct-horse-battery-staple")
            line("Hash      : ${preview(hash)}")
            line("Verify ok : ${PasswordHasher.verify("correct-horse-battery-staple", hash)}")
            line("Verify bad: ${PasswordHasher.verify("wrong-password", hash)}")
        }

        demo("Large-file streaming (SQS1, constant memory)") {
            val key = AESKey.newKey()
            val src = File(cacheDir, "demo.bin")
            val enc = File(cacheDir, "demo.sqs")
            val out = File(cacheDir, "demo.out")
            try {
                src.writeBytes(ByteArray(5 * 1024 * 1024) { it.toByte() }) // 5 MiB
                encryptStreamFile(src.absolutePath, enc.absolutePath, key)
                decryptStreamFile(enc.absolutePath, out.absolutePath, key)
                line("Source    : ${src.length()} bytes (5 MiB)")
                line("Encrypted : ${enc.length()} bytes → restored ${out.length()} bytes")
                line("Round-trip identical : ${src.readBytes().contentEquals(out.readBytes())}")
            } finally {
                src.delete(); enc.delete(); out.delete()
            }
        }

        line()
        line("--- Feature availability (current tier) ---")
        line("AES      : ${boolOrNa { ApiLicense.isAESAvailable }}")
        line("Quantum  : ${boolOrNa { ApiLicense.isQuantumAvailable }}")
        line()
        line("Done. ✓")
    }

    /** Run one labelled demo block, surfacing tier gates instead of crashing. */
    private suspend fun demo(title: String, block: suspend () -> Unit) {
        line("--- $title ---")
        try {
            block()
        } catch (e: Throwable) {
            line("(skipped: ${e.message ?: e.javaClass.simpleName})")
        }
        line()
    }

    private fun line(s: String = "") {
        sb.appendLine(s)
        Log.i(TAG, s)
        output.text = sb.toString()
    }

    private fun preview(s: String, n: Int = 60): String =
        if (s.length <= n) s else s.substring(0, n) + "…"

    private inline fun boolOrNa(block: () -> Boolean): String =
        try { block().toString() } catch (e: Throwable) { "n/a" }

    companion object {
        private const val TAG = "SaQuraSample"
    }
}
