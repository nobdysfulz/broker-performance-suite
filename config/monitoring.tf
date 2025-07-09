# Google Cloud Monitoring Configuration

# Cloud Run Service Monitoring
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "High Error Rate - My App"
  combiner     = "OR"

  conditions {
    display_name = "Error rate > 5%"

    condition_threshold {
      filter          = "resource.type=cloud_run_revision AND resource.labels.service_name=my-app"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.05
      duration        = "300s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email.name
  ]
}

resource "google_monitoring_alert_policy" "high_latency" {
  display_name = "High Latency - My App"
  combiner     = "OR"

  conditions {
    display_name = "95th percentile latency > 2s"

    condition_threshold {
      filter          = "resource.type=cloud_run_revision AND resource.labels.service_name=my-app"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 2000
      duration        = "300s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_PERCENTILE_95"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email.name
  ]
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification"
  type         = "email"

  labels = {
    email_address = "admin@your-domain.com"
  }
}
