{{/* Map keys are connector ids; list entries carry their own ids. */}}
{{- define "dex.connectors.normalize" -}}
{{- $connectors := .connectors -}}
{{- if kindIs "map" $connectors -}}
{{- range $id := keys $connectors | sortAlpha -}}
{{- $connector := deepCopy (index $connectors $id) -}}
{{- $_ := set $connector "id" $id -}}
{{- toYaml (list $connector) }}
{{ end -}}
{{- else if kindIs "slice" $connectors -}}
{{- toYaml $connectors -}}
{{- else if $connectors -}}
{{- fail (printf "dex-app: %s must be a map or a list" .path) -}}
{{- end -}}
{{- end -}}

{{- define "dex.giantswarm.connectors" -}}
{{- include "dex.connectors.normalize" (dict "connectors" .Values.oidc.giantswarm.connectors "path" "oidc.giantswarm.connectors") -}}
{{- end -}}

{{- define "dex.customer.connectors" -}}
{{- include "dex.connectors.normalize" (dict "connectors" .Values.oidc.customer.connectors "path" "oidc.customer.connectors") -}}
{{- end -}}

{{- define "dex.connector.secretEnvName" -}}
{{- printf "DEX_CONNECTOR_SECRET_%s" (regexReplaceAll "[^A-Za-z0-9]" . "_" | upper) -}}
{{- end -}}

{{- define "dex.connectors.secretRefs" -}}
{{- $envs := list -}}
{{- range concat (include "dex.giantswarm.connectors" . | fromYamlArray) (include "dex.customer.connectors" . | fromYamlArray) -}}
{{- with .clientSecretRef -}}
{{- if not (and .name .key) -}}
{{- fail "dex-app: connector clientSecretRef needs name and key" -}}
{{- end -}}
{{- end -}}
{{- if .clientSecretRef -}}
{{- if not (kindIs "map" .config) -}}
{{- fail (printf "dex-app: connector %q: clientSecretRef requires config as a map" .id) -}}
{{- end -}}
{{- $env := include "dex.connector.secretEnvName" .id -}}
{{- if has $env $envs -}}
{{- fail (printf "dex-app: connector %q: another connector's id also maps to variable %s" .id $env) -}}
{{- end -}}
{{- $envs = append $envs $env -}}
- id: {{ .id | quote }}
  env: {{ $env }}
  name: {{ .clientSecretRef.name | quote }}
  key: {{ .clientSecretRef.key | quote }}
  optional: true
{{ end -}}
{{- end -}}
{{- end -}}

{{- define "dex.connector" -}}
- type: {{ .connectorType }}
  id: {{ .id }}
  name: {{ .connectorName }}
  config:
{{- if hasKey . "config" -}}
{{- $config := deepCopy .config -}}
{{- if .clientSecretRef -}}
{{- $_ := set $config "clientSecret" (printf "${%s}" (include "dex.connector.secretEnvName" .id)) -}}
{{- end -}}
{{- toYaml $config | nindent 4 }}
{{- else -}}
{{- .connectorConfig | nindent 4 }}
{{- end }}
{{- end -}}
