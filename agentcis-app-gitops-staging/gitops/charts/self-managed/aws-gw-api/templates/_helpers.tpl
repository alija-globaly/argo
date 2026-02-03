{{/*
Expand the name of the chart.
*/}}
{{- define "aws-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "aws-gateway.labels" -}}
helm.sh/chart: {{ include "aws-gateway.chart" . }}
{{ include "aws-gateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "aws-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aws-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Gateway name (SHORT helper)
*/}}
{{- define "aws-gateway.gatewayName" -}}
{{- .Values.gateway.https_mode.k8s_api_gateway.name | default (printf "%s-gateway" .Release.Name) }}
{{- end }}

{{/*
ALB Config name (SHORT helper)
*/}}
{{- define "aws-gateway.albConfigName" -}}
{{- .Values.gateway.https_mode.aws_alb_config.name | default (printf "%s-lbconfig" .Release.Name) }}
{{- end }}

{{/*
Listener HTTP namespaces (SHORT helper)
*/}}
{{- define "aws-gateway.listenerHttpNamespaces" -}}
{{- .Values.gateway.https_mode.k8s_api_gateway.listener_http_namespaces | default "All" }}
{{- end }}

{{/*
Listener HTTPS namespaces (SHORT helper)
*/}}
{{- define "aws-gateway.listenerHttpsNamespaces" -}}
{{- .Values.gateway.https_mode.k8s_api_gateway.listener_https_namespaces | default "All" }}
{{- end }}

{{/*
Gateway ClassName (SHORT helper)
*/}}
{{- define "aws-gateway.gatewayClassName" -}}
{{- .Values.gateway.https_mode.k8s_api_gateway.gatewayClassName }}
{{- end }}

{{/*
Default Certificate (SHORT helper)
*/}}
{{- define "aws-gateway.defaultCertificate" -}}
{{- .Values.gateway.https_mode.aws_alb_config.defaultCertificate | quote }}
{{- end }}

{{/*
HTTPS Mode enabled check (SHORT helper)
*/}}
{{- define "aws-gateway.httpsModeEnabled" -}}
{{- .Values.gateway.https_mode.enabled }}
{{- end }}
{{/*
HTTPRoute redirect name
*/}}
{{- define "aws-gateway.httpRedirectName" -}}
{{- .Values.gateway.https_mode.http_to_https_redirect.name | default (printf "%s-http-redirect" .Release.Name) }}
{{- end }}
