{{/* vim: set filetype=mustache: */}}

{{- define "resource.dex.name" -}}
dex-customer-server
{{- end -}}

{{- define "resource.dex.networkPolicy.name" -}}
{{- include "resource.dex.name" . -}}-network-policy
{{- end -}}

{{- define "resource.dex.psp.name" -}}
{{- include "resource.dex.name" . -}}-psp
{{- end -}}

{{- define "resource.dexauthenticator.name" -}}
dex-customer-client
{{- end -}}

{{- define "resource.dexauthenticator.networkPolicy.name" -}}
{{- include "resource.dexauthenticator.name" . -}}-network-policy
{{- end -}}

{{- define "resource.dexauthenticator.psp.name" -}}
{{- include "resource.dexauthenticator.name" . -}}-psp
{{- end -}}
