locals {
  verification_error_pattern = "Verification failed"
  error_pattern              = "ERROR"
  datasync_log_group         = aws_cloudwatch_log_group.s3_to_efs.name
  sns_topic_arn              = data.terraform_remote_state.monitoring.outputs.sns_topic_arn
  name_space                 = "LogMetrics"
  dfi_instance_ids           = aws_instance.dfi_server.*.id
  dfi_primary_dns_ext        = aws_route53_record.dfi_dns_ext.*.fqdn
  dfi_ami_id                 = aws_instance.dfi_server.*.ami
  dfi_instance_type          = aws_instance.dfi_server.*.instance_type
  dfi_lb_name                = element(concat(aws_elb.dfi.*.id, [""]), 0)
}

#--------------------------------------------------------
#Datasync alerts
#--------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "datasync_error_alert" {
  alarm_name          = "${var.environment_name}__datasync_error__alert__DFI_Datasync"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DataSyncErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Datasync Error, DFI File transfer error. May affect DFI ETL run. Please review log group ${local.datasync_log_group}"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "datasync_error_alert" {
  name           = "DataSyncErrorCount"
  pattern        = local.error_pattern
  log_group_name = local.datasync_log_group

  metric_transformation {
    name      = "DataSyncErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "datasync_verification_alert" {
  alarm_name          = "${var.environment_name}__datasync_verification_error__alert__DFI_Datasync"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DataSyncVerificationErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "DFI Datasync Verification Error. Please review log group ${local.datasync_log_group}"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "datasync_verification_alert" {
  name           = "DataSyncVerificationErrorCount"
  pattern        = local.error_pattern
  log_group_name = local.datasync_log_group

  metric_transformation {
    name      = "DataSyncVerificationErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}


#--------------------------------------------------------
# CPU Alert
#--------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "dfi_cpu_critical" {
  count = length(
    local.dfi_instance_ids,
  )
  alarm_name          = "${var.environment_name}__CPU-Utilization__critical__DFI__${local.dfi_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "CPU utilization is averaging 92% for ${local.dfi_primary_dns_ext[count.index]}. Please note: During the ETL Run it is normal for resource usage to be high, daily between 18:30-00:00 & 01:00-05:30 when this can be ignored. Otherwise contact the MIS Team or AWS Support Contact."
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]

  dimensions = {
    InstanceId = local.dfi_instance_ids[count.index]
  }
}

#--------------------------------------------------------
#Disk Usage Alert
#--------------------------------------------------------
module "dfi" {
  source             = "../modules/disk-usage-alarms/"
  component          = "DFI"
  objectname         = "LogicalDisk"
  alert_threshold    = "25"
  critical_threshold = "5"
  period             = "60"
  environment_name   = var.environment_name
  instance_ids       = local.dfi_instance_ids
  primary_dns_ext    = local.dfi_primary_dns_ext
  ami_id             = local.dfi_ami_id
  instance_type      = local.dfi_instance_type
  sns_topic          = local.sns_topic_arn
}

#--------------------------------------------------------
#Instance Health Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_instance-health-check" {
  count = length(
    local.dfi_instance_ids,
  )
  alarm_name          = "${var.environment_name}__StatusCheckFailed__critical__DIS__${local.dfi_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "EC2 Health status failed for ${local.dfi_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]

  dimensions = {
    InstanceId = local.dfi_instance_ids[count.index]
  }
}



#--------------------------------------------------------
#DFI LB Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_lb_unhealthy_hosts_critical" {
count = length(
  local.dfi_instance_ids,
)
  alarm_name          = "${var.environment_name}__UnHealthyHostCount__critical__DFI__${local.dfi_lb_name}-lb"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "The DFI loadbalancer ${local.dfi_lb_name} has 1 Unhealthy host. Please contact the MIS Team or the MIS AWS Support contact"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]

  dimensions = {
    LoadBalancerName = local.dfi_lb_name
  }
}

#--------------------------------------------------------
#DFI Memory Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_instance-memory-critical" {
  count = length(
    local.dfi_instance_ids,
  )
  alarm_name          = "${var.environment_name}__Memory-Utilization__critical__DFI__${local.dfi_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${local.dfi_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]

  dimensions = {
    InstanceId   = local.dfi_instance_ids[count.index]
    ImageId      = local.dfi_ami_id[count.index]
    InstanceType = local.dfi_instance_type[count.index]
    objectname   = "Memory"
  }
}
