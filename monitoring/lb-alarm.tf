#BWS LB
resource "aws_cloudwatch_metric_alarm" "bws_lb_unhealthy_hosts" {
  alarm_name                = "${local.environment_name}__UnHealthyHostCount__alert__BWS__${local.bws_lb_name}-lb"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "The BWS loadbalancer ${local.bws_lb_name} has 1 Unhealthy host. Please contact the MIS Team or the MIS AWS Support contact"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
              LoadBalancerName  = "${local.bws_lb_name}"
  }
}


resource "aws_cloudwatch_metric_alarm" "bws_lb_latency" {
  alarm_name                = "${local.environment_name}__Latency__alert__BWS__${local.bws_lb_name}-lb"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Latency"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "The BWS loadbalancer ${local.bws_lb_name} is averaging on high latency. Please contact the MIS AWS Support contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.bws_lb_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "bws_lb_spillovercount" {
  alarm_name                = "${local.environment_name}__SpilloverCount__severe__BWS__${local.bws_lb_name}-lb"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "SpilloverCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "The BWS loadbalancer ${local.bws_lb_name} is averaging a spillover count of 1. Please contact the MIS AWS Support contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.bws_lb_name}"
  }
}


resource "aws_cloudwatch_metric_alarm" "ses_auth_fail" {
  alarm_name                = "${local.environment_name}__SesAuthenticationFail__critical__SMTP"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.SesAuthenticationFail.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "The SMTP Server has failed to authenticate to AWS SES. Emails will not be delivered!. Please contact the AWS Support Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}


resource "aws_cloudwatch_log_metric_filter" "SesAuthenticationFail" {
  name           = "SesAuthenticationFail"
  pattern        = "535 Authentication Credentials Invalid"
  log_group_name = "${var.short_environment_identifier}/smtp_logs"

  metric_transformation {
    name      = "EventCount"
    namespace = "smtp"
    value     = "1"
  }
}


#Nextcloud LB

resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_unhealthy_hosts" {
  alarm_name                = "${local.environment_name}__UnHealthyHostCount__alert__NEXTCLOUD__${local.nextcloud_lb_name}-lb"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "The NEXTCLOUD loadbalancer ${local.nextcloud_lb_name} has 1 Unhealthy host. Please contact the MIS AWS Support contact"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
              LoadBalancerName  = "${local.nextcloud_lb_name}"
  }
}


resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_latency" {
  alarm_name                = "${local.environment_name}__Latency__alert__NEXTCLOUD__${local.nextcloud_lb_name}-lb"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Latency"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "The NEXTCLOUD loadbalancer ${local.nextcloud_lb_name} is averaging on high latency. Please contact the MIS Team or the MIS AWS Support contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.nextcloud_lb_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_spillovercount" {
  alarm_name                = "${local.environment_name}__SpilloverCount__severe__NEXTCLOUD__${local.nextcloud_lb_name}-lb"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "SpilloverCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "The NEXTCLOUD loadbalancer ${local.nextcloud_lb_name} is averaging a spillover count of 1. Please contact the MIS AWS Support contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.nextcloud_lb_name}"
  }
}
