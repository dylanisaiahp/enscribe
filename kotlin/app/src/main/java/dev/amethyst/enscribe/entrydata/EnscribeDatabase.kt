package dev.amethyst.enscribe.entrydata

import android.content.Context
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import kotlinx.coroutines.flow.Flow

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
    // Change the return type to Flow<SettingsEntity>
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
        Entry.Note::class,
        Entry.Task::class,
        Entry.Verse::class,
        Entry.Prayer::class,
        SettingsEntity::class
    ],
    version = 5,
    exportSchema = true,
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
                    .fallbackToDestructiveMigration(true) // Remove in production, use migration
                    .build()
                    .also { INSTANCE = it }
            }
    }
}

/**
 * DAO interfaces for entries.
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
