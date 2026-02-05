{{/*
Expand the name of the chart.
*/}}
{{- define "dex.name" -}}
dex
{{- end }}

{{/*
Namespace for all resources to be installed into
If not defined in values file then the helm release namespace is used
By default this is not set so the helm release namespace will be used

This gets around an problem within helm discussed here
https://github.com/helm/helm/issues/5358
*/}}
{{- define "dex.namespace" -}}
{{ .Values.namespaceOverride | default (.Release.Namespace | trunc 63 | trimSuffix "-") }}
{{- end -}}

{{/*
    Override the namespace for the serviceMonitor

    Fallback to the namespaceOverride if serviceMonitor.namespace is not set
*/}}
{{- define "dex.serviceMonitor.namespace" -}}
{{- if .Values.serviceMonitor.namespace }}
{{- .Values.serviceMonitor.namespace -}}
{{- else }}
{{- template "dex.namespace" . -}}
{{- end }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dex.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

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
helm.sh/chart: {{ include "dex.chart" . }}
{{ include "dex.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}
giantswarm.io/service-type: "managed"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dex.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dex.name" . }}
app.kubernetes.io/component: {{ include "dex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dex.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dex.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret containing the config file to use
*/}}
{{- define "dex.configSecretName" -}}
{{- if .Values.configSecret.create }}
{{- default (include "dex.fullname" .) .Values.configSecret.name }}
{{- else }}
{{- default "default" .Values.configSecret.name }}
{{- end }}
{{- end }}

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
{{- $ok = or $ok (ne (len $v.address) 0) -}}
{{- end -}}
{{- end -}}
{{- printf "%v" $ok -}}
{{- end -}}

### GS-Helpers
{{/*
Before trying to contribute this file to upstream, please read below.
This helpers file contains Giant Swarm specific overrides to helpers defined
in the original upstream _helpers.tpl file.
*/}}

{{/*
Labels that should be added on each resource
*/}}
{{- define "labels" -}}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
giantswarm.io/service-type: "managed"
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}
{{- if eq (default "helm" .Values.creator) "helm" }}
helm.sh/chart: {{ include "chartName" . }}
{{- end -}}
{{- end -}}

{{/*
Override for original helper because Giant Swarm cert-manager chart v2 label selectors are different
*/}}
{{- define "cainjector.name" -}}
{{- printf "%s" (include "cert-manager.name" .) -}}
{{- end -}}

{{/*
Override for original helper because Giant Swarm cert-manager chart v2 label selectors are different
*/}}
{{- define "webhook.name" -}}
{{- printf "%s" (include "cert-manager.name" .) -}}
{{- end -}}

{{- define "registry" }}
{{- $registry := .Values.image.registry -}}
{{- if and .Values.global (and .Values.global.image .Values.global.image.registry) -}}
{{- $registry = .Values.global.image.registry -}}
{{- end -}}
{{- printf "%s" $registry -}}
{{- end -}}
{{/*

{{/*
Common dex labels
*/}}
{{- define "dex.labels.common" -}}
{{ include "dex.labels.selector" . }}
helm.sh/chart: {{ include "dex.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}
giantswarm.io/service-type: "managed"
{{- end -}}