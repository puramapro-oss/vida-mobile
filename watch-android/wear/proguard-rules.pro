# Keep Compose runtime reflection-accessed types.
-keep class androidx.compose.runtime.** { *; }

# Health Connect data types are reflectively parsed.
-keep class androidx.health.connect.client.records.** { *; }

# Tiles / Complications services are instantiated by the OS.
-keep class dev.purama.vida.wear.tiles.** { *; }
-keep class dev.purama.vida.wear.complications.** { *; }

# Wearable DataClient payload classes.
-keep class dev.purama.vida.wear.data.** { *; }
