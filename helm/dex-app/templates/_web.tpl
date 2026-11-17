{{/*
The data of the web templates ConfigMap: one key per page in
files/web/templates, named like the upstream page it replaces.
*/}}
{{- define "dex-app.webTemplates.data" -}}
{{- range $path, $_ := .Files.Glob "files/web/templates/*.html" }}
{{ base $path }}: |-
  {{- $.Files.Get $path | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "dex-app.webTemplates.name" -}}
{{ include "resource.dex.name" . }}-web-templates
{{- end -}}
