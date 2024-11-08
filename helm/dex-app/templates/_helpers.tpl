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
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
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

{{/*
Abstract the knowledge to know if it needs a Giant Swarm connector or not
*/}}
{{- define "has-giantswarm-connector" -}}
{{- if .Values.oidc.giantswarm.connectorConfig.clientID -}}
  {{- printf "true" }}
{{- else -}}
  {{- printf "false" }}
{{- end -}}
{{- end -}}

{{/*
Abstract the knowledge to know if its installed on a workload cluster or not
*/}}
{{- define "is-workload-cluster" -}}
{{- if .Values.isWorkloadCluster -}}
  {{- printf "true" }}
{{- else if .Values.isManagementCluster -}}
  {{- printf "false" }}
{{- else if and .Values.baseDomain .Values.clusterID -}}
  {{- printf "true" }}
{{- else -}}
  {{- printf "false" }}
{{- end -}}
{{- end -}}

{{/*
Gather and print trusted peers of a static client from various sources
*/}}
{{- define "trusted-peers" -}}
  {{- if . }}
    {{- $trustedPeers := uniq ( compact . ) -}}
    {{- if $trustedPeers }}
      {{- print "trustedPeers:" | nindent 6 -}}
      {{- if $trustedPeers -}}
        {{- $trustedPeers | toYaml | nindent 6 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Clean up and print extra static clients
*/}}
{{- define "print-clean-extra-static-clients" -}}
  {{- if . }}
    {{- $extraStaticClients := list nil -}}
    {{- range . -}}
      {{- $extraStaticClients = append $extraStaticClients (omit . "trustedPeerOf") -}}
    {{- end -}}
    {{- compact $extraStaticClients | toYaml | nindent 4 -}}
  {{- end -}}
{{- end -}}

{{/*
Checks if any services in addition to Kubernetes are defined in values
*/}}
{{- define "is-any-service-listed" -}}
{{- $ok := false -}}
{{- range $k, $v := .Values.services -}}
{{- if ne $k "kubernetes" }}
{{- $ok = or $ok (ne $v.address "") -}}
{{- end -}}
{{- end -}}
{{- printf "%v" $ok -}}
{{- end -}}
