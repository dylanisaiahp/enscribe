package dev.amethyst.enscribe.ui.nav

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AddBox
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material.icons.rounded.AddBox
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp

@Composable
fun NavBar(
    selectedIndex: Int,
    onItemSelected: (Int) -> Unit,
    accentColor: Color = MaterialTheme.colorScheme.tertiary
) {
    Surface(
        shape = RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp),
        modifier = Modifier.fillMaxWidth(),
    ) {
        NavigationBar(
            modifier = Modifier.fillMaxWidth(),
            containerColor = MaterialTheme.colorScheme.secondary,
        ) {
            data class NavItem(
                val label: String,
                val iconOutlined: ImageVector,
                val iconRounded: ImageVector
            )

            val items = listOf(
                NavItem("Home", Icons.Outlined.Home, Icons.Rounded.Home),
                NavItem("Create", Icons.Outlined.AddBox, Icons.Rounded.AddBox),
                NavItem("Settings", Icons.Outlined.Settings, Icons.Rounded.Settings),
            )

            items.forEachIndexed { index, (_, _) ->
                val selected = selectedIndex == index
                NavigationBarItem(
                    icon = {
                        Icon(
                            imageVector = if (selectedIndex == index) items[index].iconRounded else items[index].iconOutlined,
                            contentDescription = items[index].label,
                            modifier = Modifier.size(28.dp),
                        )
                    },
                    label = {
                        if (selectedIndex == index)
                            Text(
                                items[index].label,
                                modifier = Modifier.offset(0.dp, (-8).dp)
                            )
                        else null
                    },
                    selected = selected,
                    onClick = { onItemSelected(index) },
                    alwaysShowLabel = false,
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = accentColor,
                        unselectedIconColor = MaterialTheme.colorScheme.onSecondary,
                        selectedTextColor = accentColor,
                        unselectedTextColor = MaterialTheme.colorScheme.onSecondary,
                        indicatorColor = Color.Transparent
                    )
                )
            }
        }
    }
}
