package com.example.myapplication

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.ByteArrayOutputStream

class PixooClient(private val context: Context) {
    private val client = OkHttpClient()
    private val baseUrl = "http://espressif:80/post"
    private val mediaType = "application/json".toMediaType()
    private val TAG = "PixooClient"

    suspend fun sendImage(drawableId: Int) {
        try {
            Log.d(TAG, "Starting to send image with drawableId: $drawableId")
            withContext(Dispatchers.IO) {
                // Clear the display first
                clearPixooImage()
                
                val drawable = context.getDrawable(drawableId)
                if (drawable == null) {
                    Log.e(TAG, "Failed to get drawable for id: $drawableId")
                    return@withContext
                }
                Log.d(TAG, "Got drawable, converting to bitmap")
                val bitmap = drawableToBitmap(drawable)
                Log.d(TAG, "Converted to bitmap, converting to pixel data")
                val pixelData = bitmapToPixelData(bitmap)
                Log.d(TAG, "Converted to pixel data, encoding to base64")
                val base64Data = Base64.encodeToString(pixelData, Base64.NO_WRAP)

                val payload = JSONObject().apply {
                    put("Command", "Draw/SendHttpGif")
                    put("PicID", 1)
                    put("PicNum", 1)
                    put("PicWidth", 64)
                    put("PicOffset", 0)
                    put("PicSpeed", 100)
                    put("PicData", base64Data)
                }

                Log.d(TAG, "Sending request to Pixoo at $baseUrl")
                val request = Request.Builder()
                    .url(baseUrl)
                    .post(payload.toString().toRequestBody(mediaType))
                    .build()

                client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) {
                        Log.e(TAG, "Failed to send image: ${response.code}")
                        Log.e(TAG, "Response body: ${response.body?.string()}")
                        throw Exception("Failed to send image: ${response.code}")
                    }
                    Log.d(TAG, "Successfully sent image to Pixoo")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error sending image to Pixoo", e)
            throw e
        }
    }
    
    suspend fun sendBitmap(bitmap: Bitmap) {
        try {
            Log.d(TAG, "Starting to send bitmap")
            withContext(Dispatchers.IO) {
                // Clear the display first
                clearPixooImage()
                
                // Ensure bitmap is 64x64
                val scaledBitmap = if (bitmap.width != 64 || bitmap.height != 64) {
                    Bitmap.createScaledBitmap(bitmap, 64, 64, true)
                } else {
                    bitmap
                }
                
                Log.d(TAG, "Converting bitmap to pixel data")
                val pixelData = bitmapToPixelData(scaledBitmap)
                Log.d(TAG, "Converted to pixel data, encoding to base64")
                val base64Data = Base64.encodeToString(pixelData, Base64.NO_WRAP)

                val payload = JSONObject().apply {
                    put("Command", "Draw/SendHttpGif")
                    put("PicID", 1)
                    put("PicNum", 1)
                    put("PicWidth", 64)
                    put("PicOffset", 0)
                    put("PicSpeed", 100)
                    put("PicData", base64Data)
                }

                Log.d(TAG, "Sending request to Pixoo at $baseUrl")
                val request = Request.Builder()
                    .url(baseUrl)
                    .post(payload.toString().toRequestBody(mediaType))
                    .build()

                client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) {
                        Log.e(TAG, "Failed to send bitmap: ${response.code}")
                        Log.e(TAG, "Response body: ${response.body?.string()}")
                        throw Exception("Failed to send bitmap: ${response.code}")
                    }
                    Log.d(TAG, "Successfully sent bitmap to Pixoo")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error sending bitmap to Pixoo", e)
            throw e
        }
    }

    private suspend fun clearPixooImage() {
        try {
            Log.d(TAG, "Clearing Pixoo display")
            withContext(Dispatchers.IO) {
                val payload = JSONObject().apply {
                    put("Command", "Draw/ResetHttpGifId")
                    put("PicID", 1)
                }

                val request = Request.Builder()
                    .url(baseUrl)
                    .post(payload.toString().toRequestBody(mediaType))
                    .build()

                client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) {
                        Log.e(TAG, "Failed to clear display: ${response.code}")
                        Log.e(TAG, "Response body: ${response.body?.string()}")
                        throw Exception("Failed to clear display: ${response.code}")
                    }
                    Log.d(TAG, "Successfully cleared Pixoo display")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing Pixoo display", e)
            throw e
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        try {
            val bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val width = drawable.intrinsicWidth
                val height = drawable.intrinsicHeight
                val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                drawable.setBounds(0, 0, width, height)
                drawable.draw(android.graphics.Canvas(bitmap))
                bitmap
            }
            return Bitmap.createScaledBitmap(bitmap, 64, 64, true)
        } catch (e: Exception) {
            Log.e(TAG, "Error converting drawable to bitmap", e)
            throw e
        }
    }

    private fun bitmapToPixelData(bitmap: Bitmap): ByteArray {
        try {
            val width = bitmap.width
            val height = bitmap.height
            val pixelData = ByteArray(width * height * 3)

            var index = 0
            for (y in 0 until height) {
                for (x in 0 until width) {
                    val pixel = bitmap.getPixel(x, y)
                    pixelData[index++] = android.graphics.Color.red(pixel).toByte()
                    pixelData[index++] = android.graphics.Color.green(pixel).toByte()
                    pixelData[index++] = android.graphics.Color.blue(pixel).toByte()
                }
            }
            return pixelData
        } catch (e: Exception) {
            Log.e(TAG, "Error converting bitmap to pixel data", e)
            throw e
        }
    }
} 