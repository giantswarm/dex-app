{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
dex-k8s-authenticator-customer
{{- end -}}

{{/*
Create chart name and version as used by the chart label. 
*/}}
{{- define "dex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "labels.common" -}}
{{ include "labels.selector" . }}
helm.sh/chart: {{ include "dex.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
giantswarm.io/service-type: "managed"
{{- end -}}

{{/*
Selector dex labels
*/}}
{{- define "labels.selector" -}}
app.kubernetes.io/name: {{ include "name" . }}
app.kubernetes.io/component: {{ include "name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

