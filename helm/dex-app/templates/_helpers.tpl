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
Helpers for dex-k8s-authenticator.
*/}}
{{- define "dexk8sauth.customer.name" -}}
dex-k8s-authenticator
{{- end -}}

{{/*
Common dex-k8s-authenticator labels
*/}}
{{- define "dexk8sauth.labels.common" -}}
helm.sh/chart: {{ include "dex.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
giantswarm.io/service-type: "managed"
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Selector dex-k8s-authenticator customer labels
*/}}
{{- define "dexk8sauth.customer.labels.selector" -}}
app.kubernetes.io/name: dex-k8s-authenticator-customer
app.kubernetes.io/component: dex-k8s-authenticator-customer
{{- end -}}

{{/*
Selector dex-k8s-authenticator giantswarm labels
*/}}
{{- define "dexk8sauth.giantswarm.labels.selector" -}}
app.kubernetes.io/name: dex-k8s-authenticator-giantswarm
app.kubernetes.io/component: dex-k8s-authenticator-giantswarm
{{- end -}}

{{- define "giantswarm-connector" -}}
{{- if .Values.oidc.giantswarm.connectorConfig.clientID -}}
  {{- printf "true" }}
{{- else -}}
  {{- printf "false" }}
{{- end -}}
{{- end -}}
