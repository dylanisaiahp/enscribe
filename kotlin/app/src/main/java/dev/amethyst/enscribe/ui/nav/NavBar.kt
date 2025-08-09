package dev.amethyst.enscribe.ui.nav

import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AddBox
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material.icons.rounded.AddBox
import androidx.compose.material.icons.rounded.Notifications
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.R

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

    val homeOutlinedVector = vectorResourceAsImageVector(resId = R.drawable.ic_home_outlined)
    val homeFilledVector = vectorResourceAsImageVector(resId = R.drawable.ic_home_filled)

    val items = listOf(
        NavItem("Home", homeOutlinedVector, homeFilledVector),
        NavItem("Create", Icons.Outlined.AddBox, Icons.Rounded.AddBox),
        NavItem("Log", Icons.Outlined.Notifications, Icons.Rounded.Notifications),
        NavItem("Settings", Icons.Outlined.Settings, Icons.Rounded.Settings),
    )

    NavigationBar(
        modifier = Modifier.clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)),
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

@Composable
fun vectorResourceAsImageVector(resId: Int): ImageVector {
    return ImageVector.vectorResource(id = resId)
}
