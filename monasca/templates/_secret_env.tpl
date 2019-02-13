{{- /*
Read a single optional secret or string from values into an `env` `value:` or
`valueFrom:`, depending on the user-defined content of the value.

Example:
  - name: OS_AUTH_URL
    {{ template "monasca_secret_env" .Values.auth.url }}

Note that unlike monasca_keystone_env, secret_key can not have any default
values.

Make sure to change the name of this template when copying to keep it unique,
e.g. chart_name_secret_env.
*/}}
{{- define "monasca_secret_env" }}
{{- if eq (kindOf .) "map" }}
valueFrom:
  secretKeyRef:
    name: "{{ .secret_name }}"
    key: "{{ .secret_key }}"
{{- else }}
value: "{{ . }}"
{{- end }}
{{- end }}

{{- /*
Generate a list of environment vars for Keystone Auth

Example:
  env:
{{ include "monasca_keystone_env" .Values.my_pod.auth | indent 4 }}

(indent level should be adjusted as necessary)

Make sure to change the name of this template when copying to keep it unique,
e.g. chart_name_keystone_env.

Note that monasca_secret_env is not used here because we want to provide
default key names.

Note: this template does NOT set OS_AUTH_URL, since we may need to reference our
internal Keystone URL and Helm cannot pass more than one variable at once.
*/}}
{{- define "monasca_keystone_env" -}}
{{- if .api_version }}
- name: OS_IDENTITY_API_VERSION
  value: "{{ .api_version }}"
{{- end }}
{{- if .domain_name }}
- name: OS_DOMAIN_NAME
{{- if eq (kindOf .domain_name) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .domain_name.secret_name }}"
      key: "{{ .domain_name.secret_key | default "OS_DOMAIN_NAME" }}"
{{- else }}
  value: "{{ .domain_name }}"
{{- end }}
{{- end }}
- name: OS_USERNAME
{{- if eq (kindOf .username) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .username.secret_name }}"
      key: "{{ .username.secret_key | default "OS_USERNAME" }}"
{{- else }}
  value: "{{ .username }}"
{{- end }}
- name: OS_PASSWORD
{{- if eq (kindOf .password) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .password.secret_name }}"
      key: "{{ .password.secret_key | default "OS_PASSWORD" }}"
{{- else }}
  value: "{{ .password }}"
{{- end }}
{{- if .user_domain_name }}
- name: OS_USER_DOMAIN_NAME
{{- if eq (kindOf .user_domain_name) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .user_domain_name.secret_name }}"
      key: "{{ .user_domain_name.secret_key | default "OS_USER_DOMAIN_NAME" }}"
{{- else }}
  value: "{{ .user_domain_name }}"
{{- end }}
{{- end }}
{{- if .project_name }}
- name: OS_PROJECT_NAME
{{- if eq (kindOf .project_name) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .project_name.secret_name }}"
      key: "{{ .project_name.secret_key | default "OS_PROJECT_NAME" }}"
{{- else }}
  value: "{{ .project_name }}"
{{- end }}
{{- end }}
{{- if .project_domain_name }}
- name: OS_PROJECT_DOMAIN_NAME
{{- if eq (kindOf .project_domain_name) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .project_domain_name.secret_name }}"
      key: "{{ .project_domain_name.secret_key | default "OS_PROJECT_DOMAIN_NAME" }}"
{{- else }}
  value: "{{ .project_domain_name }}"
{{- end }}
{{- end }}
{{- if .tenant_name }}
- name: OS_TENANT_NAME
{{- if eq (kindOf .tenant_name) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .tenant_name.secret_name }}"
      key: "{{ .tenant_name.secret_key | default "OS_TENANT_NAME" }}"
{{- else }}
  value: "{{ .tenant_name }}"
{{- end }}
{{- end }}
{{- if .tenant_id }}
- name: OS_TENANT_ID
{{- if eq (kindOf .tenant_id) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .tenant_id.secret_name }}"
      key: "{{ .tenant_id.secret_key | default "OS_TENANT_ID" }}"
{{- else }}
  value: "{{ .tenant_id }}"
{{- end }}
{{- end }}
{{- if .region_name }}
- name: OS_REGION_NAME
{{- if eq (kindOf .region_name) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .region_name.secret_name }}"
      key: "{{ .region_name.secret_key | default "OS_REGION_NAME" }}"
{{- else }}
  value: "{{ .region_name }}"
{{- end }}
{{- end }}
{{- if .auth_type }}
- name: OS_AUTH_TYPE
{{- if eq (kindOf .auth_type) "map" }}
  valueFrom:
    secretKeyRef:
      name: "{{ .auth_type.secret_name }}"
      key: "{{ .auth_type.secret_key | default "OS_AUTH_TYPE" }}"
{{- else }}
  value: "{{ .auth_type }}"
{{- end }}
{{- end }}
{{- end -}}
