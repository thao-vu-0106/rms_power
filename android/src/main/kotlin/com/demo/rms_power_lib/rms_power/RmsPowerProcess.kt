package com.demo.rms_power_lib.rms_power

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.demo.rms_power_lib.rms_power.core.FFT4g
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.log10
import kotlin.math.pow
import kotlin.math.sqrt


class RmsPowerProcess(private val activity: Activity) : MethodCallHandler,
    EventChannel.StreamHandler,
    PluginRegistry.RequestPermissionsResultListener {
    companion object {
        /**
         * When the application's activity is [androidx.fragment.app.FragmentActivity], requestCode can only use the lower 16 bits.
         * @see androidx.fragment.app.FragmentActivity.validateRequestPermissionsRequestCode
         */
        private const val REQUEST_CODE = 0x0786
        private val TAG = RmsPowerProcess::class.java.simpleName

        private const val SAMPLING_RATE = 44100

        private const val FFT_SIZE = 2048

    }

    private var listener: PluginRegistry.RequestPermissionsResultListener? = null
    private var audioRecord: AudioRecord? = null
    private var bIsRecording = false
    private var fft: Thread? = null
    private var eventSink: EventChannel.EventSink? = null
    private val bufferSize = AudioRecord.getMinBufferSize(
        SAMPLING_RATE,
        AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
    )
    private val dbBaseLine: Double = 2.0.pow(15.0) * FFT_SIZE * sqrt(2.0)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> getPlatformVersion(result)
            "requestPermission" -> requestPermission(result)
            "startRecorder" -> startRecorder(result)
            "stopRecorder" -> stopRecorder(result)
            "checkPermission" -> checkPermissionAudio(result)
        }

    }

    private fun checkPermissionAudio(result: MethodChannel.Result) {
        val state =
            ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        result.success(state)
    }

    private fun stopRecorder(result: MethodChannel.Result) {
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        fft = null
        result.success("Recorder stopped.")
    }

    private fun startRecorder(result: MethodChannel.Result) {
        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLING_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize,
        )
        audioRecord?.startRecording()
        bIsRecording = true
        fft = Thread {
            val buf = ByteArray(bufferSize * 2)
            while (bIsRecording) {
                audioRecord?.read(buf, 0, buf.size)

                // エンディアン変換
                val bf = ByteBuffer.wrap(buf)
                bf.order(ByteOrder.LITTLE_ENDIAN)
                val s = ShortArray(bufferSize)
                for (i in bf.position() until bf.capacity() / 2) {
                    s[i] = bf.short
                }

                // FFTクラスの作成と値の引き渡し
                val fft = FFT4g(FFT_SIZE)
                val fftData =
                    DoubleArray(FFT_SIZE)
                for (i in 0 until FFT_SIZE) {
                    fftData[i] = s[i].toDouble()
                }
                fft.rdft(1, fftData)

                // デシベルの計算
                val dbfs =
                    DoubleArray(FFT_SIZE / 2)
                var maxDb = -120.0
                var i = 0
                while (i < FFT_SIZE) {
                    dbfs[i / 2] = (20 * log10(
                        sqrt(
                            fftData[i].pow(2.0)
                                    + fftData[i + 1].pow(2.0)
                        ) / dbBaseLine
                    )).toInt().toDouble()
                    if (maxDb < dbfs[i / 2]) {
                        maxDb = dbfs[i / 2]
                    }
                    i += 2
                }

                // 音量が最大の周波数と，その音量を表示
                activity.runOnUiThread {
                    eventSink?.success(maxDb)
                }

                // 数値を表示したい時は右記 Log.v("[fft]周波数："+ self.resol * max_i+" [Hz] 音量：" +  max_db+" [dB]", "TSET");
            }
            // 録音停止
            audioRecord?.stop()
            audioRecord?.release()
        }
        fft?.start()
        result.success("startRecorder success: ")
    }

    private fun requestPermission(result: MethodChannel.Result) {
        listener = PluginRegistry.RequestPermissionsResultListener { requestCode, _, grantResults ->
            if (requestCode != REQUEST_CODE) {
                false
            } else {
                val authorized = grantResults[0] == PackageManager.PERMISSION_GRANTED
                result.success(authorized)
                listener = null
                true
            }
        }
        val permissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(activity, permissions, REQUEST_CODE)
    }

    private fun getPlatformVersion(result: MethodChannel.Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        return listener?.onRequestPermissionsResult(requestCode, permissions, grantResults) ?: false
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}