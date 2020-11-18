{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Helpers for dex.
*/}}
{{- define "dex.name" -}}
dex
{{- end -}}

{{/*
Common dex labels
*/}}
{{- define "dex.labels.common" -}}
{{ include "dex.labels.selector" . }}
helm.sh/chart: {{ include "dex.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
giantswarm.io/service-type: "managed"
{{- end -}}

{{/*
Selector dex labels
*/}}
{{- define "dex.labels.selector" -}}
app.kubernetes.io/name: {{ include "dex.name" . }}
app.kubernetes.io/component: {{ include "dex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Helpers for customer dex-k8s-authenticator.
*/}}
{{- define "dexk8sauth.customer.name" -}}
dex-k8s-authenticator-customer
{{- end -}}

{{/*
Common dex labels
*/}}
{{- define "dexk8sauth.customer.labels.common" -}}
{{ include "dexk8sauth.customer.labels.selector" . }}
helm.sh/chart: {{ include "dex.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
giantswarm.io/service-type: "managed"
{{- end -}}

{{/*
Selector dex labels
*/}}
{{- define "dexk8sauth.customer.labels.selector" -}}
app.kubernetes.io/name: {{ include "dexk8sauth.customer.name" . }}
app.kubernetes.io/component: {{ include "dexk8sauth.customer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}