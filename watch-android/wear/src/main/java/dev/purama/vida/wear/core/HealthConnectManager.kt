package dev.purama.vida.wear.core

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.aggregate.AggregateMetric
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.MindfulnessSessionRecord
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import java.time.Duration
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

/**
 * P8-F6 — Acces Health Connect cote Wear OS. Equivalent Android du
 * HealthKitManager.swift.
 *
 * Surface : requestPermissions, currentSnapshot. Mindful session ecriture
 * en F7 via RitualTimerScreen (post-start/stop).
 */
class HealthConnectManager(private val context: Context) {

    private val client: HealthConnectClient? by lazy {
        runCatching { HealthConnectClient.getOrCreate(context) }.getOrNull()
    }

    val isAvailable: Boolean get() = client != null

    val requiredPermissions: Set<String> = setOf(
        HealthPermission.getReadPermission(StepsRecord::class),
        HealthPermission.getReadPermission(HeartRateRecord::class),
        HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
        HealthPermission.getReadPermission(MindfulnessSessionRecord::class),
        HealthPermission.getReadPermission(SleepSessionRecord::class),
    )

    suspend fun hasAllPermissions(): Boolean {
        val c = client ?: return false
        val granted = c.permissionController.getGrantedPermissions()
        return granted.containsAll(requiredPermissions)
    }

    suspend fun currentSnapshot(): HealthSnapshot {
        val c = client ?: return HealthSnapshot.ZERO
        if (!hasAllPermissions()) return HealthSnapshot.ZERO

        val zone = ZoneId.systemDefault()
        val startOfToday = LocalDate.now(zone).atStartOfDay(zone).toInstant()
        val now = Instant.now()
        val todayFilter = TimeRangeFilter.between(startOfToday, now)

        val steps = readSum(c, StepsRecord.COUNT_TOTAL, todayFilter)?.toInt() ?: 0
        val calories = readSum(
            c, ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL, todayFilter,
        ) ?: 0.0
        val mindful = readMindfulMinutes(c, todayFilter)
        val hr = readLatestHeartRate(c)
        val sleepHours = readSleepHoursLastNight(c, zone)

        return HealthSnapshot(
            stepsToday = steps,
            heartRateBpm = hr,
            mindfulMinutesToday = mindful,
            activeCaloriesToday = calories,
            sleepHoursLastNight = sleepHours,
        )
    }

    @Suppress("UNCHECKED_CAST")
    private suspend fun <T : Any> readSum(
        client: HealthConnectClient,
        metric: AggregateMetric<T>,
        filter: TimeRangeFilter,
    ): Double? = runCatching {
        val result = client.aggregate(
            AggregateRequest(metrics = setOf(metric), timeRangeFilter = filter),
        )
        when (val v = result[metric]) {
            is androidx.health.connect.client.units.Energy -> v.inKilocalories
            is Long -> v.toDouble()
            is Number -> v.toDouble()
            else -> null
        }
    }.getOrNull()

    private suspend fun readMindfulMinutes(
        client: HealthConnectClient,
        filter: TimeRangeFilter,
    ): Int = runCatching {
        val response = client.readRecords(
            ReadRecordsRequest(MindfulnessSessionRecord::class, filter),
        )
        response.records.sumOf { rec ->
            Duration.between(rec.startTime, rec.endTime).toMinutes().toInt()
        }
    }.getOrDefault(0)

    private suspend fun readLatestHeartRate(client: HealthConnectClient): Double? = runCatching {
        val now = Instant.now()
        val oneHourAgo = now.minus(Duration.ofHours(1))
        val response = client.readRecords(
            ReadRecordsRequest(
                HeartRateRecord::class,
                TimeRangeFilter.between(oneHourAgo, now),
            ),
        )
        response.records
            .flatMap { it.samples }
            .maxByOrNull { it.time }
            ?.beatsPerMinute
            ?.toDouble()
    }.getOrNull()

    private suspend fun readSleepHoursLastNight(
        client: HealthConnectClient,
        zone: ZoneId,
    ): Double? = runCatching {
        val noonToday = LocalDate.now(zone).atTime(12, 0).atZone(zone).toInstant()
        val previousEvening = noonToday.minus(Duration.ofHours(18))
        val response = client.readRecords(
            ReadRecordsRequest(
                SleepSessionRecord::class,
                TimeRangeFilter.between(previousEvening, noonToday),
            ),
        )
        val seconds = response.records.sumOf {
            Duration.between(it.startTime, it.endTime).seconds
        }
        if (seconds == 0L) null else seconds / 3_600.0
    }.getOrNull()
}
