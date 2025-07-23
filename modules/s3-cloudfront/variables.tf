variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "aliases" {
  description = "List of custom domain aliases"
  type        = list(string)
  default     = []
}

variable "zone_id" {
  
}

variable "record_name" {
  
}

variable "allowed_origins" {
  
}