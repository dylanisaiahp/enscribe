package dev.amethyst.enscribe.ui.nav

import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AddBox
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material.icons.rounded.AddBox
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.Notifications
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.NavigationRail
import androidx.compose.material3.NavigationRailItem
import androidx.compose.material3.NavigationRailItemDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp

enum class NavBarPosition {
    Top,
    Bottom,
    Left,
    Right
}

@Composable
fun NavBar(
    selectedIndex: Int,
    onItemSelected: (Int) -> Unit,
    navBarPosition: NavBarPosition = NavBarPosition.Bottom,
    accentColor: Color = MaterialTheme.colorScheme.tertiary
) {
    data class NavItem(
        val label: String,
        val iconOutlined: ImageVector,
        val iconRounded: ImageVector
    )

    val items = listOf(
        NavItem("Home", Icons.Outlined.Home, Icons.Rounded.Home),
        NavItem("Create", Icons.Outlined.AddBox, Icons.Rounded.AddBox),
        NavItem("Log", Icons.Outlined.Notifications, Icons.Rounded.Notifications),
        NavItem("Settings", Icons.Outlined.Settings, Icons.Rounded.Settings),
    )

    when (navBarPosition) {
        NavBarPosition.Top -> {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.secondary,
            ) {
                items.forEachIndexed { index, item ->
                    NavigationBarItem(
                        icon = {
                            Icon(
                                imageVector = if (selectedIndex == index) item.iconRounded else item.iconOutlined,
                                contentDescription = item.label,
                                modifier = Modifier.size(28.dp),
                            )
                        },
                        label = {
                            if (selectedIndex == index)
                                Text(
                                    item.label,
                                    modifier = Modifier.offset(0.dp, (-8).dp)
                                )
                            else null
                        },
                        selected = selectedIndex == index,
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

        NavBarPosition.Bottom -> {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.secondary,
            ) {
                items.forEachIndexed { index, item ->
                    NavigationBarItem(
                        icon = {
                            Icon(
                                imageVector = if (selectedIndex == index) item.iconRounded else item.iconOutlined,
                                contentDescription = item.label,
                                modifier = Modifier.size(28.dp),
                            )
                        },
                        label = {
                            if (selectedIndex == index)
                                Text(
                                    item.label,
                                    modifier = Modifier.offset(0.dp, (-8).dp)
                                )
                            else null
                        },
                        selected = selectedIndex == index,
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

        NavBarPosition.Left -> {
            Surface(
                shape = RoundedCornerShape(topEnd = 32.dp, bottomEnd = 32.dp),
            ) {
                NavigationRail(
                    containerColor = MaterialTheme.colorScheme.secondary,
                ) {
                    items.forEachIndexed { index, item ->
                        NavigationRailItem(
                            icon = {
                                Icon(
                                    imageVector = if (selectedIndex == index) item.iconRounded else item.iconOutlined,
                                    contentDescription = item.label,
                                    modifier = Modifier.size(28.dp),
                                )
                            },
                            label = {
                                if (selectedIndex == index)
                                    Text(
                                        item.label,
                                        modifier = Modifier.offset(0.dp, (-8).dp)
                                    )
                                else null
                            },
                            selected = selectedIndex == index,
                            onClick = { onItemSelected(index) },
                            alwaysShowLabel = false,
                            colors = NavigationRailItemDefaults.colors(
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

        NavBarPosition.Right -> {
            Surface(
                shape = RoundedCornerShape(topStart = 32.dp, bottomStart = 32.dp),
            ) {
                NavigationRail(
                    containerColor = MaterialTheme.colorScheme.secondary,
                ) {
                    items.forEachIndexed { index, item ->
                        NavigationRailItem(
                            icon = {
                                Icon(
                                    imageVector = if (selectedIndex == index) item.iconRounded else item.iconOutlined,
                                    contentDescription = item.label,
                                    modifier = Modifier.size(28.dp),
                                )
                            },
                            label = {
                                if (selectedIndex == index)
                                    Text(
                                        item.label,
                                        modifier = Modifier.offset(0.dp, (-8).dp)
                                    )
                                else null
                            },
                            selected = selectedIndex == index,
                            onClick = { onItemSelected(index) },
                            alwaysShowLabel = false,
                            colors = NavigationRailItemDefaults.colors(
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
    }
}
