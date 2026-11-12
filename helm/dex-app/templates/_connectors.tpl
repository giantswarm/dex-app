{{- define "dex.connector.secretEnvName" -}}
{{- printf "DEX_CONNECTOR_SECRET_%s" (regexReplaceAll "[^A-Za-z0-9]" . "_" | upper) -}}
{{- end -}}

{{- define "dex.connectors.secretRefs" -}}
{{- $envs := list -}}
{{- range $owner := list .Values.oidc.giantswarm .Values.oidc.customer -}}
{{- range $id, $connector := $owner.connectors -}}
{{- if kindIs "slice" $owner.connectors }}{{ $id = $connector.id }}{{ end -}}
{{- with $connector.clientSecretRef -}}
{{- $env := include "dex.connector.secretEnvName" $id -}}
{{- if has $env $envs -}}
{{- fail (printf "dex-app: connector %q: another connector's id also maps to variable %s" $id $env) -}}
{{- end -}}
{{- $envs = append $envs $env -}}
- id: {{ $id | quote }}
  env: {{ $env }}
  name: {{ .name | quote }}
  key: {{ .key | quote }}
  optional: true
{{ end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "dex.connector" -}}
{{- $connector := .connector -}}
- type: {{ $connector.connectorType }}
  id: {{ .id }}
  name: {{ $connector.connectorName }}
  config:
{{- if hasKey $connector "config" -}}
{{- $config := deepCopy $connector.config -}}
{{- if $connector.clientSecretRef -}}
{{- $_ := set $config "clientSecret" (printf "${%s}" (include "dex.connector.secretEnvName" .id)) -}}
{{- end -}}
{{- toYaml $config | nindent 4 }}
{{- else -}}
{{- $connector.connectorConfig | nindent 4 }}
{{- end }}
{{- end -}}
