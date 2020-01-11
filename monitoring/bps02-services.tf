resource "aws_cloudwatch_metric_alarm" "PROCTIER002_AdaptiveJobServer" {
  alarm_name                = "${local.environment_name}__PROCTIER002.AdaptiveJobServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002AdaptiveJobServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.AdaptiveJobServer Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_AdaptiveJobServer" {
 name           = "PROCTIER002AdaptiveJobServerCount"
 pattern        = "${local.exclude_log_level} PROCTIER002.AdaptiveJobServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002AdaptiveJobServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER002_APS_Webi" {
  alarm_name                = "${local.environment_name}__PROCTIER002.APS.Webi__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002APSWebiCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.APS.Webi Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_APS_Webi" {
 name           = "PROCTIER002APSWebiCount"
 pattern        = "${local.exclude_log_level} PROCTIER002.APS.Webi"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002APSWebiCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER002_ConnectionServer" {
  alarm_name                = "${local.environment_name}__PROCTIER002.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002ConnectionServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.ConnectionServer Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_ConnectionServer" {
 name           = "PROCTIER002ConnectionServerCount"
 pattern        = "${local.exclude_log_level} PROCTIER002.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002ConnectionServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER002_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__PROCTIER002.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002ConnectionServer32Count"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.ConnectionServer32 Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_ConnectionServer32" {
 name           = "PROCTIER002ConnectionServer32Count"
 pattern        = "${local.exclude_log_level} PROCTIER002.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002ConnectionServer32Count"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER002_WebIntelligenceProcessingServer" {
  alarm_name                = "${local.environment_name}__PROCTIER002.WebIntelligenceProcessingServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002WebIntelligenceProcessingServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.WebIntelligenceProcessingServer Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_WebIntelligenceProcessingServer" {
 name           = "PROCTIER002WebIntelligenceProcessingServerCount"
 pattern        = "${local.exclude_log_level} PROCTIER002.WebIntelligenceProcessingServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002WebIntelligenceProcessingServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

##PROCTIER002.WebIntelligenceProcessingServer OK ALARM
resource "aws_cloudwatch_metric_alarm" "PROCTIER002_WebIntelligenceProcessingServer_OK" {
  alarm_name                = "${local.environment_name}__PROCTIER002.WebIntelligenceProcessingServer__OK"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002WebIntelligenceProcessingServerCount_OK"
  namespace                 = "${local.name_space}"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.WebIntelligenceProcessingServer Service in Error state on ndl-bps-002. If no OK alarm is recieved in a few minutes, please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_WebIntelligenceProcessingServer_OK" {
 name           = "PROCTIER002WebIntelligenceProcessingServerCount_OK"
 pattern        = "INFORMATION PROCTIER002.WebIntelligenceProcessingServer has been started"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002WebIntelligenceProcessingServerCount_OK"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER002_WebIntelligenceProcessingServer1" {
  alarm_name                = "${local.environment_name}__PROCTIER002.WebIntelligenceProcessingServer1__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002WebIntelligenceProcessingServer1Count"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.WebIntelligenceProcessingServer1 Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_WebIntelligenceProcessingServer1" {
 name           = "PROCTIER002WebIntelligenceProcessingServer1Count"
 pattern        = "${local.exclude_log_level} PROCTIER002.WebIntelligenceProcessingServer1"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002WebIntelligenceProcessingServer1Count"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

##PROCTIER002.WebIntelligenceProcessingServer1 OK ALARM
resource "aws_cloudwatch_metric_alarm" "PROCTIER002_WebIntelligenceProcessingServer1_OK" {
  alarm_name                = "${local.environment_name}__PROCTIER002.WebIntelligenceProcessingServer1__OK"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER002WebIntelligenceProcessingServer1Count_OK"
  namespace                 = "${local.name_space}"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.WebIntelligenceProcessingServer1 Service in Error state on ndl-bps-002. If no OK alarm is recieved in a few minutes, please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_WebIntelligenceProcessingServer1_OK" {
 name           = "PROCTIER002WebIntelligenceProcessingServer1Count_OK"
 pattern        = "INFORMATION PROCTIER002.WebIntelligenceProcessingServer1 has been started"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER002WebIntelligenceProcessingServer1Count_OK"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
