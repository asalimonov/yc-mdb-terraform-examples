variable "yc_oauth_token" {
  description = "YC OAuth token"
  default     = ""
  type        = "string"
}

variable "yc_cloud_id" {
  description = "ID of a cloud"
  default     = ""
  type        = "string"
}

variable "yc_folder_id" {
  description = "ID of a folder"
  default     = ""
  type        = "string"
}

variable "yc_main_zone" {
  description = "The main availability zone"
  default     = "ru-central1-a"
  type        = "string"
}

variable "default_labels" {
  description = "Set of labels"
  default     = { "env" = "prod", "deployment" = "terraform" }
  type        = map(string)
}
