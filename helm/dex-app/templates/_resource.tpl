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

{{- define "resource.dexk8sauth.customer.name" -}}
dex-k8s-authenticator-customer
{{- end -}}

{{- define "resource.dexk8sauth.customer.networkPolicy.name" -}}
{{- include "resource.dexk8sauth.customer.name" . -}}-network-policy
{{- end -}}

{{- define "resource.dexk8sauth.customer.psp.name" -}}
{{- include "resource.dexk8sauth.customer.name" . -}}-psp
{{- end -}}