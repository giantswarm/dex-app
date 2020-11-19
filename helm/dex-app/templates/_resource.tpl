{{/* vim: set filetype=mustache: */}}

{{- define "resource.dex.name" -}}
dex
{{- end -}}

{{- define "resource.dex.networkPolicy.name" -}}
{{- include "resource.dex.name" . -}}-network-policy
{{- end -}}

{{- define "resource.dex.psp.name" -}}
{{- include "resource.dex.name" . -}}-psp
{{- end -}}

{{- define "resource.dexk8sauth.name" -}}
dex-k8s-authenticator
{{- end -}}

{{- define "resource.dexk8sauth.networkPolicy.name" -}}
{{- include "resource.dexk8sauth.name" . -}}-network-policy
{{- end -}}

{{- define "resource.dexk8sauth.psp.name" -}}
{{- include "resource.dexk8sauth.name" . -}}-psp
{{- end -}}
