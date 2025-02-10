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

{{- define "infogrep.infogrepPostgres.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.InfogrepPostgres.name | trunc 63 | trimSuffix "-" -}}
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

{{- define "infogrep.vectorEtcd.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.VectorEtcd.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.vectorEtcd.serviceAccountName" -}}
{{- if .Values.VectorEtcd.serviceAccount.create -}}
    {{ default (include "infogrep.fileManagementService.fullname" .) .Values.VectorEtcd.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.VectorEtcd.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "infogrep.vectorMinio.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.VectorMinio.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.vectorMinio.serviceAccountName" -}}
{{- if .Values.VectorMinio.serviceAccount.create -}}
    {{ default (include "infogrep.vectorMinio.fullname" .) .Values.VectorMinio.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.VectorMinio.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "infogrep.vectorMilvus.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.VectorMilvus.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.vectorMilvus.serviceAccountName" -}}
{{- if .Values.VectorMilvus.serviceAccount.create -}}
    {{ default (include "infogrep.vectorMilvus.fullname" .) .Values.VectorMilvus.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.VectorMilvus.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "infogrep.vectorAttu.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.VectorAttu.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.vectorAttu.serviceAccountName" -}}
{{- if .Values.VectorAttu.serviceAccount.create -}}
    {{ default (include "infogrep.vectorAttu.fullname" .) .Values.VectorAttu.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.VectorAttu.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "waitForPostgres" -}}
- name: wait-for-postgres
  image: busybox
  command: ["/bin/sh", "-c"]
  args:
      [
      "until echo 'Waiting for auth service postgres...' && nc -vz -w 2 $PGHOST $PGPORT; do echo 'Looping forever...'; sleep 2; done;",
      ] 
  env:
  {{- with .Values.PostgresEnv }}
      {{- tpl (toYaml .) $ | nindent 6 }}
  {{- end }}
  {{- end -}}