package dev.amethyst.enscribe.data

import androidx.room.Entity
import androidx.room.PrimaryKey

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
