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
app.kubernetes.io/name: dex-app
helm.sh/chart: {{ include "dex.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/component: dex
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: dex-app
giantswarm.io/service-type: "managed"
{{- end -}}

{{- define "dexauthenticator.labels" -}}
app.kubernetes.io/name: dex-app
helm.sh/chart: {{ include "dex.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: dex-k8s-authenticator
app: dex-app
giantswarm.io/service-type: "managed"
{{- end -}}
