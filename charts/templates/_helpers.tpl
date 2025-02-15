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


{{- define "infogrep.milvus.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.MilvusConfig.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# {{- define "infogrep.milvus.serviceAccountName" -}}
# {{- if .Values.VectorMilvus.serviceAccount.create -}}
#     {{ default (include "infogrep.vectorMilvus.fullname" .) .Values.VectorMilvus.serviceAccount.name }}
# {{- else -}}
#     {{ default "default" .}}
# {{- end -}}
# {{- end -}}

{{- define "defaultEnv" -}}
- name: AI_SERVICE_HOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-service-url-config
      key: aiServiceHost
      optional: false
- name: AUTH_SERVICE_HOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-service-url-config
      key: authServiceHost
      optional: false
- name: CHATROOM_SERVICE_HOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-service-url-config
      key: chatroomServiceHost
      optional: false
- name: FILE_MANAGEMENT_SERVICE_HOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-service-url-config
      key: fileManagementServiceHost
      optional: false
- name: MILVUS_SERVICE_HOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-service-url-config
      key: milvusServiceHost
      optional: false
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: infogrep-pg-creds
      key: password
      optional: false
- name: POSTGRES_USERNAME
  valueFrom:
    secretKeyRef:
      name: infogrep-pg-creds
      key: username
      optional: false
- name: PGHOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-pg-configs
      key: pgHost
      optional: false
- name: PGPORT
  value: "5432"
- name: ES_SERVICE_HOST
  value: "{{ template "infogrep.elasticsearchService.fullname" . }}-es-http"
- name: ES_SERVICE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "infogrep.elasticsearchService.fullname" . }}-es-elastic-user
      key: elastic
      optional: false
- name: OLLAMA_SERVICE_HOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-service-url-config
      key: ollamaServiceHost
      optional: false
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
  {{- include "defaultEnv" . | nindent 2}}
{{- end -}}

{{- define "infogrep.elasticsearchService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) "elasticsearch-logs" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.kibanaService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) "kibana" | trunc 63 | trimSuffix "-" -}}
{{- end -}}