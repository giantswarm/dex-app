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
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | trimSuffix "." | trimSuffix "_" -}}
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
Clean up and print extra static clients. A client declaring its secret as a
reference (`secretRef: {name, key}`) is printed with `secretEnv` naming the
variable the Deployment sets from that Secret; dex reads it at start-up.
*/}}
{{- define "print-clean-extra-static-clients" -}}
  {{- if . }}
    {{- $extraStaticClients := list nil -}}
    {{- range . -}}
      {{- $client := omit . "trustedPeerOf" -}}
      {{- if .secretRef -}}
        {{- $client = set (omit $client "secretRef") "secretEnv" (include "dex.staticClient.secretEnvName" .id) -}}
      {{- end -}}
      {{- $extraStaticClients = append $extraStaticClients $client -}}
    {{- end -}}
    {{- compact $extraStaticClients | toYaml | nindent 4 -}}
  {{- end -}}
{{- end -}}

{{/*
Name of the environment variable carrying a referenced static client secret,
derived from the client id: DEX_CLIENT_SECRET_<id upper-cased, [^A-Za-z0-9] -> _>.
*/}}
{{- define "dex.staticClient.secretEnvName" -}}
DEX_CLIENT_SECRET_{{ regexReplaceAll "[^A-Za-z0-9]" . "_" | upper }}
{{- end -}}

{{/*
The secret line of a pre-defined static client: `secret: <inline value>` or,
for a client declared with `clientSecretRef`, `secretEnv: <variable>`.
Takes a dict with `id` (the client id) and `client` (the client's values).
*/}}
{{- define "dex.staticClient.secretField" -}}
{{- if .client.clientSecretRef -}}
secretEnv: {{ include "dex.staticClient.secretEnvName" .id }}
{{- else -}}
secret: {{ .client.clientSecret }}
{{- end -}}
{{- end -}}

{{/*
The pre-defined static clients that authenticate with a secret, as their values
keys in the order they are validated. The public ones (grafana, gsCLIAuth,
happa) have no secret; dex-k8s-authenticator, always rendered, is handled apart.
*/}}
{{- define "dex.staticClients.confidential" -}}
gitopsui mcpCapi mcpKubernetes mcpPrometheus muster
{{- end -}}

{{/*
Whether a pre-defined static client has a secret source, clientSecret or
clientSecretRef (both at once fails in dex.staticClients.secretRefs). A client
with a clientID and neither is left out of the configuration, as it was before
v3.1.0, and named in NOTES.txt. Takes the client's values; prints "true" or
nothing.
*/}}
{{- define "dex.staticClient.hasSecret" -}}
{{- if or .clientSecret .clientSecretRef }}true{{ end -}}
{{- end -}}

{{/*
The pre-defined static clients left out of the configuration — a clientID
without a secret source — as a YAML list of {key, id} for NOTES.txt.
*/}}
{{- define "dex.staticClients.withoutSecret" -}}
{{- range $name := (include "dex.staticClients.confidential" . | splitList " ") -}}
{{- $client := index $.Values.oidc.staticClients $name -}}
{{- if and $client.clientID (not (include "dex.staticClient.hasSecret" $client)) }}
- key: {{ $name }}
  id: {{ $client.clientID | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validates one static client's secret sources — at most one of the inline value,
the environment variable name and the Secret reference; none only on a public
client or on one that is left out without a secret (`optional`) — and prints it
as a YAML list item {id, env, name, key} when it is a reference, nothing
otherwise. Takes a dict with `id`, `secret`, `secretEnv`, `secretRef`, `public`,
`optional` and `fields` (the field names for the error message).
*/}}
{{- define "dex.staticClient.secretRef" -}}
{{- $id := .id -}}
{{- $sources := 0 -}}
{{- if .secret }}{{ $sources = add1 $sources }}{{ end -}}
{{- if .secretEnv }}{{ $sources = add1 $sources }}{{ end -}}
{{- if .secretRef }}{{ $sources = add1 $sources }}{{ end -}}
{{- if gt $sources 1 -}}
  {{- fail (printf "dex-app: static client %q sets more than one of %s; set exactly one" $id .fields) -}}
{{- else if and (eq $sources 0) (not .public) (not .optional) -}}
  {{- fail (printf "dex-app: static client %q sets none of %s; set exactly one" $id .fields) -}}
{{- end -}}
{{- with .secretRef -}}
  {{- if not (and .name .key) -}}
    {{- fail (printf "dex-app: static client %q: the secret reference needs name and key" $id) -}}
  {{- end -}}
- id: {{ $id | quote }}
  env: {{ include "dex.staticClient.secretEnvName" $id }}
  name: {{ .name | quote }}
  key: {{ .key | quote }}
{{ end -}}
{{- end -}}

{{/*
Every static client whose secret is a reference to a Kubernetes Secret, as a
YAML list of {id, env, name, key}: the Deployment sets one environment variable
per item from the referenced key and the dex configuration names that variable
in `secretEnv`. Every static client is validated on the way — at most one of
the inline value and the reference; a pre-defined client with neither is left
out (dex.staticClient.hasSecret), dex-k8s-authenticator and a confidential extra
client need one — so rendering either template fails naming the client. Two ids
that map to the same variable name fail as well: the variable would carry only
one of the two secrets.
*/}}
{{- define "dex.staticClients.secretRefs" -}}
{{- $clients := .Values.oidc.staticClients -}}
{{- $refs := "" -}}
{{- range $name := (include "dex.staticClients.confidential" . | splitList " ") -}}
  {{- $client := index $clients $name -}}
  {{- if $client.clientID -}}
    {{- $refs = print $refs (include "dex.staticClient.secretRef" (dict "id" $client.clientID "secret" $client.clientSecret "secretRef" $client.clientSecretRef "optional" true "fields" (printf "oidc.staticClients.%s.clientSecret and .clientSecretRef" $name))) -}}
  {{- end -}}
{{- end -}}
{{- if or .Values.isManagementCluster (eq (include "is-workload-cluster" .) "true") -}}
  {{- $refs = print $refs (include "dex.staticClient.secretRef" (dict "id" "dex-k8s-authenticator" "secret" $clients.dexK8SAuthenticator.clientSecret "secretRef" $clients.dexK8SAuthenticator.clientSecretRef "fields" "oidc.staticClients.dexK8SAuthenticator.clientSecret (a chart default; set it to \"\" to use the reference) and .clientSecretRef")) -}}
{{- end -}}
{{- range .Values.oidc.extraStaticClients -}}
  {{- if and .secretRef (not .id) -}}
    {{- fail (printf "dex-app: extra static client %q: secretRef needs a literal id, not idEnv" (.name | default .idEnv)) -}}
  {{- end -}}
  {{- $refs = print $refs (include "dex.staticClient.secretRef" (dict "id" (.id | default .idEnv) "secret" .secret "secretEnv" .secretEnv "secretRef" .secretRef "public" .public "fields" "secret, secretEnv and secretRef")) -}}
{{- end -}}
{{- $envs := list -}}
{{- range ($refs | fromYamlArray) -}}
  {{- if has .env $envs -}}
    {{- fail (printf "dex-app: static client %q: another client's id also maps to the variable %s; client ids must differ after [^A-Za-z0-9] -> _" .id .env) -}}
  {{- end -}}
  {{- $envs = append $envs .env -}}
{{- end -}}
{{- $refs -}}
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