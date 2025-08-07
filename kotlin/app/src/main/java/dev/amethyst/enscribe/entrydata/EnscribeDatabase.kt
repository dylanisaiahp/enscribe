package dev.amethyst.enscribe.entrydata

import android.content.Context
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

/**
 * Room database for entries: Note, Task, Verse, Prayer.
 * Registers the Reminder converter via EntryReminders.
 */
@Database(
    entities = [
        Entry.Note::class,
        Entry.Task::class,
        Entry.Verse::class,
        Entry.Prayer::class,
    ],
    version = 1,
    exportSchema = true,
)
@TypeConverters(EntryConverters::class)
abstract class EnscribeDatabase : RoomDatabase() {
    abstract fun noteDao(): NoteDao

    abstract fun taskDao(): TaskDao

    abstract fun verseDao(): VerseDao

    abstract fun prayerDao(): PrayerDao

    companion object {
        @Volatile
        private var INSTANCE: EnscribeDatabase? = null

        fun getInstance(context: Context): EnscribeDatabase =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: Room
                    .databaseBuilder(
                        context.applicationContext,
                        EnscribeDatabase::class.java,
                        "enscribe.db",
                    ).build()
                    .also { INSTANCE = it }
            }
    }
}

/**
 * DAO interfaces declared here for quick access.
 * Feel free to move each into its own file when you scale.
 */
@Dao
interface NoteDao {
    @Insert
    suspend fun insert(note: Entry.Note)

    @Query("SELECT * FROM notes WHERE id = :id")
    suspend fun getById(id: Int): Entry.Note?

    @Query("SELECT * FROM notes ORDER BY createdAt DESC")
    suspend fun getAll(): List<Entry.Note>
}

@Dao
interface TaskDao {
    @Insert
    suspend fun insert(task: Entry.Task)

    @Query("SELECT * FROM tasks WHERE completed = 0 ORDER BY modifiedAt DESC")
    suspend fun getPendingTasks(): List<Entry.Task>
}

@Dao
interface VerseDao {
    @Insert
    suspend fun insert(verse: Entry.Verse)

    @Query("SELECT * FROM verses ORDER BY title")
    suspend fun getAll(): List<Entry.Verse>
}

@Dao
interface PrayerDao {
    @Insert
    suspend fun insert(prayer: Entry.Prayer)

    @Query("SELECT * FROM prayers ORDER BY priority DESC, modifiedAt DESC")
    suspend fun getAll(): List<Entry.Prayer>
}
