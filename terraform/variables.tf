variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = "westus"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "homelab-ai-apps"
}

variable "unique_suffix" {
  type        = string
  description = "Suffix for globally unique resource names"
  default     = "poc-001"
}

variable "apim_publisher_name" {
  type        = string
  description = "Publisher name for APIM"
  default     = "Homelab Admin"
}

variable "apim_publisher_email" {
  type        = string
  description = "Publisher email for APIM"
  default     = "admin@homelab.local"
}

variable "tenant_id" {
  type        = string
  description = "Entra ID Tenant ID for JWT validation"
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "apim_client_id" {
  type        = string
  description = "Client ID of the APIM Entra ID Application"
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "apim_shared_secret" {
  type        = string
  description = "Shared secret injected by APIM into backend requests"
  sensitive   = true
  default     = "ChangeMeInProduction123!"
}
