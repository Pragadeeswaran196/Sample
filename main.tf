locals {
  LB = [for line in split("\n", file("LB.txt")) : {
    LB_name = split(":", line)[0]
    Threshold = split(":", line)[1]
    sustain = split(":", line)[2]
  }]
}
resource "chronosphere_monitor" "critical_prod_aws_inf_elb_httpcode_elb_5xx_upper_threshold" {
  name                   = "Sample-test | Critical | PROD | AWS INF | ELB |  httpcode_elb_5_xx Count breached Upper Threshold"
  slug                   = "critical-prod-aws-inf-elb-httpcode-elb-5xx-upper-threshold"
  bucket_id              = "techops-prod-alerts"
  notification_policy_id = "techops-prod-alerts"
  query {
    prometheus_expr = "sum by (tag_Name,dimension_LoadBalancerName,tag_env) (aws_elb_httpcode_elb_5_xx_sum{tag_env=\"prod\"})"
  }
  series_conditions {
    condition {
      op       = "GT"
      severity = "critical"
      sustain  = "10m"
      value    = 50
    }
    dynamic "override" {
      for_each = { for lb in local.LB : lb.LB_name => lb }

      content {
        condition {
          op       = "GT"
          severity = "critical"
          sustain  = override.value.sustain
          value    = override.value.Threshold
        }

        label_matcher {
          name  = "tag_Name"
          type  = "EXACT"
          value = override.value.LB_name
        }
      }
    }
  }
  annotations = {
    SOP = "https://fourkites.atlassian.net/wiki/spaces/TECHOPS/pages/629407987/ALB+ELB+5XX+Alert"
  }
  interval = "1m"
  labels = {
    Comp      = "Load-balancer"
    Env       = "Prod"
    Terraform = "True"
  }
  signal_grouping {
    label_names = ["dimension_LoadBalancerName", "tag_env", "tag_Name"]
  }
}
