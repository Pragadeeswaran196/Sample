locals {
  lines = split("\n", file("visble_msg.txt"))
  non_empty_lines = [
    for line in local.lines : line if trimspace(line) != ""
  ]

  Queue = [
    for line in local.non_empty_lines : {
      Queue_name = split(",", line)[0]
      Threshold  = length(split(",", line)) >= 2 ? split(",", line)[1] : ""
      sustain    = length(split(",", line)) >= 3 ? split(",", line)[2] : ""
    }
  ]
}
resource "chronosphere_monitor" "jenkins-test1-new" {
  name                   = "testing-jenkins-terraform-new"
  slug                   = "testing-jenkins-terraform-new"
  bucket_id              = "techops-prod-alerts"
  notification_policy_id = "techops-prod-alerts"

  query {
    prometheus_expr = "(aws_sqs_approximate_number_of_messages_visible_average{tag_env=\"prod\",dimension_QueueName!~\".*dlq*.\"})"
  }

  series_conditions {
    condition {
      op       = "GT"
      severity = "critical"
      sustain  = "10m"
      value    = 1000000
    }    
    dynamic "override" {
      for_each = { for queue in local.Queue : queue.Queue_name => queue }

      content {
        condition {
          op       = "GT"
          severity = "critical"
          sustain  = override.value.sustain
          value    = override.value.Threshold
        }

        label_matcher {
          name  = "dimension_QueueName"
          type  = "EXACT"
          value = override.value.Queue_name
        }
      }
    }
  }
  annotations = {
    SOP = "https://fourkites.atlassian.net/wiki/spaces/TECHOPS/pages/909705503/SQS"
  }
  interval = "1m"
  labels = {
    Comp      = "SQS"
    Env       = "Prod"
    Terraform = "True"
  }
  signal_grouping {
    label_names = ["tag_env", "dimension_QueueName"]
  }
}
