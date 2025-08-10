package dev.amethyst.enscribe.ui.nav

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
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
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp

@Composable
fun NavBar(
    selectedIndex: Int,
    onItemSelected: (Int) -> Unit,
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

    NavigationBar(
        modifier = Modifier
            .height(96.dp)
            .clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)),
        containerColor = MaterialTheme.colorScheme.secondary,
    ) {
        Row(modifier = Modifier.weight(1f)) {
            items.forEachIndexed { index, item ->
                CustomNavBarItem(
                    icon = {
                        Icon(
                            imageVector = if (selectedIndex == index) item.iconRounded else item.iconOutlined,
                            contentDescription = item.label,
                            tint = if (selectedIndex == index) accentColor else MaterialTheme.colorScheme.onSecondary,
                            modifier = if (selectedIndex == index) Modifier.size(32.dp) else Modifier.size(
                                24.dp
                            )
                        )
                    },
                    onClick = { onItemSelected(index) },
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

/**
 * A custom composable that mimics a NavigationBarItem but allows for the ripple effect to be removed.
 */
@Composable
private fun CustomNavBarItem(
    icon: @Composable () -> Unit,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxHeight()
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        icon()
    }
}