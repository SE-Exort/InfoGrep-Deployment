{{- define "infogrep.aiService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.AiService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.aiService.serviceAccountName" -}}
{{- if .Values.AiService.serviceAccount.create -}}
    {{ default (include "infogrep.aiService.fullname" .) .Values.AiService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.AiService.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "infogrep.authService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.AuthService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.authService.serviceAccountName" -}}
{{- if .Values.AuthService.serviceAccount.create -}}
    {{ default (include "infogrep.authService.fullname" .) .Values.AuthService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.AuthService.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "infogrep.authPostgres.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.AuthPostgres.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.videoService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.VideoService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.videoService.serviceAccountName" -}}
{{- if .Values.VideoService.serviceAccount.create -}}
    {{ default (include "infogrep.videoService.fullname" .) .Values.VideoService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.VideoService.serviceAccount.name }}
{{- end -}}
{{- end -}}