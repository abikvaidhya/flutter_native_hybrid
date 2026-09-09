package com.abik.vaidhya.flutter_native_hybrid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.BatteryFull
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import kotlin.text.get

class NativeMetricsActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val collector = MetricsCollector(this)

        setContent {
            MaterialTheme {
                NativeMetricsScreen(
                    collector = collector,
                    onBack = { finish() }
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NativeMetricsScreen(
    collector: MetricsCollector,
    onBack: () -> Unit
) {
    var metrics by remember { mutableStateOf(collector.collect()) }

    // Refresh every 2 seconds
    LaunchedEffect(Unit) {
        while (true) {
            delay(2000)
            metrics = collector.collect()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Native Metrics (Compose)") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            item {
                Text(
                    text = "Running fully in Jetpack Compose",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
            }

            val items = listOf(
                MetricItem(
                    title = "Battery",
                    value = "${metrics["batteryLevel"] ?: "–"}%",
                    subtitle = if (metrics["isCharging"] == true) "Charging" else "Not charging",
                    icon = Icons.Default.BatteryFull
                ),
                MetricItem(
                    title = "Available Memory",
                    value = formatBytes(metrics["availableMemory"] as? Long),
                    subtitle = "of ${formatBytes(metrics["totalMemory"] as? Long)}",
                    icon = Icons.Default.Memory
                ),
                MetricItem(
                    title = "Network",
                    value = metrics["networkType"]?.toString() ?: "–",
                    subtitle = if (metrics["isConnected"] == true) "Connected" else "Offline",
                    icon = Icons.Default.Wifi
                ),
                MetricItem(
                    title = "Device",
                    value = metrics["model"]?.toString() ?: "–",
                    subtitle = metrics["manufacturer"]?.toString() ?: "",
                    icon = Icons.Default.PhoneAndroid
                ),
                MetricItem(
                    title = "Android Version",
                    value = metrics["androidVersion"]?.toString() ?: "–",
                    subtitle = "SDK ${metrics["sdkInt"] ?: "–"}",
                    icon = Icons.Default.PhoneAndroid
                ),
            )

            items(items) { item ->
                MetricCard(item)
            }
        }
    }
}

data class MetricItem(
    val title: String,
    val value: String,
    val subtitle: String,
    val icon: ImageVector
)

@Composable
fun MetricCard(item: MetricItem) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Row(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = item.icon,
                contentDescription = null,
                modifier = Modifier.size(32.dp)
            )
            Spacer(modifier = Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(text = item.title, style = MaterialTheme.typography.titleMedium)
                Text(
                    text = item.subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Text(
                text = item.value,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

private fun formatBytes(bytes: Long?): String {
    if (bytes == null) return "–"
    return when {
        bytes < 1024 -> "$bytes B"
        bytes < 1024 * 1024 -> "%.1f KB".format(bytes / 1024.0)
        bytes < 1024 * 1024 * 1024 -> "%.1f MB".format(bytes / (1024.0 * 1024))
        else -> "%.2f GB".format(bytes / (1024.0 * 1024 * 1024))
    }
}