package com.example.myapplication

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.Log
import java.util.*
import kotlin.math.max
import kotlin.math.min
import kotlin.random.Random

class SnakeGame {
    companion object {
        const val GRID_SIZE = 16 // 64px / 4px per cell = 16 cells
        const val CELL_SIZE = 4  // Each cell is 4x4 pixels
        const val TAG = "SnakeGame"
    }

    // Game state
    private var isGameOver = false
    private var score = 0
    private var direction = Direction.RIGHT
    private var nextDirection = Direction.RIGHT
    private val snake = LinkedList<Point>()
    private var food = Point(0, 0)
    
    // Colors
    private val backgroundColor = Color.BLACK
    private val snakeBorderColor = Color.GREEN
    private val foodColor = Color.RED
    private val borderColor = Color.BLUE
    
    init {
        resetGame()
    }
    
    fun resetGame() {
        Log.d(TAG, "Resetting game")
        isGameOver = false
        score = 0
        direction = Direction.RIGHT
        nextDirection = Direction.RIGHT
        
        // Initialize snake with 3 segments in the middle
        snake.clear()
        val centerX = GRID_SIZE / 2
        val centerY = GRID_SIZE / 2
        snake.add(Point(centerX, centerY))     // Head
        snake.add(Point(centerX - 1, centerY)) // Body
        snake.add(Point(centerX - 2, centerY)) // Tail
        
        // Place food at random location
        placeFood()
    }
    
    private fun placeFood() {
        // Find a random empty cell for food
        val emptyCells = mutableListOf<Point>()
        for (x in 0 until GRID_SIZE) {
            for (y in 0 until GRID_SIZE) {
                val point = Point(x, y)
                if (!snake.contains(point)) {
                    emptyCells.add(point)
                }
            }
        }
        
        if (emptyCells.isEmpty()) {
            // Game won! (unlikely but possible)
            isGameOver = true
            return
        }
        
        food = emptyCells[Random.nextInt(emptyCells.size)]
        Log.d(TAG, "Food placed at $food")
    }
    
    fun update(): Boolean {
        if (isGameOver) {
            return false
        }
        
        // Update direction (but don't allow 180-degree turns)
        if ((nextDirection == Direction.UP && direction != Direction.DOWN) ||
            (nextDirection == Direction.DOWN && direction != Direction.UP) ||
            (nextDirection == Direction.LEFT && direction != Direction.RIGHT) ||
            (nextDirection == Direction.RIGHT && direction != Direction.LEFT)) {
            direction = nextDirection
        }
        
        // Calculate new head position
        val head = snake.first()
        val newHead = when (direction) {
            Direction.UP -> Point(head.x, (head.y - 1 + GRID_SIZE) % GRID_SIZE)
            Direction.DOWN -> Point(head.x, (head.y + 1) % GRID_SIZE)
            Direction.LEFT -> Point((head.x - 1 + GRID_SIZE) % GRID_SIZE, head.y)
            Direction.RIGHT -> Point((head.x + 1) % GRID_SIZE, head.y)
        }
        
        // Check for collision with self
        if (snake.contains(newHead)) {
            isGameOver = true
            Log.d(TAG, "Game over: Snake collided with itself")
            return false
        }
        
        // Move snake
        snake.addFirst(newHead)
        
        // Check for food
        if (newHead == food) {
            // Snake ate food, increase score
            score++
            Log.d(TAG, "Snake ate food! Score: $score")
            placeFood()
        } else {
            // Remove tail if no food was eaten
            snake.removeLast()
        }
        
        return true
    }
    
    fun setDirection(newDirection: Direction) {
        this.nextDirection = newDirection
        Log.d(TAG, "Direction set to $newDirection")
    }
    
    fun render(): Bitmap {
        val bitmap = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()
        
        // Fill background
        canvas.drawColor(backgroundColor)
        
        // Draw border
        paint.color = borderColor
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 1f
        canvas.drawRect(0f, 0f, 64f, 64f, paint)
        paint.style = Paint.Style.FILL
        
        // Draw snake with gradient
        if (snake.isNotEmpty()) {
            // Calculate gradient colors based on snake length
            val snakeLength = snake.size
            
            // Draw each segment with gradient color
            snake.forEachIndexed { index, segment ->
                // Calculate gradient color - darker towards the tail
                val gradientFactor = 1.0f - (index.toFloat() / snakeLength.toFloat())
                val brightness = 0.3f + (gradientFactor * 0.7f) // Range from 0.3 to 1.0
                
                // Create gradient green color
                val green = (brightness * 255).toInt()
                paint.color = Color.rgb(0, green, 0)
                
                // Draw filled segment
                val left = segment.x * CELL_SIZE.toFloat()
                val top = segment.y * CELL_SIZE.toFloat()
                val right = (segment.x + 1) * CELL_SIZE.toFloat()
                val bottom = (segment.y + 1) * CELL_SIZE.toFloat()
                
                // Draw filled segment with gradient color
                paint.style = Paint.Style.FILL
                canvas.drawRect(
                    left,
                    top,
                    right,
                    bottom,
                    paint
                )
            }
        }
        
        // Draw food
        paint.style = Paint.Style.FILL
        paint.color = foodColor
        canvas.drawRect(
            food.x * CELL_SIZE.toFloat(),
            food.y * CELL_SIZE.toFloat(),
            (food.x + 1) * CELL_SIZE.toFloat(),
            (food.y + 1) * CELL_SIZE.toFloat(),
            paint
        )
        
        return bitmap
    }
    
    fun isGameOver(): Boolean = isGameOver
    
    fun getScore(): Int = score
    
    data class Point(val x: Int, val y: Int)
    
    enum class Direction {
        UP, DOWN, LEFT, RIGHT
    }
} 