package dev.amethyst.enscribe

import android.content.Context
import androidx.room.AutoMigration
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.Transaction
import androidx.room.TypeConverters
import com.google.gson.Gson
import dev.amethyst.enscribe.entrydata.Entry.Note
import dev.amethyst.enscribe.entrydata.Entry.Prayer
import dev.amethyst.enscribe.entrydata.Entry.Task
import dev.amethyst.enscribe.entrydata.Entry.Verse
import dev.amethyst.enscribe.entrydata.EntryConverters
import dev.amethyst.enscribe.entrydata.SettingsConverters
import kotlinx.coroutines.flow.Flow

/**
 * A helper data class to hold all the database content for backup/restore.
 */
data class AllEntries(
    val notes: List<Note>,
    val tasks: List<Task>,
    val verses: List<Verse>,
    val prayers: List<Prayer>,
)

/**
 * Entity for app-wide settings
 */
@Entity(tableName = "settings")
data class SettingsEntity(
    @PrimaryKey val id: Int = 0,
    val themeName: String = "Onyx",
    val isGridView: Boolean = true,
    val showCategory: Boolean = true,
    val showDateTime: Boolean = true,
)

@Dao
interface SettingsDao {
    @Query("SELECT * FROM settings WHERE id = 0")
    fun getSettings(): Flow<SettingsEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun saveSettings(settings: SettingsEntity)
}

/**
 * Room database for entries: Note, Task, Verse, Prayer, plus Settings.
 */
@Database(
    entities = [
        Note::class,
        Task::class,
        Verse::class,
        Prayer::class,
        SettingsEntity::class
    ],
    version = 9,
    exportSchema = true,
    autoMigrations = [
        AutoMigration(from = 8, to = 9)
    ]
)
@TypeConverters(EntryConverters::class, SettingsConverters::class)
abstract class EnscribeDatabase : RoomDatabase() {
    abstract fun noteDao(): NoteDao
    abstract fun taskDao(): TaskDao
    abstract fun verseDao(): VerseDao
    abstract fun prayerDao(): PrayerDao
    abstract fun settingsDao(): SettingsDao

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
                    )
                    .build()
                    .also { INSTANCE = it }
            }
    }

    // Helper methods for backup and restore
    suspend fun exportAllDataAsJson(): String {
        val allEntries = AllEntries(
            notes = noteDao().getAll(),
            tasks = taskDao().getAllTasks(),
            verses = verseDao().getAll(),
            prayers = prayerDao().getAll()
        )
        return Gson().toJson(allEntries)
    }

    @Transaction
    suspend fun importDataFromJson(jsonString: String) {
        val importedData = Gson().fromJson(jsonString, AllEntries::class.java)

        noteDao().deleteAll()
        taskDao().deleteAll()
        verseDao().deleteAll()
        prayerDao().deleteAll()

        noteDao().insertAll(importedData.notes)
        taskDao().insertAll(importedData.tasks)
        verseDao().insertAll(importedData.verses)
        prayerDao().insertAll(importedData.prayers)
    }
}

/**
 * DAO interfaces for entries.
 */
@Dao
interface NoteDao {
    @Insert
    suspend fun insert(note: Note)

    @Query("SELECT * FROM notes WHERE id = :id")
    suspend fun getById(id: Int): Note?

    @Query("SELECT * FROM notes ORDER BY createdAt DESC")
    suspend fun getAll(): List<Note>

    @Query("DELETE FROM notes")
    suspend fun deleteAll()

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(notes: List<Note>)
}

@Dao
interface TaskDao {
    @Insert
    suspend fun insert(task: Task)

    @Query("SELECT * FROM tasks WHERE completed = 0 ORDER BY modifiedAt DESC")
    suspend fun getPendingTasks(): List<Task>

    @Query("SELECT * FROM tasks")
    suspend fun getAllTasks(): List<Task>

    @Query("DELETE FROM tasks")
    suspend fun deleteAll()

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(tasks: List<Task>)
}

@Dao
interface VerseDao {
    @Insert
    suspend fun insert(verse: Verse)

    @Query("SELECT * FROM verses ORDER BY title")
    suspend fun getAll(): List<Verse>

    @Query("DELETE FROM verses")
    suspend fun deleteAll()

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(verses: List<Verse>)
}

@Dao
interface PrayerDao {
    @Insert
    suspend fun insert(prayer: Prayer)

    @Query("SELECT * FROM prayers ORDER BY priority DESC, modifiedAt DESC")
    suspend fun getAll(): List<Prayer>

    @Query("DELETE FROM prayers")
    suspend fun deleteAll()

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(prayers: List<Prayer>)
}