{{/*
Expand the name of the chart.
*/}}
{{- define "zadig.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zadig.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zadig.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "zadig.labels" -}}
helm.sh/chart: {{ include "zadig.chart" . }}
{{ include "zadig.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zadig.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zadig.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end }}

{{/*
=====================================================
=         ZADIG SERVICE ACCOUNT SETTINGS            =
=====================================================
*/}}
{{- define "zadig.serviceAccountName" -}}
sa-{{ .Release.Name }}
{{- end }}

{{/*
=====================================================
=              ZADIG ENDPOINT SETTINGS              =
=====================================================
*/}}
{{- define "zadig.endpoint" -}}
{{- if eq .Values.endpoint.type "IP" }}
{{- $nodeport := index .Values "gloo" "gatewayProxies" "gatewayProxy" "service" "httpNodePort" }}
{{- required "endpoint.IP is required for ip endpoint type!" .Values.endpoint.IP }}:{{- required "ingress-nginx.controller.service.nodePorts.http is required for ip endpoint type" $nodeport }}
{{- else if eq .Values.endpoint.type "FQDN" }}
{{- required "endpoint.FQDN is required for FQDN type" .Values.endpoint.FQDN }}
{{- else }}
{{- required "endpoint.type must be IP or FQDN" .Values.error }}
{{- end }}
{{- end }}

{{/*
=====================================================
=             ZADIG ROOT TOKEN SETTINGS             =
=====================================================
*/}}
{{- define "zadig.rootToken" -}}
{{- .Values.global.encryption.key | trunc 16 -}}
{{- end }}

{{/*
=====================================================
=            ASLAN MICROSERVICE SETTINGS            =
=====================================================
*/}}
{{- define "zadig.microservice.aslan.port" -}}
25000
{{- end }}

{{- define "zadig.microservice.aslan.labels" -}}
app.kubernetes.io/component: aslan
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.aslan.selectorLabels" -}}
app.kubernetes.io/component: aslan
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=            CRON MICROSERVICE SETTINGS             =
=====================================================
*/}}
{{- define "zadig.microservice.cron.labels" -}}
app.kubernetes.io/component: cron
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.cron.selectorLabels" -}}
app.kubernetes.io/component: cron
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=            DIND MICROSERVICE SETTINGS             =
=====================================================
*/}}
{{- define "zadig.microservice.dind.port" -}}
2375
{{- end }}

{{- define "zadig.microservice.dind.labels" -}}
app.kubernetes.io/component: dind
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.dind.selectorLabels" -}}
app.kubernetes.io/component: dind
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=                NSQ LOOKUPD SETTINGS               =
=====================================================
*/}}
{{- define "zadig.microservice.nsqlookupd.labels" -}}
app.kubernetes.io/component: nsqlookupd
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.nsqlookupd.selectorLabels" -}}
app.kubernetes.io/component: nsqlookupd
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=         HUB SERVER MICROSERVICE SETTINGS          =
=====================================================
*/}}
{{- define "zadig.microservice.hubServer.port" -}}
26000
{{- end }}

{{- define "zadig.microservice.hubServer.labels" -}}
app.kubernetes.io/component: hub-server
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.hubServer.selectorLabels" -}}
app.kubernetes.io/component: hub-server
{{ include "zadig.selectorLabels" . }}
{{- end }}



{{/*
=====================================================
=          OPA MICROSERVICE SETTINGS          =
=====================================================
*/}}
{{- define "zadig.microservice.opa.port" -}}
8181
{{- end }}

{{- define "zadig.microservice.opa.labels" -}}
app.kubernetes.io/component: opa
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.opa.selectorLabels" -}}
app.kubernetes.io/component: opa
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=          WARPDRIVE MICROSERVICE SETTINGS          =
=====================================================
*/}}
{{- define "zadig.microservice.warpdrive.port" -}}
25001
{{- end }}

{{- define "zadig.microservice.warpdrive.labels" -}}
app.kubernetes.io/component: warpdrive
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.warpdrive.selectorLabels" -}}
app.kubernetes.io/component: warpdrive
{{ include "zadig.selectorLabels" . }}
{{- end }}

=====================================================
=     RESOURCE SERVER MICROSERVICE SETTINGS         =
=====================================================
*/}}
{{- define "zadig.microservice.resourceServer.port" -}}
80
{{- end }}

{{- define "zadig.microservice.resourceServer.labels" -}}
app.kubernetes.io/component: resource-server
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.microservice.resourceServer.selectorLabels" -}}
app.kubernetes.io/component: resource-server
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=          FRONTEND MICROSERVICE SETTINGS           =
=====================================================
*/}}
{{- define "zadig.frontend.labels" -}}
app.kubernetes.io/component: zadig-portal
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.frontend.selectorLabels" -}}
app.kubernetes.io/component: zadig-portal
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=          POST HOOK SETTINGS           =
=====================================================
*/}}
{{- define "zadig.postHook.labels" -}}
app.kubernetes.io/component: post-hook
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.postHook.selectorLabels" -}}
app.kubernetes.io/component: post-hook
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=          INIT JOB SETTINGS           =
=====================================================
*/}}
{{- define "zadig.init.labels" -}}
app.kubernetes.io/component: init
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.init.selectorLabels" -}}
app.kubernetes.io/component: init
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=                  MYSQL SETTINGS                   =
=====================================================
*/}}
{{- define "zadig.mysql.name" -}}
{{- if .Values.mysql.fullnameOverride -}}
{{- .Values.mysql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
zadig-mysql
{{- end -}}
{{- end -}}

{{- define "zadig.mysql.labels" -}}
app.kubernetes.io/component: mysql
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.mysql.selectorLabels" -}}
app.kubernetes.io/component: mysql
{{ include "zadig.selectorLabels" . }}
{{- end }}

{{/*
=====================================================
=                MONGODB SETTINGS                   =
=====================================================
*/}}
{{- define "zadig.mongodb.name" -}}
{{- if .Values.mongodb.fullnameOverride -}}
{{- .Values.mongodb.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
zadig-mongodb
{{- end -}}
{{- end -}}

{{- define "zadig.mongodb.labels" -}}
app.kubernetes.io/component: mongodb
{{ include "zadig.labels" . }}
{{- end }}

{{- define "zadig.mongodb.selectorLabels" -}}
app.kubernetes.io/component: mongodb
{{ include "zadig.selectorLabels" . }}
{{- end }}
