{{/* vim: set filetype=mustache: */}}

{{- define "resource.default.name" -}}
dex-k8s-authenticator-customer
{{- end -}}

{{- define "resource.networkPolicy.name" -}}
{{- include "resource.default.name" . -}}-network-policy
{{- end -}}

{{- define "resource.psp.name" -}}
{{- include "resource.default.name" . -}}-psp
{{- end -}}

