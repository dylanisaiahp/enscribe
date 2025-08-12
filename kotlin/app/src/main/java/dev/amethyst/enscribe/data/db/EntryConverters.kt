package dev.amethyst.enscribe.data.db

import androidx.room.TypeConverter
import dev.amethyst.enscribe.ui.theme.EnscribeTheme

/**
 * Encapsulates reminder details for an entry.
 *
 * @param timeMillis when the notification should fire (epoch ms)
 * @param repeatInterval NONE, DAILY, WEEKLY or CUSTOM
 * @param isActive whether the reminder is currently enabled
 */
data class Reminder(
    val timeMillis: Long,
    val repeatInterval: RepeatType,
    val isActive: Boolean,
)

enum class RepeatType {
    NONE,
    DAILY,
    WEEKLY,
    CUSTOM,
}

object SettingsConverters {
    @TypeConverter
    fun fromEnscribeTheme(theme: EnscribeTheme): String {
        return theme.name
    }

    @TypeConverter
    fun toEnscribeTheme(themeName: String): EnscribeTheme {
        return EnscribeTheme.valueOf(themeName)
    }
}

/**
 * Room TypeConverter for Reminder and checklist fields.
 */
object EntryConverters {
    @TypeConverter
    @JvmStatic
    fun fromReminder(reminder: Reminder?): String? =
        reminder
            ?.let { "${it.timeMillis}|${it.repeatInterval.name}|${it.isActive}" }

    @TypeConverter
    @JvmStatic
    fun toReminder(data: String?): Reminder? {
        if (data.isNullOrBlank()) return null
        val parts = data.split("|")
        val time = parts.getOrNull(0)?.toLongOrNull() ?: return null
        val repeat =
            parts
                .getOrNull(1)
                ?.let { name -> RepeatType.entries.firstOrNull { it.name == name } }
                ?: RepeatType.NONE
        val active = parts.getOrNull(2)?.toBooleanStrictOrNull() ?: false

        return Reminder(timeMillis = time, repeatInterval = repeat, isActive = active)
    }

    // List<String> converters for checklist
    @TypeConverter
    @JvmStatic
    fun fromStringList(list: List<String>?): String? =
        list?.joinToString(separator = "|::|") // safer delimiter than |

    @TypeConverter
    @JvmStatic
    fun toStringList(data: String?): List<String> =
        data?.takeIf { it.isNotBlank() }?.split("|::|") ?: emptyList()
}
