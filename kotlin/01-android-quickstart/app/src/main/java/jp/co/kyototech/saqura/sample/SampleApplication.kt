package jp.co.kyototech.saqura.sample

import android.app.Application
import co.kyototech.saqura.licensing.ApiLicense
import kotlinx.coroutines.runBlocking

/**
 * Wire SaQura's license storage to Android at startup.
 *
 * `ApiLicense.initialize(context)` connects license persistence to
 * EncryptedSharedPreferences; `loadStoredLicense()` restores a previously
 * activated `.lic` so paid features stay unlocked across launches.
 *
 * On the Free tier (no license) both calls are still safe — every feature
 * runs, output is just size-limited and watermarked.
 */
class SampleApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        runBlocking {
            ApiLicense.initialize(this@SampleApplication)
            ApiLicense.loadStoredLicense()
        }
    }
}
