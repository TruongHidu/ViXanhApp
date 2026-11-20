package com.example.vi_xanh_app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Lắng nghe notification của các app ngân hàng và đẩy sang Flutter qua EventChannel
 * `vi_xanh/bank_notifications`. Người dùng phải cấp quyền Notification Access.
 */
class BankNotificationListener : NotificationListenerService() {

    companion object {
        /** Package các app ngân hàng được theo dõi — mở rộng khi cần. */
        val BANK_PACKAGES = setOf(
            "com.VCB",                 // Vietcombank
            "com.vietinbank.ipay",     // VietinBank
            "com.mbmobile",            // MB Bank
            "vn.com.techcombank.bb.app", // Techcombank
            "com.tpb.mb.gprsandroid",  // TPBank
            "ops.namabank.com.vn",     // Nam A Bank
        )

        @Volatile
        var sink: EventChannel.EventSink? = null

        private val mainHandler = Handler(Looper.getMainLooper())
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName !in BANK_PACKAGES) return
        val extras = sbn.notification.extras
        val payload = mapOf(
            "package" to sbn.packageName,
            "title" to (extras.getCharSequence("android.title")?.toString() ?: ""),
            "text" to (extras.getCharSequence("android.bigText")
                ?: extras.getCharSequence("android.text"))?.toString().orEmpty(),
            "postedAt" to sbn.postTime,
        )
        mainHandler.post { sink?.success(payload) }
    }
}
