package com.example.myapplication

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(
                colorScheme = darkColorScheme(
                    background = androidx.compose.ui.graphics.Color(0xFF121212),
                    surface = androidx.compose.ui.graphics.Color(0xFF121212),
                    primary = androidx.compose.ui.graphics.Color(0xFFBB86FC),
                    secondary = androidx.compose.ui.graphics.Color(0xFF03DAC6),
                    tertiary = androidx.compose.ui.graphics.Color(0xFF3700B3)
                )
            ) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    GameControls()
                }
            }
        }
    }
}

// Function to create game over bitmap
private fun createGameOverBitmap(finalScore: Int): Bitmap {
    val bitmap = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    val paint = Paint()
    
    // Fill background
    canvas.drawColor(Color.BLACK)
    
    // Draw "GAME OVER" text
    paint.color = Color.RED
    paint.textSize = 10f
    paint.textAlign = Paint.Align.CENTER
    canvas.drawText("GAME", 32f, 25f, paint)
    canvas.drawText("OVER", 32f, 35f, paint)
    
    // Draw score
    paint.color = Color.WHITE
    paint.textSize = 8f
    canvas.drawText("SCORE: $finalScore", 32f, 50f, paint)
    
    return bitmap
}

@Composable
fun GameControls() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val pixooClient = remember { PixooClient(context) }
    val snakeGame = remember { SnakeGame() }
    val TAG = "GameControls"
    
    // Game state
    var score by remember { mutableStateOf(0) }
    var isGameRunning by remember { mutableStateOf(false) }
    var gameJob by remember { mutableStateOf<Job?>(null) }
    var currentGameBitmap by remember { mutableStateOf<Bitmap?>(null) }
    
    // Function to start the game
    fun startGame() {
        if (gameJob?.isActive == true) {
            gameJob?.cancel()
        }
        
        Log.d(TAG, "Starting Snake game")
        snakeGame.resetGame()
        isGameRunning = true
        score = 0
        
        gameJob = scope.launch {
            while (isActive && snakeGame.update()) {
                // Update score
                score = snakeGame.getScore()
                
                // Render and send to Pixoo
                val gameBitmap = snakeGame.render()
                currentGameBitmap = gameBitmap // Update the bitmap for display
                pixooClient.sendBitmap(gameBitmap)
                
                // Game speed - adjust for difficulty
                val gameSpeed = 300L - (score * 5L).coerceAtMost(200L) // Speed up as score increases
                delay(gameSpeed)
            }
            
            // Game over
            isGameRunning = false
            Log.d(TAG, "Game over! Final score: ${snakeGame.getScore()}")
            
            // Show game over screen
            delay(500) // Short pause
            val gameOverBitmap = createGameOverBitmap(snakeGame.getScore())
            currentGameBitmap = gameOverBitmap // Update the bitmap for display
            pixooClient.sendBitmap(gameOverBitmap)
            
            // Restart the game after a short delay
            delay(2000) // Show game over screen for 2 seconds
            startGame() // Restart automatically
        }
    }
    
    // Portrait layout with vertical arrangement
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Top section with title and score
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(bottom = 16.dp)
        ) {
            // Game title and score
            Text(
                text = "SNAKE",
                color = androidx.compose.ui.graphics.Color.Green,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = "Score: $score",
                color = androidx.compose.ui.graphics.Color.White,
                fontSize = 18.sp,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
        
        // Game preview in the center
        Spacer(modifier = Modifier.weight(1f))
        
        currentGameBitmap?.let { bitmap ->
            Box(
                modifier = Modifier
                    .size(240.dp)
                    .background(androidx.compose.ui.graphics.Color.Black)
                    .border(2.dp, androidx.compose.ui.graphics.Color.Gray)
            ) {
                Image(
                    bitmap = bitmap.asImageBitmap(),
                    contentDescription = "Game Preview",
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        // Controls at the bottom
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(bottom = 16.dp)
        ) {
            // Up button
            Button(
                onClick = {
                    scope.launch {
                        try {
                            Log.d(TAG, "Up button pressed")
                            snakeGame.setDirection(SnakeGame.Direction.UP)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error handling up button press", e)
                        }
                    }
                },
                modifier = Modifier.size(70.dp)
            ) {
                Text("↑", fontSize = 20.sp)
            }
            
            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Left button
                Button(
                    onClick = {
                        scope.launch {
                            try {
                                Log.d(TAG, "Left button pressed")
                                snakeGame.setDirection(SnakeGame.Direction.LEFT)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error handling left button press", e)
                            }
                        }
                    },
                    modifier = Modifier.size(70.dp)
                ) {
                    Text("←", fontSize = 20.sp)
                }
                
                // Right button
                Button(
                    onClick = {
                        scope.launch {
                            try {
                                Log.d(TAG, "Right button pressed")
                                snakeGame.setDirection(SnakeGame.Direction.RIGHT)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error handling right button press", e)
                            }
                        }
                    },
                    modifier = Modifier.size(70.dp)
                ) {
                    Text("→", fontSize = 20.sp)
                }
            }
            
            // Down button
            Button(
                onClick = {
                    scope.launch {
                        try {
                            Log.d(TAG, "Down button pressed")
                            snakeGame.setDirection(SnakeGame.Direction.DOWN)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error handling down button press", e)
                        }
                    }
                },
                modifier = Modifier.size(70.dp)
            ) {
                Text("↓", fontSize = 20.sp)
            }
        }
    }
    
    // Start game automatically when composable is first created
    LaunchedEffect(Unit) {
        delay(1000) // Short delay to ensure everything is initialized
        startGame()
    }
} 