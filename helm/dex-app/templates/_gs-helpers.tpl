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
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
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
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
giantswarm.io/service-type: "managed"
{{- end -}}