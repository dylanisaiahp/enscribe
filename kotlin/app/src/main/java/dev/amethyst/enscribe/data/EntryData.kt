package dev.amethyst.enscribe.data

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

sealed class Entry {
    abstract val id: Int
    abstract val title: String
    abstract val category: String
    abstract val categoryColor: Int
    abstract val backgroundColor: Int?
    abstract val imageUri: String?
    abstract val imageFillCard: Boolean
    abstract val hasReminder: Reminder?
    abstract val createdAt: Long
    abstract val modifiedAt: Long

    // Extension function to format the date dynamically, converted from Dart.
    fun formatDynamicDate(): String {
        // Convert the timestamp to a ZonedDateTime in the local time zone.
        val date = Instant.ofEpochMilli(createdAt)
            .atZone(ZoneId.systemDefault())

        // Get today and yesterday without the time component.
        val now = Instant.now().atZone(ZoneId.systemDefault())
        val today = now.toLocalDate()
        val yesterday = today.minusDays(1)
        val targetDay = date.toLocalDate()

        // Define formatters for different cases.
        val timeFormatter = DateTimeFormatter.ofPattern("h:mm a")
        val yearAndDayFormatter = DateTimeFormatter.ofPattern("MMM d, yyyy, h:mm a")
        val dayOnlyFormatter = DateTimeFormatter.ofPattern("MMM d, h:mm a")

        return when {
            targetDay.isEqual(today) -> {
                // If the date is today, show only the time.
                timeFormatter.format(date)
            }

            targetDay.isEqual(yesterday) -> {
                // If the date is yesterday, show "Yesterday" and the time.
                "Yesterday, ${timeFormatter.format(date)}"
            }

            date.year == now.year -> {
                // If the date is in the current year, show month, day, and time.
                dayOnlyFormatter.format(date)
            }

            else -> {
                // Otherwise, show the full date, year, and time.
                yearAndDayFormatter.format(date)
            }
        }
    }

    @Entity(tableName = "notes")
    data class Note(
        @PrimaryKey(autoGenerate = true) override val id: Int = 0,
        override val title: String,
        override val category: String,
        override val categoryColor: Int,
        override val backgroundColor: Int?,
        override val imageUri: String?,
        override val imageFillCard: Boolean,
        override val hasReminder: Reminder?,
        override val createdAt: Long,
        override val modifiedAt: Long,
        val content: String,
    ) : Entry()

    @Entity(tableName = "tasks")
    data class Task(
        @PrimaryKey(autoGenerate = true) override val id: Int = 0,
        override val title: String,
        override val category: String,
        override val categoryColor: Int,
        override val backgroundColor: Int?,
        override val imageUri: String?,
        override val imageFillCard: Boolean,
        override val hasReminder: Reminder?,
        override val createdAt: Long,
        override val modifiedAt: Long,
        val checklist: List<String>,
        val completed: Boolean = false,
    ) : Entry()

    @Entity(tableName = "verses")
    data class Verse(
        @PrimaryKey(autoGenerate = true) override val id: Int = 0,
        override val title: String,
        override val category: String,
        override val categoryColor: Int,
        override val backgroundColor: Int?,
        override val imageUri: String?,
        override val imageFillCard: Boolean,
        override val hasReminder: Reminder?,
        override val createdAt: Long,
        override val modifiedAt: Long,
        val verse: String,
    ) : Entry()

    @Entity(tableName = "prayers")
    data class Prayer(
        @PrimaryKey(autoGenerate = true) override val id: Int = 0,
        override val title: String,
        override val category: String,
        override val categoryColor: Int,
        override val backgroundColor: Int?,
        override val imageUri: String?,
        override val imageFillCard: Boolean,
        override val hasReminder: Reminder?,
        override val createdAt: Long,
        override val modifiedAt: Long,
        val prayer: String,
        val priority: Int = 0,
    ) : Entry()
}
