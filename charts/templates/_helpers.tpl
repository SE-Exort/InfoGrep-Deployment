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

{{- define "infogrep.chatroomService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.ChatroomService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.chatroomService.serviceAccountName" -}}
{{- if .Values.ChatroomService.serviceAccount.create -}}
    {{ default (include "infogrep.chatroomService.fullname" .) .Values.ChatroomService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.ChatroomService.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "infogrep.parsingService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.ParsingService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.parsingService.serviceAccountName" -}}
{{- if .Values.ParsingService.serviceAccount.create -}}
    {{ default (include "infogrep.parsingService.fullname" .) .Values.ParsingService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.ParsingService.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "infogrep.fileManagementService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.FileManagementService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.fileManagementService.serviceAccountName" -}}
{{- if .Values.FileManagementService.serviceAccount.create -}}
    {{ default (include "infogrep.fileManagementService.fullname" .) .Values.FileManagementService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.FileManagementService.serviceAccount.name }}
{{- end -}}
{{- end -}}