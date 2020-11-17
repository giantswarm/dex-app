{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
dex-app-customer
{{- end -}}

{{/*
Create chart name and version as used by the chart label. 
*/}}
{{- define "dex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "dex.labels" -}}
{{ include "labels.selector" . }}
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
app.kubernetes.io/name: {{ include "name" . }}
app.kubernetes.io/component: {{ include "name" . }}-server
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{- define "dexauthenticator.labels" -}}
{{ include "labels.selector" . }}
helm.sh/chart: {{ include "dex.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
giantswarm.io/service-type: "managed"
{{- end -}}

{{/*
Selector dex labels
*/}}
{{- define "dexauthenticator.labels.selector" -}}
app.kubernetes.io/name: {{ include "name" . }}
app.kubernetes.io/component: {{ include "name" . }}-client
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

