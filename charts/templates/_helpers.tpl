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

{{- define "infogrep.postgres.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) .Values.InfogrepPostgres.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.postgresService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.postgres.fullname" .) "rw" | trunc 63 | trimSuffix "-" -}}
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

{{- define "infogrepClientCertVolumeMounts" -}}
- name: infogrep-internal-client-certs-elasticsearch
  mountPath: "/etc/secrets/ca/elasticsearch"
  readOnly: true
- name: infogrep-internal-client-certs-postgres
  mountPath: "/etc/secrets/ca/postgres"
  readOnly: true
{{- end -}}

{{- define "infogrepClientCertVoumes" -}}
- name: infogrep-internal-client-certs-elasticsearch
  secret:
    secretName: "{{ template "infogrep.elasticsearchService.fullname" . }}-es-http-certs-public"
    defaultMode: 256
    items:
      - key: tls.crt
        path: tls.crt
- name: infogrep-internal-client-certs-postgres
  projected:
    defaultMode: 256
    sources:
    - secret:
        name: infogrep-cnpg-client-cert
        items:
          - key: tls.crt
            path: tls.crt
            mode: 256
    - secret:
        name: infogrep-cnpg-client-cert
        items:
          - key: tls.key
            path: tls.key
            mode: 256
    - secret:
        name: infogrep-postgres-ca
        items:
          - key: ca.crt
            path: ca.crt
            mode: 256
{{- end -}}

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
- name: OLLAMA_SERVICE_HOST
  valueFrom:
    configMapKeyRef:
      name: infogrep-service-url-config
      key: ollamaServiceHost
      optional: false
{{- end -}}

{{- define "infogrepPostgresEnv" -}}
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
- name: PG_VERIFY_CERT
  value: "true"
- name: PG_TLS_CERT_PATH
  value: "/etc/secrets/ca/postgres/tls.crt"
- name: PG_TLS_KEY_PATH
  value: "/etc/secrets/ca/postgres/tls.key"
- name: PG_CA_CERT_PATH
  value: "/etc/secrets/ca/postgres/ca.crt"
{{- end -}}

{{- define "infogrepElasticsearchEnv" -}}
- name: ES_SERVICE_HOST
  value: "{{ template "infogrep.elasticsearchService.fullname" . }}-es-http"
- name: ES_SERVICE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "infogrep.elasticsearchService.fullname" . }}-es-elastic-user
      key: elastic
      optional: false
- name: ES_VERIFY_CERT
  value: "true"
- name: ES_TLS_CERT_PATH
  value: "/etc/secrets/ca/elasticsearch/tls.crt"
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
  {{- include "infogrepPostgresEnv" . | nindent 2}}
{{- end -}}

{{- define "infogrep.elasticsearchService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) "elasticsearch-logs" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infogrep.kibanaService.fullname" -}}
{{- printf "%s-%s" (include "infogrep.fullname" .) "kibana" | trunc 63 | trimSuffix "-" -}}
{{- end -}}