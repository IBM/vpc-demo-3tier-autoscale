resource "sysdig_monitor_dashboard" "dashboard" {
  for_each = {for dashboard in var.dashboards : dashboard.name => dashboard}
  name        = each.value.name
  description = each.value.description

  dynamic "scope" {
    for_each = each.value.scope
    content {
      metric = scope.value.metric
      variable = scope.value.variable
    }
  }

  dynamic "panel" {
    for_each = each.value.panel 
    content {
      pos_x       = panel.value.pos_x
      pos_y       = panel.value.pos_y
      width       = panel.value.width
      height      = panel.value.height
      type        = panel.value.type
      name        = panel.value.name
      description = panel.value.description
      dynamic "query" {
        for_each = panel.value.query
        content {
          promql = query.value.promql
          unit = query.value.unit

        }
      }

    }
  }
}