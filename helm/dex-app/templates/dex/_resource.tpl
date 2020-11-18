{{/* vim: set filetype=mustache: */}}

{{- define "resource.default.name" -}}
dex
{{- end -}}

{{- define "resource.dex.networkPolicy.name" -}}
{{- include "resource.default.name" . -}}-network-policy
{{- end -}}

{{- define "resource.dex.psp.name" -}}
{{- include "resource.default.name" . -}}-psp
{{- end -}}
