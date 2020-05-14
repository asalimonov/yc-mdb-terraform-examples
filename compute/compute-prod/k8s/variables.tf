variable "yc_oauth_token" {
  description = "YC OAuth token"
  default     = ""
  type        = "string"
}

variable "yc_cloud_id" {
  description = "ID of a cloud"
  type        = "string"
  default     = ""
}

variable "yc_folder_id" {
  description = "ID of a folder"
  type        = "string"
}

variable "yc_main_zone" {
  description = "The main availability zone"
  default     = "ru-central1-a"
  type        = "string"
}

variable "labels" {
  description = "Set of labels"
  default     = { "env" = "prod", "created_by" = "tf" }
  type        = map(string)
}
